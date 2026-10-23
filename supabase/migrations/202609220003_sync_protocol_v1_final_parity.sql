-- Phase 6A final parity gate. Apply after 202609220002.

-- Tombstoned receipts no longer reserve their former display position. The
-- storage-path uniqueness from the base migration remains unchanged.
alter table public.sync_receipt_attachments
  drop constraint if exists sync_receipts_transaction_position_unique;

create unique index if not exists sync_receipts_active_transaction_position_unique
  on public.sync_receipt_attachments(user_id, transaction_id, position)
  where deleted_at is null;

alter table public.sync_receipt_attachments
  add constraint sync_receipts_storage_path_length
  check (length(storage_path) between 1 and 160);

alter table public.sync_accounts
  add constraint sync_accounts_opening_minor_units_supported
  check (opening_minor_units >= -9223372036854775807);

-- Repair only timestamp ordering from any pre-activation fixture before the
-- permanent deleted_at checks are validated.
update public.sync_profiles set deleted_at = created_at
  where deleted_at is not null and deleted_at < created_at;
update public.sync_accounts set deleted_at = created_at
  where deleted_at is not null and deleted_at < created_at;
update public.sync_categories set deleted_at = created_at
  where deleted_at is not null and deleted_at < created_at;
update public.sync_projects set deleted_at = created_at
  where deleted_at is not null and deleted_at < created_at;
update public.sync_budgets set deleted_at = created_at
  where deleted_at is not null and deleted_at < created_at;
update public.sync_transactions set deleted_at = created_at
  where deleted_at is not null and deleted_at < created_at;
update public.sync_transfers set deleted_at = created_at
  where deleted_at is not null and deleted_at < created_at;
update public.sync_receipt_attachments set deleted_at = created_at
  where deleted_at is not null and deleted_at < created_at;

alter table public.sync_profiles add constraint sync_profiles_tombstone_order
  check (deleted_at is null or deleted_at >= created_at);
alter table public.sync_accounts add constraint sync_accounts_tombstone_order
  check (deleted_at is null or deleted_at >= created_at);
alter table public.sync_categories add constraint sync_categories_tombstone_order
  check (deleted_at is null or deleted_at >= created_at);
alter table public.sync_projects add constraint sync_projects_tombstone_order
  check (deleted_at is null or deleted_at >= created_at);
alter table public.sync_budgets add constraint sync_budgets_tombstone_order
  check (deleted_at is null or deleted_at >= created_at);
alter table public.sync_transactions add constraint sync_transactions_tombstone_order
  check (deleted_at is null or deleted_at >= created_at);
alter table public.sync_transfers add constraint sync_transfers_tombstone_order
  check (deleted_at is null or deleted_at >= created_at);
alter table public.sync_receipt_attachments add constraint sync_receipts_tombstone_order
  check (deleted_at is null or deleted_at >= created_at);

-- Existing triggers from 202609220002 use this function. Replacing it extends
-- the same server-side guard to tombstones without changing RPC privileges.
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
  if new.deleted_at is not null and new.deleted_at < new.created_at then
    new.deleted_at := new.created_at;
  end if;
  return new;
end;
$$;

revoke all on function public.sync_enforce_timestamp_order_v1()
  from public, anon, authenticated;
