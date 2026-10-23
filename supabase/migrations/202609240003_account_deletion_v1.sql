-- Keep only an unlinked store identity fingerprint to prevent a deleted
-- subscription from being claimed by a different account after Auth cascades.
create table billing_private.deleted_purchase_tombstones (
  platform text not null check (platform in ('apple','google')),
  environment text not null check (environment in ('production','sandbox')),
  identity_hash text not null check (length(identity_hash)=64),
  original_identity text,
  deleted_at timestamptz not null default now(),
  primary key (platform,environment,identity_hash)
);
create index deleted_apple_chain_idx on billing_private.deleted_purchase_tombstones(environment,original_identity)
  where platform='apple' and original_identity is not null;
revoke all on billing_private.deleted_purchase_tombstones from public, anon, authenticated;

create table billing_private.account_deletion_jobs (
  user_id uuid primary key,
  state text not null check (state in ('requested','storageCleared','billingMinimized')),
  updated_at timestamptz not null default now()
);
revoke all on billing_private.account_deletion_jobs from public, anon, authenticated;

-- Supabase JWTs may remain valid until expiry after Auth deletion. Reject
-- Storage uploads from an already deleted/deleting account in that interval.
create function public.account_can_upload_v1()
returns boolean language sql stable security definer set search_path = '' as $$
  select (select auth.uid()) is not null
    and exists (select 1 from auth.users u where u.id=(select auth.uid()))
    and not exists (select 1 from billing_private.account_deletion_jobs j
      where j.user_id=(select auth.uid()));
$$;
revoke all on function public.account_can_upload_v1() from public, anon, authenticated;
grant execute on function public.account_can_upload_v1() to authenticated;
drop policy if exists "ledger_backup_objects_insert_own" on storage.objects;
create policy "ledger_backup_objects_insert_own" on storage.objects for insert to authenticated with check (
  bucket_id='ledger-backups' and (storage.foldername(name))[1]=(select auth.uid())::text
  and public.account_can_upload_v1()
);
drop policy if exists "sync_receipt_objects_insert_own" on storage.objects;
create policy "sync_receipt_objects_insert_own" on storage.objects for insert to authenticated with check (
  bucket_id='ledger-sync-receipts' and (storage.foldername(name))[1]=(select auth.uid())::text
  and public.account_can_upload_v1()
);

create function public.account_deletion_progress_v1(p_user_id uuid,p_state text)
returns text language plpgsql security definer set search_path = '' as $$
declare v_state text;
begin
  if p_user_id is null or p_state not in ('requested','storageCleared','billingMinimized') then
    return 'REJECTED';
  end if;
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_user_id::text,1));
  insert into billing_private.account_deletion_jobs(user_id,state) values(p_user_id,'requested')
  on conflict(user_id) do nothing;
  select state into v_state from billing_private.account_deletion_jobs where user_id=p_user_id for update;
  if p_state='storageCleared' and v_state='requested' then
    update billing_private.account_deletion_jobs set state='storageCleared',updated_at=now() where user_id=p_user_id;
    v_state:='storageCleared';
  elsif p_state='billingMinimized' and v_state in ('storageCleared','billingMinimized') then
    insert into billing_private.deleted_purchase_tombstones(platform,environment,identity_hash,original_identity)
    select platform,environment,identity_hash,original_identity
    from billing_private.store_purchases where user_id=p_user_id
    on conflict(platform,environment,identity_hash) do nothing;
    delete from billing_private.store_purchases where user_id=p_user_id;
    update billing_private.account_deletion_jobs set state='billingMinimized',updated_at=now() where user_id=p_user_id;
    v_state:='billingMinimized';
  end if;
  return v_state;
end $$;
revoke all on function public.account_deletion_progress_v1(uuid,text) from public, anon, authenticated;
grant execute on function public.account_deletion_progress_v1(uuid,text) to service_role;

-- No new purchase may reuse a store identity retained after deletion.
create function billing_private.reject_deleted_purchase_v1()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if exists (select 1 from billing_private.deleted_purchase_tombstones t
     where t.platform=new.platform and t.environment=new.environment and
       (t.identity_hash=new.identity_hash or
        (new.platform='apple' and new.original_identity is not null and t.original_identity=new.original_identity))) then
    raise check_violation using message='deleted purchase identity';
  end if;
  return new;
end $$;
revoke all on function billing_private.reject_deleted_purchase_v1() from public, anon, authenticated;
create trigger reject_deleted_purchase before insert or update on billing_private.store_purchases
for each row execute function billing_private.reject_deleted_purchase_v1();
