-- Phase 6 final retention safety gate. Apply after 202609230005.

alter table public.sync_datasets
  add column history_floor_revision bigint not null default 0
  check (history_floor_revision >= 0);

create function public.sync_reset_history_floor_on_generation_change_v1()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if new.generation is distinct from old.generation then
    new.history_floor_revision:=0;
  end if;
  return new;
end $$;
revoke all on function public.sync_reset_history_floor_on_generation_change_v1()
  from public,anon,authenticated;
create trigger sync_dataset_generation_resets_history_floor
before update of generation on public.sync_datasets for each row
execute function public.sync_reset_history_floor_on_generation_change_v1();

-- Acknowledgements are monotonic only inside one dataset generation.
create or replace function public.sync_ack_device_v1(
  p_device_id uuid,p_generation uuid,p_revision bigint
) returns jsonb language plpgsql security definer set search_path = '' as $$
declare v_user uuid:=auth.uid(); v_current uuid; v_state text;
begin
  if v_user is null then raise exception using errcode='42501',message='auth required'; end if;
  if p_revision<0 then raise exception using errcode='22023',message='invalid revision'; end if;
  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(v_user::text||':device:'||p_device_id::text,0));
  select generation,state into v_current,v_state from public.sync_datasets
    where user_id=v_user for update;
  if v_current is null or v_current<>p_generation or v_state<>'active' then
    return jsonb_build_object('status','RECONCILIATION_REQUIRED');
  end if;
  insert into public.sync_device_registrations(
    user_id,device_id,generation,acknowledged_revision,last_seen_at,linked)
  values(v_user,p_device_id,p_generation,p_revision,pg_catalog.now(),true)
  on conflict(user_id,device_id) do update set
    generation=excluded.generation,
    acknowledged_revision=case
      when public.sync_device_registrations.generation=excluded.generation
      then pg_catalog.greatest(
        public.sync_device_registrations.acknowledged_revision,
        excluded.acknowledged_revision)
      else excluded.acknowledged_revision
    end,
    last_seen_at=pg_catalog.now(),linked=true;
  return jsonb_build_object('status','ACKNOWLEDGED','revision',p_revision);
end $$;
revoke all on function public.sync_ack_device_v1(uuid,uuid,bigint)
  from public,anon;
grant execute on function public.sync_ack_device_v1(uuid,uuid,bigint)
  to authenticated;

-- Incremental pull is rejected before returning any event when the caller's
-- durable cursor predates history already pruned by trusted maintenance.
create or replace function public.sync_fetch_changes_v2(
  p_generation uuid,p_after_sequence bigint,p_limit integer
) returns jsonb language plpgsql security definer set search_path = '' as $$
declare v_user uuid:=auth.uid(); v_current uuid; v_state text;
  v_floor bigint; v_rows jsonb;
begin
  if v_user is null then raise exception using errcode='42501',message='auth required'; end if;
  if p_after_sequence<0 or p_limit<1 or p_limit>200 then
    return jsonb_build_object('status','REJECTED','reason','INVALID_PAGE');
  end if;
  select generation,state,history_floor_revision
    into v_current,v_state,v_floor from public.sync_datasets
    where user_id=v_user;
  if v_current is null or v_current<>p_generation or v_state<>'active' then
    return jsonb_build_object('status','RECONCILIATION_REQUIRED',
      'reason','GENERATION_MISMATCH');
  end if;
  if p_after_sequence<v_floor then
    return jsonb_build_object('status','RECONCILIATION_REQUIRED',
      'reason','HISTORY_UNAVAILABLE','generation',v_current,
      'history_floor_revision',v_floor);
  end if;
  select coalesce(jsonb_agg(jsonb_build_object(
    'sequence',x.sequence,'entity_type',x.entity_type,'entity_id',x.entity_id,
    'server_version',x.server_version,'operation',x.operation,
    'origin_device_id',x.origin_device_id,'mutation_id',x.mutation_id,
    'payload',x.payload) order by x.sequence),'[]'::jsonb) into v_rows
  from (select * from public.sync_change_log where user_id=v_user
        and generation=p_generation and sequence>p_after_sequence
        order by sequence asc limit p_limit) x;
  return jsonb_build_object('status','OK','generation',v_current,
    'history_floor_revision',v_floor,'changes',v_rows);
end $$;
revoke all on function public.sync_fetch_changes_v2(uuid,bigint,integer)
  from public,anon;
grant execute on function public.sync_fetch_changes_v2(uuid,bigint,integer)
  to authenticated;

create or replace function public.sync_prune_safe_history_v1(p_user_id uuid)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare v_generation uuid; v_safe bigint; v_changes bigint:=0;
  v_receipts bigint:=0; v_floor bigint;
begin
  select generation into v_generation from public.sync_datasets
    where user_id=p_user_id and state='active' for update;
  if v_generation is null then
    return jsonb_build_object('status','NO_ACTIVE_DATASET');
  end if;
  select min(acknowledged_revision) into v_safe
    from public.sync_device_registrations
    where user_id=p_user_id and generation=v_generation and linked=true
      and last_seen_at>=pg_catalog.now()-interval '180 days';
  if v_safe is null then
    return jsonb_build_object('status','NO_SAFE_REVISION');
  end if;
  delete from public.sync_change_log where user_id=p_user_id
    and generation=v_generation and sequence<=v_safe;
  get diagnostics v_changes=row_count;
  update public.sync_datasets set history_floor_revision=
      pg_catalog.greatest(history_floor_revision,v_safe),
      updated_at=pg_catalog.now()
    where user_id=p_user_id and generation=v_generation
    returning history_floor_revision into v_floor;
  delete from public.sync_mutation_receipts where user_id=p_user_id
    and generation=v_generation and resulting_server_revision<=v_safe
    and applied_at<pg_catalog.now()-interval '365 days';
  get diagnostics v_receipts=row_count;
  return jsonb_build_object('status','PRUNED','safe_revision',v_safe,
    'history_floor_revision',v_floor,'change_events',v_changes,
    'mutation_receipts',v_receipts,'tombstones',0);
end $$;
revoke all on function public.sync_prune_safe_history_v1(uuid)
  from public,anon,authenticated;
