-- Phase 6C-A: explicit onboarding, dataset generations, trusted reset/init.
-- Apply after 202609230002_sync_runtime_v1_fix_gate.sql.

create table public.sync_datasets (
  user_id uuid primary key references auth.users(id) on delete cascade,
  generation uuid not null,
  state text not null check (state in ('initializing','active')),
  operation_id uuid,
  snapshot_revision bigint not null default 0 check (snapshot_revision >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.sync_datasets enable row level security;
alter table public.sync_datasets force row level security;
create policy sync_datasets_select_own on public.sync_datasets for select
  to authenticated using ((select auth.uid()) = user_id);
revoke all on public.sync_datasets from anon, authenticated;
grant select on public.sync_datasets to authenticated;

alter table public.sync_change_log add column generation uuid;
alter table public.sync_mutation_receipts add column generation uuid;

-- Live sync was not activated before this gate. Existing fixtures are assigned
-- one generation per owner so development projects can migrate deterministically.
insert into public.sync_datasets(user_id,generation,state,snapshot_revision)
select u.user_id, gen_random_uuid(), 'active',
       coalesce((select max(c.sequence) from public.sync_change_log c where c.user_id=u.user_id),0)
from (
  select user_id from public.sync_profiles
  union select user_id from public.sync_change_log
  union select user_id from public.sync_mutation_receipts
) u
on conflict (user_id) do nothing;
update public.sync_change_log c set generation=d.generation
from public.sync_datasets d where c.user_id=d.user_id and c.generation is null;
update public.sync_mutation_receipts r set generation=d.generation
from public.sync_datasets d where r.user_id=d.user_id and r.generation is null;
alter table public.sync_change_log alter column generation set not null;
create index sync_change_log_user_generation_sequence
  on public.sync_change_log(user_id,generation,sequence);
create index sync_receipts_user_generation_mutation
  on public.sync_mutation_receipts(user_id,generation,mutation_id);

create or replace function public.sync_complete_change_event_v1()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  new.mutation_id := nullif(pg_catalog.current_setting('keev.sync_mutation_id',true),'')::uuid;
  new.origin_device_id := nullif(pg_catalog.current_setting('keev.sync_device_id',true),'')::uuid;
  new.generation := nullif(pg_catalog.current_setting('keev.sync_generation',true),'')::uuid;
  new.payload := public.sync_canonical_snapshot_v1(new.user_id,new.entity_type,new.entity_id);
  if new.mutation_id is null or new.origin_device_id is null or
     new.generation is null or new.payload is null then
    raise exception using errcode='23514',message='incomplete sync event';
  end if;
  return new;
end $$;
revoke all on function public.sync_complete_change_event_v1() from public,anon,authenticated;

alter function public.sync_apply_mutation_v1(uuid,uuid,text,uuid,text,bigint,jsonb)
  rename to sync_apply_mutation_v1_phase6c_base;
revoke all on function public.sync_apply_mutation_v1_phase6c_base(
  uuid,uuid,text,uuid,text,bigint,jsonb) from public,anon,authenticated;

-- Receipt metadata has no ordinary update UI. This inaccessible helper permits
-- only an explicit optimistic conflict resolution to revive a tombstone; the
-- public mutation wrapper below remains the sole mobile entry point.
create function public.sync_apply_receipt_resolution_v1(
  p_mutation_id uuid,p_device_id uuid,p_entity_id uuid,
  p_base_server_version bigint,p_payload jsonb,p_generation uuid
) returns jsonb language plpgsql security definer set search_path = '' as $$
declare v_user uuid:=auth.uid(); v_prior public.sync_mutation_receipts%rowtype;
  v_result jsonb; v_snapshot jsonb;
begin
  if v_user is null or p_payload->>'_conflict_resolution'<>'true' then
    return jsonb_build_object('status','REJECTED','reason','UNSUPPORTED_OPERATION');
  end if;
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(v_user::text||':mutation:'||p_mutation_id::text,0));
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(v_user::text||':entity:receipt_attachment:'||p_entity_id::text,0));
  select * into v_prior from public.sync_mutation_receipts where user_id=v_user and mutation_id=p_mutation_id;
  if found then
    return case when v_prior.outcome='APPLIED'
      then jsonb_set(v_prior.result_json,'{status}','"ALREADY_APPLIED"'::jsonb)
      else v_prior.result_json end;
  end if;
  perform pg_catalog.set_config('keev.sync_generation',p_generation::text,true);
  perform pg_catalog.set_config('keev.sync_mutation_id',p_mutation_id::text,true);
  perform pg_catalog.set_config('keev.sync_device_id',p_device_id::text,true);
  v_result:=public.sync_apply_mutation_v1_unlocked(
    p_mutation_id,p_device_id,'receipt_attachment',p_entity_id,'update',
    p_base_server_version,p_payload);
  if v_result->>'status'='CONFLICT' then
    v_snapshot:=public.sync_canonical_snapshot_v1(v_user,'receipt_attachment',p_entity_id);
    v_result:=v_result||jsonb_build_object('server_revision',(v_snapshot->>'server_revision')::bigint,
      'remote_snapshot',v_snapshot,'remote_deleted',(v_snapshot->>'deleted_at') is not null);
  end if;
  update public.sync_mutation_receipts set result_json=v_result,generation=p_generation
    where user_id=v_user and mutation_id=p_mutation_id;
  return v_result;
exception when not_null_violation or numeric_value_out_of_range or invalid_text_representation
  or string_data_right_truncation or check_violation or foreign_key_violation then
  return jsonb_build_object('status','REJECTED','reason','VALIDATION_FAILED');
end $$;
revoke all on function public.sync_apply_receipt_resolution_v1(
  uuid,uuid,uuid,bigint,jsonb,uuid) from public,anon,authenticated;

create function public.sync_apply_mutation_v1(
  p_mutation_id uuid,p_device_id uuid,p_entity_type text,p_entity_id uuid,
  p_operation text,p_base_server_version bigint,p_payload jsonb,p_generation uuid
) returns jsonb language plpgsql security definer set search_path = '' as $$
declare v_user uuid := auth.uid(); v_current uuid; v_state text; v_result jsonb;
begin
  if v_user is null then return jsonb_build_object('status','REJECTED','reason','AUTH_REQUIRED'); end if;
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(v_user::text || ':dataset',0));
  select generation,state into v_current,v_state from public.sync_datasets
    where user_id=v_user for update;
  if v_current is null or v_current<>p_generation or v_state<>'active' then
    return jsonb_build_object('status','RECONCILIATION_REQUIRED');
  end if;
  if p_entity_type='receipt_attachment' and p_operation='update' then
    return public.sync_apply_receipt_resolution_v1(
      p_mutation_id,p_device_id,p_entity_id,p_base_server_version,p_payload,p_generation);
  end if;
  perform pg_catalog.set_config('keev.sync_generation',v_current::text,true);
  v_result := public.sync_apply_mutation_v1_phase6c_base(
    p_mutation_id,p_device_id,p_entity_type,p_entity_id,p_operation,
    p_base_server_version,p_payload);
  update public.sync_mutation_receipts set generation=v_current
    where user_id=v_user and mutation_id=p_mutation_id and generation is null;
  return v_result;
end $$;
revoke all on function public.sync_apply_mutation_v1(
  uuid,uuid,text,uuid,text,bigint,jsonb,uuid) from public,anon;
grant execute on function public.sync_apply_mutation_v1(
  uuid,uuid,text,uuid,text,bigint,jsonb,uuid) to authenticated;

create function public.sync_current_generation_v1()
returns jsonb language plpgsql security definer set search_path = '' as $$
declare v_user uuid:=auth.uid(); v_row public.sync_datasets%rowtype;
begin
  if v_user is null then raise exception using errcode='42501',message='auth required'; end if;
  select * into v_row from public.sync_datasets where user_id=v_user;
  if not found or v_row.state<>'active' then
    return jsonb_build_object('generation',null,'state',coalesce(v_row.state,'missing'));
  end if;
  return jsonb_build_object('generation',v_row.generation,'state',v_row.state);
end $$;
revoke all on function public.sync_current_generation_v1() from public,anon;
grant execute on function public.sync_current_generation_v1() to authenticated;

create function public.sync_fetch_changes_v2(
  p_generation uuid,p_after_sequence bigint,p_limit integer
) returns jsonb language plpgsql security definer set search_path = '' as $$
declare v_user uuid:=auth.uid(); v_current uuid; v_rows jsonb;
begin
  if v_user is null then raise exception using errcode='42501',message='auth required'; end if;
  if p_after_sequence<0 or p_limit<1 or p_limit>200 then
    raise exception using errcode='22023',message='invalid page';
  end if;
  select generation into v_current from public.sync_datasets
    where user_id=v_user and state='active';
  if v_current is null or v_current<>p_generation then
    raise exception using errcode='40001',message='generation mismatch';
  end if;
  select coalesce(jsonb_agg(jsonb_build_object(
    'sequence',x.sequence,'entity_type',x.entity_type,'entity_id',x.entity_id,
    'server_version',x.server_version,'operation',x.operation,
    'origin_device_id',x.origin_device_id,'mutation_id',x.mutation_id,
    'payload',x.payload) order by x.sequence),'[]'::jsonb) into v_rows
  from (select * from public.sync_change_log where user_id=v_user
        and generation=p_generation and sequence>p_after_sequence
        order by sequence asc limit p_limit) x;
  return jsonb_build_object('generation',v_current,'changes',v_rows);
end $$;
revoke all on function public.sync_fetch_changes_v2(uuid,bigint,integer) from public,anon;
grant execute on function public.sync_fetch_changes_v2(uuid,bigint,integer) to authenticated;

create function public.sync_discover_dataset_v1()
returns jsonb language plpgsql security definer set search_path = '' as $$
declare v_user uuid:=auth.uid(); v_dataset public.sync_datasets%rowtype;
begin
  if v_user is null then raise exception using errcode='42501',message='auth required'; end if;
  select * into v_dataset from public.sync_datasets where user_id=v_user;
  return jsonb_build_object(
    'generation',v_dataset.generation,
    'initialization_in_progress',coalesce(v_dataset.state='initializing',false),
    'maximum_revision',coalesce((select max(sequence) from public.sync_change_log where user_id=v_user and generation=v_dataset.generation),0),
    'accounts',(select count(*) from public.sync_accounts where user_id=v_user and deleted_at is null),
    'transactions',(select count(*) from public.sync_transactions where user_id=v_user and deleted_at is null),
    'receipts',(select count(*) from public.sync_receipt_attachments where user_id=v_user and deleted_at is null),
    'other_records',(
      (select count(*) from public.sync_categories where user_id=v_user and deleted_at is null)+
      (select count(*) from public.sync_projects where user_id=v_user and deleted_at is null)+
      (select count(*) from public.sync_budgets where user_id=v_user and deleted_at is null)+
      (select count(*) from public.sync_transfers where user_id=v_user and deleted_at is null)),
    'base_currency_code',(select base_currency_code from public.sync_profiles where user_id=v_user and deleted_at is null limit 1),
    'latest_activity_date',(select max(business_date)::text from (
       select business_date from public.sync_transactions where user_id=v_user and deleted_at is null
       union all select business_date from public.sync_transfers where user_id=v_user and deleted_at is null) q));
end $$;
revoke all on function public.sync_discover_dataset_v1() from public,anon;
grant execute on function public.sync_discover_dataset_v1() to authenticated;

create function public.sync_begin_initialization_v1(p_operation_id uuid,p_choice text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare v_user uuid:=auth.uid(); v_row public.sync_datasets%rowtype; v_generation uuid; v_revision bigint;
begin
  if v_user is null then raise exception using errcode='42501',message='auth required'; end if;
  if p_operation_id is null or p_choice not in ('enableEmpty','keepLocal','keepCloud','replaceCloud') then
    raise exception using errcode='22023',message='invalid initialization';
  end if;
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(v_user::text || ':dataset',0));
  select * into v_row from public.sync_datasets where user_id=v_user for update;
  if found and v_row.state='initializing' and v_row.operation_id<>p_operation_id then
    raise exception using errcode='55P03',message='initialization in progress';
  end if;
  if found and v_row.operation_id=p_operation_id then
    return jsonb_build_object('operation_id',p_operation_id,'generation',v_row.generation,'snapshot_revision',v_row.snapshot_revision);
  end if;
  if p_choice='keepCloud' then
    if not found then raise exception using errcode='40001',message='cloud dataset missing'; end if;
    v_revision:=coalesce((select max(sequence) from public.sync_change_log where user_id=v_user and generation=v_row.generation),0);
    update public.sync_datasets set state='initializing',operation_id=p_operation_id,
      snapshot_revision=v_revision,updated_at=now() where user_id=v_user;
    return jsonb_build_object('operation_id',p_operation_id,'generation',v_row.generation,'snapshot_revision',v_revision);
  end if;
  if p_choice in ('enableEmpty','keepLocal') and (
    exists(select 1 from public.sync_accounts where user_id=v_user and deleted_at is null) or
    exists(select 1 from public.sync_transactions where user_id=v_user and deleted_at is null) or
    exists(select 1 from public.sync_receipt_attachments where user_id=v_user and deleted_at is null)
    or exists(select 1 from public.sync_categories where user_id=v_user and deleted_at is null)
    or exists(select 1 from public.sync_projects where user_id=v_user and deleted_at is null)
    or exists(select 1 from public.sync_budgets where user_id=v_user and deleted_at is null)
    or exists(select 1 from public.sync_transfers where user_id=v_user and deleted_at is null)
  ) then
    raise exception using errcode='40001',message='cloud dataset changed';
  end if;
  -- keepLocal is the only trusted destructive reset. Encrypted backups live in
  -- ledger_backups and are intentionally not touched.
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
  insert into public.sync_datasets(user_id,generation,state,operation_id,snapshot_revision)
    values(v_user,v_generation,'initializing',p_operation_id,0)
    on conflict(user_id) do update set generation=excluded.generation,state='initializing',
      operation_id=excluded.operation_id,snapshot_revision=0,updated_at=now();
  return jsonb_build_object('operation_id',p_operation_id,'generation',v_generation,'snapshot_revision',0);
end $$;
revoke all on function public.sync_begin_initialization_v1(uuid,text) from public,anon;
grant execute on function public.sync_begin_initialization_v1(uuid,text) to authenticated;

create function public.sync_initialize_entity_v1(
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
  return v_result;
end $$;
revoke all on function public.sync_initialize_entity_v1(uuid,uuid,uuid,text,uuid,jsonb) from public,anon;
grant execute on function public.sync_initialize_entity_v1(uuid,uuid,uuid,text,uuid,jsonb) to authenticated;

create function public.sync_finalize_initialization_v1(p_operation_id uuid,p_generation uuid)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare v_user uuid:=auth.uid(); v_revision bigint;
begin
  if v_user is null then raise exception using errcode='42501',message='auth required'; end if;
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(v_user::text || ':dataset',0));
  update public.sync_datasets set state='active',operation_id=null,
    snapshot_revision=coalesce((select max(sequence) from public.sync_change_log where user_id=v_user and generation=p_generation),0),
    updated_at=now()
    where user_id=v_user and generation=p_generation and operation_id=p_operation_id and state='initializing'
    returning snapshot_revision into v_revision;
  if not found then raise exception using errcode='40001',message='generation mismatch'; end if;
  return jsonb_build_object('maximum_revision',v_revision,'generation',p_generation);
end $$;
revoke all on function public.sync_finalize_initialization_v1(uuid,uuid) from public,anon;
grant execute on function public.sync_finalize_initialization_v1(uuid,uuid) to authenticated;

create function public.sync_fetch_snapshot_v1(
  p_generation uuid,p_high_water_revision bigint,p_offset integer,p_limit integer
) returns jsonb language plpgsql security definer set search_path = '' as $$
declare v_user uuid:=auth.uid(); v_rows jsonb; v_count integer;
begin
  if v_user is null then raise exception using errcode='42501',message='auth required'; end if;
  if p_offset<0 or p_limit<1 or p_limit>200 then raise exception using errcode='22023',message='invalid page'; end if;
  if not exists(select 1 from public.sync_datasets where user_id=v_user and generation=p_generation and snapshot_revision=p_high_water_revision) then
    raise exception using errcode='40001',message='generation mismatch';
  end if;
  with canonical as (
    select 1 ord,'profile' entity_type,id entity_id,to_jsonb(t)-'user_id' payload from public.sync_profiles t where user_id=v_user and server_revision<=p_high_water_revision
    union all select 2,'account',id,to_jsonb(t)-'user_id' from public.sync_accounts t where user_id=v_user and server_revision<=p_high_water_revision
    union all select 3,'category',id,to_jsonb(t)-'user_id' from public.sync_categories t where user_id=v_user and server_revision<=p_high_water_revision
    union all select 4,'project',id,to_jsonb(t)-'user_id' from public.sync_projects t where user_id=v_user and server_revision<=p_high_water_revision
    union all select 5,'budget',id,to_jsonb(t)-'user_id' from public.sync_budgets t where user_id=v_user and server_revision<=p_high_water_revision
    union all select 6,'transaction',id,to_jsonb(t)-'user_id' from public.sync_transactions t where user_id=v_user and server_revision<=p_high_water_revision
    union all select 7,'transfer',id,to_jsonb(t)-'user_id' from public.sync_transfers t where user_id=v_user and server_revision<=p_high_water_revision
    union all select 8,'receipt_attachment',id,to_jsonb(t)-'user_id' from public.sync_receipt_attachments t where user_id=v_user and server_revision<=p_high_water_revision
  ), page as (select * from canonical order by ord,entity_id offset p_offset limit p_limit)
  select coalesce(jsonb_agg(jsonb_build_object('entity_type',entity_type,'entity_id',entity_id,'payload',payload) order by ord,entity_id),'[]'::jsonb),count(*) into v_rows,v_count from page;
  return jsonb_build_object('generation',p_generation,'high_water_revision',p_high_water_revision,
    'entities',v_rows,'next_offset',case when v_count=p_limit then p_offset+p_limit else null end);
end $$;
revoke all on function public.sync_fetch_snapshot_v1(uuid,bigint,integer,integer) from public,anon;
grant execute on function public.sync_fetch_snapshot_v1(uuid,bigint,integer,integer) to authenticated;

create function public.sync_fetch_current_entity_v1(p_generation uuid,p_entity_type text,p_entity_id uuid)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare v_user uuid:=auth.uid(); v_payload jsonb;
begin
  if v_user is null then raise exception using errcode='42501',message='auth required'; end if;
  if not exists(select 1 from public.sync_datasets where user_id=v_user and generation=p_generation) then
    raise exception using errcode='40001',message='generation mismatch';
  end if;
  v_payload:=public.sync_canonical_snapshot_v1(v_user,p_entity_type,p_entity_id);
  if v_payload is null then raise exception using errcode='P0002',message='entity missing'; end if;
  v_payload:=v_payload || jsonb_build_object('entity_type',p_entity_type);
  return jsonb_build_object('payload',v_payload,'server_revision',(v_payload->>'server_revision')::bigint);
end $$;
revoke all on function public.sync_fetch_current_entity_v1(uuid,text,uuid) from public,anon;
grant execute on function public.sync_fetch_current_entity_v1(uuid,text,uuid) to authenticated;

-- Client access remains read-only; trusted functions own all mutation/reset work.
revoke insert,update,delete on public.sync_datasets from authenticated;
revoke insert,update,delete on public.sync_change_log from authenticated;
revoke all on public.sync_mutation_receipts from authenticated,anon;
