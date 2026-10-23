-- Phase 6A Fix Gate: Protocol v1 schema parity and mutation hardening.
-- Apply after 202609220001_sync_protocol_v1.sql.

alter table public.sync_profiles
  add constraint sync_profiles_one_ledger_per_user unique (user_id);

alter table public.sync_receipt_attachments
  add constraint sync_receipts_transaction_position_unique
  unique (user_id, transaction_id, position);

alter table public.sync_transfers
  add constraint sync_transfers_same_currency_amount_equal check (
    source_currency_code <> destination_currency_code
    or source_minor_units = destination_minor_units
  );

-- Repair any pre-activation fixture written by the base migration, then make
-- the local createdAt <= updatedAt invariant permanent for canonical rows.
update public.sync_profiles set updated_at = created_at where updated_at < created_at;
update public.sync_accounts set updated_at = created_at where updated_at < created_at;
update public.sync_categories set updated_at = created_at where updated_at < created_at;
update public.sync_projects set updated_at = created_at where updated_at < created_at;
update public.sync_budgets set updated_at = created_at where updated_at < created_at;
update public.sync_transactions set updated_at = created_at where updated_at < created_at;
update public.sync_transfers set updated_at = created_at where updated_at < created_at;
update public.sync_receipt_attachments set updated_at = created_at where updated_at < created_at;

alter table public.sync_profiles add constraint sync_profiles_timestamp_order check (updated_at >= created_at);
alter table public.sync_accounts add constraint sync_accounts_timestamp_order check (updated_at >= created_at);
alter table public.sync_categories add constraint sync_categories_timestamp_order check (updated_at >= created_at);
alter table public.sync_projects add constraint sync_projects_timestamp_order check (updated_at >= created_at);
alter table public.sync_budgets add constraint sync_budgets_timestamp_order check (updated_at >= created_at);
alter table public.sync_transactions add constraint sync_transactions_timestamp_order check (updated_at >= created_at);
alter table public.sync_transfers add constraint sync_transfers_timestamp_order check (updated_at >= created_at);
alter table public.sync_receipt_attachments add constraint sync_receipts_timestamp_order check (updated_at >= created_at);

create or replace function public.sync_enforce_timestamp_order_v1()
returns trigger
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if new.updated_at < new.created_at then
    new.updated_at := new.created_at;
  end if;
  return new;
end;
$$;

revoke all on function public.sync_enforce_timestamp_order_v1() from public, anon, authenticated;

create trigger sync_profiles_timestamp_order_before_write before insert or update on public.sync_profiles
  for each row execute function public.sync_enforce_timestamp_order_v1();
create trigger sync_accounts_timestamp_order_before_write before insert or update on public.sync_accounts
  for each row execute function public.sync_enforce_timestamp_order_v1();
create trigger sync_categories_timestamp_order_before_write before insert or update on public.sync_categories
  for each row execute function public.sync_enforce_timestamp_order_v1();
create trigger sync_projects_timestamp_order_before_write before insert or update on public.sync_projects
  for each row execute function public.sync_enforce_timestamp_order_v1();
create trigger sync_budgets_timestamp_order_before_write before insert or update on public.sync_budgets
  for each row execute function public.sync_enforce_timestamp_order_v1();
create trigger sync_transactions_timestamp_order_before_write before insert or update on public.sync_transactions
  for each row execute function public.sync_enforce_timestamp_order_v1();
create trigger sync_transfers_timestamp_order_before_write before insert or update on public.sync_transfers
  for each row execute function public.sync_enforce_timestamp_order_v1();
create trigger sync_receipts_timestamp_order_before_write before insert or update on public.sync_receipt_attachments
  for each row execute function public.sync_enforce_timestamp_order_v1();

-- Preserve the Phase 6A implementation as an inaccessible inner function.
-- The public contract below serializes by mutation id and entity before the
-- inner implementation re-checks both its receipt and canonical row.
alter function public.sync_apply_mutation_v1(uuid,uuid,text,uuid,text,bigint,jsonb)
  rename to sync_apply_mutation_v1_unlocked;
revoke all on function public.sync_apply_mutation_v1_unlocked(uuid,uuid,text,uuid,text,bigint,jsonb)
  from public, anon, authenticated;

create function public.sync_apply_mutation_v1(
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
  v_profile_version bigint;
  v_profile_revision bigint;
begin
  if v_user is null then
    return jsonb_build_object('status','REJECTED','reason','AUTH_REQUIRED');
  end if;
  if p_mutation_id is null or p_device_id is null or p_entity_id is null
     or p_payload is null
     or p_entity_type not in ('profile','account','category','transaction','transfer','project','budget','receipt_attachment')
     or p_operation not in ('create','update','delete')
     or p_base_server_version is null or p_base_server_version < 0 then
    return jsonb_build_object('status','REJECTED','reason','VALIDATION_FAILED');
  end if;

  -- The first lock makes a mutation-id retry single-effect even if a caller
  -- accidentally changes entity arguments. The second prevents concurrent
  -- creates/updates for one canonical entity from observing stale absence.
  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(v_user::text || ':mutation:' || p_mutation_id::text, 0)
  );
  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(
      v_user::text || ':entity:' ||
      case when p_entity_type = 'profile' then 'profile-root' else p_entity_type || ':' || p_entity_id::text end,
      0
    )
  );

  -- Required post-lock idempotency recheck.
  select * into v_prior from public.sync_mutation_receipts
    where user_id = v_user and mutation_id = p_mutation_id;
  if found then
    return jsonb_build_object(
      'status', case when v_prior.outcome = 'APPLIED' then 'ALREADY_APPLIED' else v_prior.outcome end,
      'server_version', v_prior.resulting_server_version,
      'server_revision', v_prior.resulting_server_revision
    );
  end if;

  -- Protocol v1 permits at most one profile root for an authenticated user.
  if p_entity_type = 'profile' and p_operation = 'create' then
    select server_version, server_revision
      into v_profile_version, v_profile_revision
      from public.sync_profiles
      where user_id = v_user
      for update;
    if found then
      insert into public.sync_mutation_receipts(
        user_id, mutation_id, device_id, entity_type, entity_id, outcome,
        resulting_server_version, resulting_server_revision
      ) values (
        v_user, p_mutation_id, p_device_id, p_entity_type, p_entity_id,
        'CONFLICT', v_profile_version, v_profile_revision
      );
      return jsonb_build_object(
        'status','CONFLICT',
        'server_version',v_profile_version,
        'server_revision',v_profile_revision
      );
    end if;
  end if;

  return public.sync_apply_mutation_v1_unlocked(
    p_mutation_id, p_device_id, p_entity_type, p_entity_id, p_operation,
    p_base_server_version, p_payload
  );
exception
  when not_null_violation
    or numeric_value_out_of_range
    or datetime_field_overflow
    or invalid_datetime_format
    or invalid_text_representation
    or string_data_right_truncation
    or check_violation
    or foreign_key_violation then
    return jsonb_build_object('status','REJECTED','reason','VALIDATION_FAILED');
end;
$$;

revoke all on function public.sync_apply_mutation_v1(uuid,uuid,text,uuid,text,bigint,jsonb)
  from public, anon;
grant execute on function public.sync_apply_mutation_v1(uuid,uuid,text,uuid,text,bigint,jsonb)
  to authenticated;
