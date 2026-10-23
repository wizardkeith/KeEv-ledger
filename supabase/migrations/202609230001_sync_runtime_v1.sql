-- Phase 6B runtime: immutable pull events and deterministic conflict receipts.
-- Apply after 202609220003_sync_protocol_v1_final_parity.sql.

alter table public.sync_change_log
  add column payload jsonb,
  add column mutation_id uuid,
  add column origin_device_id uuid;

alter table public.sync_mutation_receipts
  add column result_json jsonb;

create or replace function public.sync_canonical_snapshot_v1(
  p_user uuid, p_entity_type text, p_entity_id uuid
) returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare v_snapshot jsonb;
begin
  if p_entity_type = 'profile' then
    select to_jsonb(t) - 'user_id' into v_snapshot from public.sync_profiles t where user_id=p_user and id=p_entity_id;
  elsif p_entity_type = 'account' then
    select to_jsonb(t) - 'user_id' into v_snapshot from public.sync_accounts t where user_id=p_user and id=p_entity_id;
  elsif p_entity_type = 'category' then
    select to_jsonb(t) - 'user_id' into v_snapshot from public.sync_categories t where user_id=p_user and id=p_entity_id;
  elsif p_entity_type = 'project' then
    select to_jsonb(t) - 'user_id' into v_snapshot from public.sync_projects t where user_id=p_user and id=p_entity_id;
  elsif p_entity_type = 'budget' then
    select to_jsonb(t) - 'user_id' into v_snapshot from public.sync_budgets t where user_id=p_user and id=p_entity_id;
  elsif p_entity_type = 'transaction' then
    select to_jsonb(t) - 'user_id' into v_snapshot from public.sync_transactions t where user_id=p_user and id=p_entity_id;
  elsif p_entity_type = 'transfer' then
    select to_jsonb(t) - 'user_id' into v_snapshot from public.sync_transfers t where user_id=p_user and id=p_entity_id;
  elsif p_entity_type = 'receipt_attachment' then
    select to_jsonb(t) - 'user_id' into v_snapshot from public.sync_receipt_attachments t where user_id=p_user and id=p_entity_id;
  else
    raise exception using errcode='22023', message='unsupported sync entity';
  end if;
  return v_snapshot;
end;
$$;
revoke all on function public.sync_canonical_snapshot_v1(uuid,text,uuid)
  from public, anon, authenticated;

create or replace function public.sync_complete_change_event_v1()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  new.mutation_id := nullif(pg_catalog.current_setting('keev.sync_mutation_id', true), '')::uuid;
  new.origin_device_id := nullif(pg_catalog.current_setting('keev.sync_device_id', true), '')::uuid;
  new.payload := public.sync_canonical_snapshot_v1(new.user_id,new.entity_type,new.entity_id);
  if new.mutation_id is null or new.origin_device_id is null or new.payload is null then
    raise exception using errcode='23514', message='incomplete sync event';
  end if;
  return new;
end;
$$;
revoke all on function public.sync_complete_change_event_v1()
  from public, anon, authenticated;

create trigger sync_change_log_snapshot_before_insert
before insert on public.sync_change_log
for each row execute function public.sync_complete_change_event_v1();

-- Runtime starts before any production live-sync activation; fail closed if a
-- project contains legacy events that cannot be made exact.
do $$
begin
  if exists (select 1 from public.sync_change_log where payload is null) then
    raise exception 'OWNER ACTION REQUIRED: reset pre-activation sync fixtures before Phase 6B';
  end if;
end $$;

alter table public.sync_change_log
  alter column payload set not null,
  alter column mutation_id set not null,
  alter column origin_device_id set not null;

create unique index sync_change_log_user_mutation
  on public.sync_change_log(user_id, mutation_id);

create or replace function public.sync_apply_mutation_v1(
  p_mutation_id uuid,
  p_device_id uuid,
  p_entity_type text,
  p_entity_id uuid,
  p_operation text,
  p_base_server_version bigint,
  p_payload jsonb
) returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user uuid := auth.uid();
  v_prior public.sync_mutation_receipts%rowtype;
  v_result jsonb;
  v_snapshot jsonb;
  v_profile_id uuid;
  v_profile_version bigint;
  v_profile_revision bigint;
begin
  if v_user is null then return jsonb_build_object('status','REJECTED','reason','AUTH_REQUIRED'); end if;
  if p_mutation_id is null or p_device_id is null or p_entity_id is null or p_payload is null
     or p_entity_type not in ('profile','account','category','transaction','transfer','project','budget','receipt_attachment')
     or p_operation not in ('create','update','delete')
     or p_base_server_version is null or p_base_server_version < 0 then
    return jsonb_build_object('status','REJECTED','reason','VALIDATION_FAILED');
  end if;
  if p_operation='delete' and p_entity_type not in ('transaction','transfer','receipt_attachment') then
    return jsonb_build_object('status','REJECTED','reason','UNSUPPORTED_OPERATION');
  end if;
  if p_entity_type='receipt_attachment' and p_operation='update' then
    return jsonb_build_object('status','REJECTED','reason','UNSUPPORTED_OPERATION');
  end if;

  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(v_user::text || ':mutation:' || p_mutation_id::text,0));
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(v_user::text || ':entity:' || case when p_entity_type='profile' then 'profile-root' else p_entity_type || ':' || p_entity_id::text end,0));

  select * into v_prior from public.sync_mutation_receipts where user_id=v_user and mutation_id=p_mutation_id;
  if found then
    if v_prior.result_json is not null then
      return case when v_prior.outcome='APPLIED'
        then jsonb_set(v_prior.result_json,'{status}','"ALREADY_APPLIED"'::jsonb)
        else v_prior.result_json end;
    end if;
    return jsonb_build_object('status',case when v_prior.outcome='APPLIED' then 'ALREADY_APPLIED' else v_prior.outcome end,
      'server_version',v_prior.resulting_server_version,'server_revision',v_prior.resulting_server_revision);
  end if;

  if p_entity_type='profile' and p_operation='create' then
    select id,server_version,server_revision
      into v_profile_id,v_profile_version,v_profile_revision
      from public.sync_profiles where user_id=v_user for update;
    if found then
      v_snapshot := public.sync_canonical_snapshot_v1(v_user,'profile',v_profile_id);
      v_result := jsonb_build_object('status','CONFLICT','server_version',v_profile_version,
        'server_revision',v_profile_revision,'remote_snapshot',v_snapshot,
        'remote_deleted',coalesce((v_snapshot->>'deleted_at') is not null,false));
      insert into public.sync_mutation_receipts(user_id,mutation_id,device_id,entity_type,entity_id,outcome,
        resulting_server_version,resulting_server_revision,result_json)
      values(v_user,p_mutation_id,p_device_id,p_entity_type,p_entity_id,'CONFLICT',v_profile_version,v_profile_revision,v_result);
      return v_result;
    end if;
  end if;

  perform pg_catalog.set_config('keev.sync_mutation_id',p_mutation_id::text,true);
  perform pg_catalog.set_config('keev.sync_device_id',p_device_id::text,true);
  v_result := public.sync_apply_mutation_v1_unlocked(p_mutation_id,p_device_id,p_entity_type,p_entity_id,p_operation,p_base_server_version,p_payload);

  if v_result->>'status'='CONFLICT' then
    v_snapshot := public.sync_canonical_snapshot_v1(v_user,p_entity_type,p_entity_id);
    v_result := v_result || jsonb_build_object(
      'server_revision',(v_snapshot->>'server_revision')::bigint,
      'remote_snapshot',v_snapshot,
      'remote_deleted',(v_snapshot->>'deleted_at') is not null);
  end if;
  update public.sync_mutation_receipts set result_json=v_result
    where user_id=v_user and mutation_id=p_mutation_id;
  return v_result;
exception
  when not_null_violation or numeric_value_out_of_range or datetime_field_overflow
    or invalid_datetime_format or invalid_text_representation
    or string_data_right_truncation or check_violation or foreign_key_violation then
    return jsonb_build_object('status','REJECTED','reason','VALIDATION_FAILED');
end;
$$;

revoke all on function public.sync_apply_mutation_v1(uuid,uuid,text,uuid,text,bigint,jsonb)
  from public, anon;
grant execute on function public.sync_apply_mutation_v1(uuid,uuid,text,uuid,text,bigint,jsonb)
  to authenticated;

-- Change-log and receipts remain trusted-RPC write-only.
revoke insert, update, delete on public.sync_change_log from authenticated;
revoke all on public.sync_mutation_receipts from authenticated, anon;
