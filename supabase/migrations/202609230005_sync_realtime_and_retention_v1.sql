-- Phase 6C-B: private invalidation hints, device acknowledgement and safe
-- retention foundation. Apply after 202609230004_sync_onboarding_v1_fix_gate.

create table public.sync_device_registrations (
  user_id uuid not null references auth.users(id) on delete cascade,
  device_id uuid not null,
  generation uuid not null,
  acknowledged_revision bigint not null default 0 check (acknowledged_revision >= 0),
  last_seen_at timestamptz not null default pg_catalog.now(),
  linked boolean not null default true,
  primary key (user_id, device_id)
);
alter table public.sync_device_registrations enable row level security;
alter table public.sync_device_registrations force row level security;
revoke all on public.sync_device_registrations from public, anon, authenticated;
create index sync_devices_retention
  on public.sync_device_registrations(user_id,generation,linked,last_seen_at,acknowledged_revision);

create function public.sync_ack_device_v1(
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
    acknowledged_revision=pg_catalog.greatest(
      public.sync_device_registrations.acknowledged_revision,
      excluded.acknowledged_revision),
    last_seen_at=pg_catalog.now(),linked=true;
  return jsonb_build_object('status','ACKNOWLEDGED','revision',p_revision);
end $$;
revoke all on function public.sync_ack_device_v1(uuid,uuid,bigint) from public,anon;
grant execute on function public.sync_ack_device_v1(uuid,uuid,bigint) to authenticated;

create function public.sync_unlink_device_v1(p_device_id uuid,p_generation uuid)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare v_user uuid:=auth.uid();
begin
  if v_user is null then raise exception using errcode='42501',message='auth required'; end if;
  update public.sync_device_registrations set linked=false,last_seen_at=pg_catalog.now()
   where user_id=v_user and device_id=p_device_id and generation=p_generation;
  return jsonb_build_object('status','UNLINKED');
end $$;
revoke all on function public.sync_unlink_device_v1(uuid,uuid) from public,anon;
grant execute on function public.sync_unlink_device_v1(uuid,uuid) to authenticated;

-- Minimal, private Broadcast hint. It contains no business or receipt fields.
create function public.sync_broadcast_invalidation_v1()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  perform realtime.send(
    jsonb_build_object(
      'event_type','sync_invalidated',
      'generation',new.generation,
      'newest_revision',new.sequence),
    'sync_invalidated',
    'keev-ledger:'||new.user_id::text||':'||new.generation::text,
    true);
  return new;
end $$;
revoke all on function public.sync_broadcast_invalidation_v1()
  from public,anon,authenticated;
create trigger sync_change_log_broadcast_invalidation
after insert on public.sync_change_log for each row
execute function public.sync_broadcast_invalidation_v1();

-- Supabase private Broadcast authorization. A subscriber can receive only the
-- deterministic topic rooted at its own auth.uid(). Anonymous access is absent.
create policy keev_sync_broadcast_select_own on realtime.messages
for select to authenticated using (
  realtime.messages.extension='broadcast' and
  realtime.topic() like ('keev-ledger:'||(select auth.uid())::text||':%')
);

-- Maintenance is deliberately not executable by mobile roles. The initial
-- stale-device window is 180 days; mutation receipts retain at least 365 days.
create function public.sync_prune_safe_history_v1(p_user_id uuid)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare v_generation uuid; v_safe bigint; v_changes bigint:=0;
  v_receipts bigint:=0;
begin
  select generation into v_generation from public.sync_datasets
    where user_id=p_user_id and state='active' for update;
  if v_generation is null then
    return jsonb_build_object('status','NO_ACTIVE_DATASET');
  end if;
  select min(acknowledged_revision) into v_safe
    from public.sync_device_registrations
    where user_id=p_user_id and generation=v_generation and linked=true
      and last_seen_at >= pg_catalog.now()-interval '180 days';
  if v_safe is null then
    return jsonb_build_object('status','NO_SAFE_REVISION');
  end if;
  delete from public.sync_change_log where user_id=p_user_id
    and generation=v_generation and sequence<=v_safe;
  get diagnostics v_changes=row_count;
  delete from public.sync_mutation_receipts where user_id=p_user_id
    and generation=v_generation and resulting_server_revision<=v_safe
    and applied_at < pg_catalog.now()-interval '365 days';
  get diagnostics v_receipts=row_count;
  -- Canonical tombstones are intentionally retained in v1. The calculated
  -- safe revision is the prerequisite for a later FK-aware compactor; this
  -- function never performs unsafe age-only hard deletion.
  return jsonb_build_object('status','PRUNED','safe_revision',v_safe,
    'change_events',v_changes,'mutation_receipts',v_receipts,
    'tombstones',0);
end $$;
revoke all on function public.sync_prune_safe_history_v1(uuid)
  from public,anon,authenticated;
