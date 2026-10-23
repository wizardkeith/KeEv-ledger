-- Phase 6 final device lifecycle safety gate. Apply after 202609230006.

-- A device acknowledgement is both a generation-scoped cursor and a
-- server-time heartbeat. Reject cursors outside retained, server-known history.
create or replace function public.sync_ack_device_v1(
  p_device_id uuid,p_generation uuid,p_revision bigint
) returns jsonb language plpgsql security definer set search_path = '' as $$
declare v_user uuid:=auth.uid(); v_current uuid; v_state text;
  v_floor bigint; v_head bigint; v_ack bigint;
begin
  if v_user is null then
    raise exception using errcode='42501',message='auth required';
  end if;
  if p_revision<0 then
    return jsonb_build_object('status','REJECTED',
      'reason','INVALID_ACK_REVISION');
  end if;
  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(v_user::text||':device:'||p_device_id::text,0));
  select generation,state,history_floor_revision
    into v_current,v_state,v_floor from public.sync_datasets
    where user_id=v_user for update;
  if v_current is null or v_current<>p_generation or v_state<>'active' then
    return jsonb_build_object('status','RECONCILIATION_REQUIRED',
      'reason','GENERATION_MISMATCH');
  end if;
  if p_revision<v_floor then
    return jsonb_build_object('status','RECONCILIATION_REQUIRED',
      'reason','HISTORY_UNAVAILABLE','history_floor_revision',v_floor);
  end if;
  select pg_catalog.greatest(v_floor,coalesce(max(sequence),v_floor))
    into v_head from public.sync_change_log
    where user_id=v_user and generation=p_generation;
  if p_revision>v_head then
    return jsonb_build_object('status','REJECTED',
      'reason','INVALID_ACK_REVISION','head_revision',v_head);
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
    last_seen_at=pg_catalog.now(),linked=true
  returning acknowledged_revision into v_ack;
  return jsonb_build_object('status','ACKNOWLEDGED','revision',v_ack);
end $$;
revoke all on function public.sync_ack_device_v1(uuid,uuid,bigint)
  from public,anon;
grant execute on function public.sync_ack_device_v1(uuid,uuid,bigint)
  to authenticated;

-- Idempotent own-device unlink. A wrong generation cannot modify a current
-- registration, and no user identifier is accepted from the mobile client.
create or replace function public.sync_unlink_device_v1(
  p_device_id uuid,p_generation uuid
) returns jsonb language plpgsql security definer set search_path = '' as $$
declare v_user uuid:=auth.uid(); v_current uuid; v_changed bigint;
begin
  if v_user is null then
    raise exception using errcode='42501',message='auth required';
  end if;
  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(v_user::text||':device:'||p_device_id::text,0));
  select generation into v_current from public.sync_datasets
    where user_id=v_user;
  if v_current is null or v_current<>p_generation then
    return jsonb_build_object('status','RECONCILIATION_REQUIRED',
      'reason','GENERATION_MISMATCH');
  end if;
  update public.sync_device_registrations
    set linked=false,last_seen_at=pg_catalog.now()
    where user_id=v_user and device_id=p_device_id
      and generation=p_generation and linked=true;
  get diagnostics v_changed=row_count;
  return jsonb_build_object(
    'status',case when v_changed=1 then 'UNLINKED' else 'ALREADY_UNLINKED' end);
end $$;
revoke all on function public.sync_unlink_device_v1(uuid,uuid)
  from public,anon;
grant execute on function public.sync_unlink_device_v1(uuid,uuid)
  to authenticated;
