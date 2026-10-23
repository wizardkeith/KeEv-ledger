-- Phase 6C-A Fix Gate: recoverable initialization lease.
-- Apply after 202609230003_sync_onboarding_v1.sql.
-- Lease authority is PostgreSQL server time; duration is 30 minutes.

alter table public.sync_datasets
  add column initialization_choice text,
  add column initialization_started_at timestamptz,
  add column initialization_lease_expires_at timestamptz;

alter table public.sync_datasets add constraint sync_datasets_initialization_choice
  check (initialization_choice is null or initialization_choice in
    ('enableEmpty','keepLocal','keepCloud','replaceCloud'));

-- Existing in-flight rows receive one finite grace lease on migration.
update public.sync_datasets set
  initialization_started_at=pg_catalog.clock_timestamp(),
  initialization_lease_expires_at=pg_catalog.clock_timestamp()+interval '30 minutes'
where state='initializing' and initialization_lease_expires_at is null;

create or replace function public.sync_begin_initialization_v1(
  p_operation_id uuid,p_choice text
) returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v_user uuid:=auth.uid();
  v_row public.sync_datasets%rowtype;
  v_generation uuid;
  v_revision bigint;
  v_now timestamptz:=pg_catalog.clock_timestamp();
  v_expiry timestamptz:=v_now + interval '30 minutes';
  v_had_dataset boolean;
begin
  if v_user is null then
    raise exception using errcode='42501',message='auth required';
  end if;
  if p_operation_id is null or p_choice not in
    ('enableEmpty','keepLocal','keepCloud','replaceCloud') then
    raise exception using errcode='22023',message='invalid initialization';
  end if;
  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(v_user::text || ':dataset',0));
  select * into v_row from public.sync_datasets where user_id=v_user for update;
  v_had_dataset:=found;

  -- The same operation always resumes idempotently and refreshes its lease.
  if found and v_row.state='initializing' and v_row.operation_id=p_operation_id then
    update public.sync_datasets set
      initialization_lease_expires_at=v_expiry,updated_at=v_now
      where user_id=v_user;
    return jsonb_build_object(
      'status','RESUMED','operation_id',p_operation_id,
      'generation',v_row.generation,
      'snapshot_revision',v_row.snapshot_revision,
      'lease_expires_at',v_expiry);
  end if;

  -- A different operation cannot steal a live lease.
  if found and v_row.state='initializing' and
     coalesce(v_row.initialization_lease_expires_at,'infinity'::timestamptz)>v_now then
    return jsonb_build_object('status','INITIALIZATION_IN_PROGRESS');
  end if;

  -- A user who explicitly chooses the cloud side may recover the durable,
  -- dependency-ordered prefix left by any stale operation without deleting it.
  if found and v_row.state='initializing' and p_choice='keepCloud' then
    v_revision:=coalesce((select max(sequence) from public.sync_change_log
      where user_id=v_user and generation=v_row.generation),0);
    update public.sync_datasets set operation_id=p_operation_id,
      initialization_choice=p_choice,snapshot_revision=v_revision,
      initialization_started_at=v_now,initialization_lease_expires_at=v_expiry,
      updated_at=v_now where user_id=v_user;
    return jsonb_build_object(
      'status','RECOVERED','operation_id',p_operation_id,
      'generation',v_row.generation,
      'snapshot_revision',v_revision,
      'lease_expires_at',v_expiry);
  end if;

  if p_choice='keepCloud' then
    if not found or v_row.state='initializing' then
      return jsonb_build_object('status','RECONCILIATION_REQUIRED');
    end if;
    v_revision:=coalesce((select max(sequence) from public.sync_change_log
      where user_id=v_user and generation=v_row.generation),0);
    update public.sync_datasets set state='initializing',operation_id=p_operation_id,
      initialization_choice=p_choice,initialization_started_at=v_now,
      initialization_lease_expires_at=v_expiry,snapshot_revision=v_revision,
      updated_at=v_now where user_id=v_user;
    return jsonb_build_object(
      'status','STARTED','operation_id',p_operation_id,
      'generation',v_row.generation,'snapshot_revision',v_revision,
      'lease_expires_at',v_expiry);
  end if;

  if p_choice in ('enableEmpty','keepLocal') and (
    exists(select 1 from public.sync_accounts where user_id=v_user and deleted_at is null) or
    exists(select 1 from public.sync_transactions where user_id=v_user and deleted_at is null) or
    exists(select 1 from public.sync_receipt_attachments where user_id=v_user and deleted_at is null) or
    exists(select 1 from public.sync_categories where user_id=v_user and deleted_at is null) or
    exists(select 1 from public.sync_projects where user_id=v_user and deleted_at is null) or
    exists(select 1 from public.sync_budgets where user_id=v_user and deleted_at is null) or
    exists(select 1 from public.sync_transfers where user_id=v_user and deleted_at is null)
  ) then
    return jsonb_build_object('status','RECONCILIATION_REQUIRED');
  end if;

  -- Trusted per-user reset. Encrypted ledger_backups remain independent.
  delete from public.sync_receipt_attachments where user_id=v_user;
  delete from public.sync_transactions where user_id=v_user;
  delete from public.sync_transfers where user_id=v_user;
  delete from public.sync_budgets where user_id=v_user;
  delete from public.sync_projects where user_id=v_user;
  delete from public.sync_categories where user_id=v_user;
  delete from public.sync_accounts where user_id=v_user;
  delete from public.sync_profiles where user_id=v_user;
  delete from public.sync_change_log where user_id=v_user;
  delete from public.sync_mutation_receipts where user_id=v_user;
  v_generation:=gen_random_uuid();
  insert into public.sync_datasets(
    user_id,generation,state,operation_id,snapshot_revision,
    initialization_choice,initialization_started_at,
    initialization_lease_expires_at,updated_at)
  values(v_user,v_generation,'initializing',p_operation_id,0,p_choice,
    v_now,v_expiry,v_now)
  on conflict(user_id) do update set generation=excluded.generation,
    state='initializing',operation_id=excluded.operation_id,snapshot_revision=0,
    initialization_choice=excluded.initialization_choice,
    initialization_started_at=excluded.initialization_started_at,
    initialization_lease_expires_at=excluded.initialization_lease_expires_at,
    updated_at=excluded.updated_at;
  return jsonb_build_object(
    'status',case when v_had_dataset then 'RECOVERED' else 'STARTED' end,
    'operation_id',p_operation_id,'generation',v_generation,
    'snapshot_revision',0,'lease_expires_at',v_expiry);
end $$;
revoke all on function public.sync_begin_initialization_v1(uuid,text)
  from public,anon;
grant execute on function public.sync_begin_initialization_v1(uuid,text)
  to authenticated;

create function public.sync_refresh_initialization_lease_v1(
  p_operation_id uuid,p_generation uuid
) returns jsonb language plpgsql security definer set search_path = '' as $$
declare v_user uuid:=auth.uid(); v_expiry timestamptz;
begin
  if v_user is null then
    raise exception using errcode='42501',message='auth required';
  end if;
  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(v_user::text || ':dataset',0));
  v_expiry:=pg_catalog.clock_timestamp()+interval '30 minutes';
  update public.sync_datasets set initialization_lease_expires_at=v_expiry,
    updated_at=pg_catalog.clock_timestamp()
    where user_id=v_user and state='initializing'
      and operation_id=p_operation_id and generation=p_generation;
  if not found then
    return jsonb_build_object('status','RECONCILIATION_REQUIRED');
  end if;
  return jsonb_build_object('status','REFRESHED','lease_expires_at',v_expiry);
end $$;
revoke all on function public.sync_refresh_initialization_lease_v1(uuid,uuid)
  from public,anon;
grant execute on function public.sync_refresh_initialization_lease_v1(uuid,uuid)
  to authenticated;

create function public.sync_abort_initialization_v1(
  p_operation_id uuid,p_generation uuid
) returns jsonb language plpgsql security definer set search_path = '' as $$
declare v_user uuid:=auth.uid(); v_row public.sync_datasets%rowtype;
begin
  if v_user is null then
    raise exception using errcode='42501',message='auth required';
  end if;
  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(v_user::text || ':dataset',0));
  select * into v_row from public.sync_datasets where user_id=v_user for update;
  if not found or v_row.state<>'initializing' then
    return jsonb_build_object('status','ALREADY_ABORTED');
  end if;
  if v_row.operation_id<>p_operation_id or v_row.generation<>p_generation then
    return jsonb_build_object('status','NOT_OWNER');
  end if;
  -- Keep-cloud abort restores the pre-existing dataset. Upload/reset aborts
  -- leave a recoverable expired lease because partial state is not Active.
  if v_row.initialization_choice='keepCloud' then
    update public.sync_datasets set state='active',operation_id=null,
      initialization_choice=null,initialization_started_at=null,
      initialization_lease_expires_at=null,updated_at=pg_catalog.clock_timestamp()
      where user_id=v_user;
  else
    update public.sync_datasets set initialization_lease_expires_at=pg_catalog.clock_timestamp(),
      updated_at=pg_catalog.clock_timestamp() where user_id=v_user;
  end if;
  return jsonb_build_object('status','ABORTED');
end $$;
revoke all on function public.sync_abort_initialization_v1(uuid,uuid)
  from public,anon;
grant execute on function public.sync_abort_initialization_v1(uuid,uuid)
  to authenticated;

-- Refresh the lease after each idempotent initialization entity milestone.
create or replace function public.sync_initialize_entity_v1(
  p_operation_id uuid,p_generation uuid,p_device_id uuid,p_entity_type text,
  p_entity_id uuid,p_payload jsonb
) returns jsonb language plpgsql security definer set search_path = '' as $$
declare v_user uuid:=auth.uid(); v_ok boolean; v_result jsonb;
begin
  if v_user is null then raise exception using errcode='42501',message='auth required'; end if;
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(v_user::text || ':dataset',0));
  select true into v_ok from public.sync_datasets where user_id=v_user
    and generation=p_generation and operation_id=p_operation_id and state='initializing' for update;
  if not coalesce(v_ok,false) then raise exception using errcode='40001',message='generation mismatch'; end if;
  perform pg_catalog.set_config('keev.sync_generation',p_generation::text,true);
  v_result:=public.sync_apply_mutation_v1_phase6c_base(
    p_entity_id,p_device_id,p_entity_type,p_entity_id,'create',0,p_payload);
  if v_result->>'status' not in ('APPLIED','ALREADY_APPLIED') then
    raise exception using errcode='23514',message='initial entity rejected';
  end if;
  update public.sync_mutation_receipts set generation=p_generation
    where user_id=v_user and mutation_id=p_entity_id;
  update public.sync_datasets set
    initialization_lease_expires_at=pg_catalog.clock_timestamp()+interval '30 minutes',
    updated_at=pg_catalog.clock_timestamp() where user_id=v_user;
  return v_result;
end $$;
revoke all on function public.sync_initialize_entity_v1(uuid,uuid,uuid,text,uuid,jsonb)
  from public,anon;
grant execute on function public.sync_initialize_entity_v1(uuid,uuid,uuid,text,uuid,jsonb)
  to authenticated;

create or replace function public.sync_finalize_initialization_v1(
  p_operation_id uuid,p_generation uuid
) returns jsonb language plpgsql security definer set search_path = '' as $$
declare v_user uuid:=auth.uid(); v_revision bigint;
begin
  if v_user is null then raise exception using errcode='42501',message='auth required'; end if;
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(v_user::text || ':dataset',0));
  update public.sync_datasets set state='active',operation_id=null,
    initialization_choice=null,initialization_started_at=null,
    initialization_lease_expires_at=null,
    snapshot_revision=coalesce((select max(sequence) from public.sync_change_log
      where user_id=v_user and generation=p_generation),0),
    updated_at=pg_catalog.clock_timestamp()
    where user_id=v_user and generation=p_generation
      and operation_id=p_operation_id and state='initializing'
    returning snapshot_revision into v_revision;
  if not found then raise exception using errcode='40001',message='generation mismatch'; end if;
  return jsonb_build_object('maximum_revision',v_revision,'generation',p_generation);
end $$;
revoke all on function public.sync_finalize_initialization_v1(uuid,uuid)
  from public,anon;
grant execute on function public.sync_finalize_initialization_v1(uuid,uuid)
  to authenticated;
