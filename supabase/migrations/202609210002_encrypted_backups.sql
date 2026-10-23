-- Phase 5C: immutable encrypted backup objects and minimal metadata.
-- Apply independently to development, staging, and production projects.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'ledger-backups',
  'ledger-backups',
  false,
  67108864,
  array['application/octet-stream']
)
on conflict (id) do update set
  public = false,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

create table if not exists public.ledger_backups (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  storage_path text not null unique,
  created_at timestamptz not null default now(),
  encrypted_size_bytes bigint not null check (encrypted_size_bytes between 1 and 67108864),
  format_version integer not null check (format_version = 1),
  encrypted_sha256 text not null check (encrypted_sha256 ~ '^[0-9a-f]{64}$'),
  app_version text null
);

create index if not exists ledger_backups_user_created
  on public.ledger_backups (user_id, created_at desc);

alter table public.ledger_backups enable row level security;

revoke all on table public.ledger_backups from public, anon, authenticated;
grant select, insert, delete on table public.ledger_backups to authenticated;

create policy "ledger_backups_select_own" on public.ledger_backups
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "ledger_backups_insert_own" on public.ledger_backups
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "ledger_backups_delete_own" on public.ledger_backups
  for delete to authenticated using ((select auth.uid()) = user_id);

create policy "ledger_backup_objects_select_own" on storage.objects
  for select to authenticated using (
    bucket_id = 'ledger-backups'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
create policy "ledger_backup_objects_insert_own" on storage.objects
  for insert to authenticated with check (
    bucket_id = 'ledger-backups'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
create policy "ledger_backup_objects_delete_own" on storage.objects
  for delete to authenticated using (
    bucket_id = 'ledger-backups'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
