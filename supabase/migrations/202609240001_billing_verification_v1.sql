-- Phase 8B-A: server-only purchase identity and account-scoped entitlements.
create schema if not exists billing_private;
revoke all on schema billing_private from public, anon, authenticated;
grant usage on schema billing_private to service_role;

create table billing_private.store_purchases (
  id uuid primary key default gen_random_uuid(),
  platform text not null check (platform in ('apple','google')),
  environment text not null check (environment in ('production','sandbox')),
  identity_hash text not null check (length(identity_hash)=64),
  original_identity text,
  user_id uuid not null references auth.users(id) on delete cascade,
  product_id text not null check (length(product_id)>0),
  state text not null check (state in ('active','gracePeriod','cancelledButActive','billingRetry','onHold','paused','pending','expired','revoked','inactive')),
  valid_from timestamptz,
  valid_until timestamptz,
  acknowledged boolean not null default false,
  acknowledgement_pending boolean not null default false,
  -- Needed for later trusted Play API refresh; never readable by mobile clients.
  purchase_token text,
  last_verified_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(platform,environment,identity_hash),
  check(valid_until is null or valid_from is null or valid_until >= valid_from),
  check(platform = 'google' or purchase_token is null)
);
create index billing_purchases_user_idx on billing_private.store_purchases(user_id,state);
create index billing_purchases_original_idx on billing_private.store_purchases(platform,environment,original_identity) where original_identity is not null;

create table billing_private.verification_events (
  id bigint generated always as identity primary key,
  purchase_id uuid references billing_private.store_purchases(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  event_code text not null,
  created_at timestamptz not null default now()
);
create index billing_events_purchase_idx on billing_private.verification_events(purchase_id,created_at);

create table public.billing_entitlements (
  user_id uuid not null references auth.users(id) on delete cascade,
  environment text not null check (environment in ('production','sandbox')),
  capability text not null check (capability in ('premium','adFree')),
  state text not null check (state in ('active','gracePeriod','cancelledButActive','billingRetry','onHold','paused','pending','expired','revoked','inactive')),
  valid_until timestamptz,
  last_verified_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key(user_id,environment,capability)
);
alter table public.billing_entitlements enable row level security;
revoke all on public.billing_entitlements from public, anon, authenticated;
grant select on public.billing_entitlements to authenticated;
create policy billing_entitlements_own_read on public.billing_entitlements for select to authenticated using (user_id = (select auth.uid()));

create or replace function billing_private.recompute_entitlements_v1(p_user_id uuid,p_environment text)
returns void language plpgsql security definer set search_path = '' as $$
begin
  insert into public.billing_entitlements(user_id,environment,capability,state,valid_until,last_verified_at,updated_at)
  select p_user_id,p_environment, c.capability,
    case when exists (
      select 1 from billing_private.store_purchases p
      where p.user_id=p_user_id and p.state='active'
      and p.valid_until > now() and p.environment = p_environment
    ) then 'active'
    when exists (select 1 from billing_private.store_purchases p where p.user_id=p_user_id
      and p.environment=p_environment and p.state='gracePeriod' and p.valid_until>now()) then 'gracePeriod'
    when exists (select 1 from billing_private.store_purchases p where p.user_id=p_user_id
      and p.environment=p_environment and p.state='cancelledButActive' and p.valid_until>now()) then 'cancelledButActive'
    else coalesce((select case when p.valid_until is not null and p.valid_until<=now() then 'expired' else p.state end
      from billing_private.store_purchases p where p.user_id=p_user_id and p.environment=p_environment
      order by p.last_verified_at desc limit 1),'inactive') end,
    (select max(p.valid_until) from billing_private.store_purchases p
      where p.user_id=p_user_id and p.state in ('active','gracePeriod','cancelledButActive')
      and p.valid_until > now() and p.environment = p_environment),
    coalesce((select max(p.last_verified_at) from billing_private.store_purchases p
      where p.user_id=p_user_id and p.environment=p_environment),now()),now()
  from (values ('premium'),('adFree')) c(capability)
  on conflict(user_id,environment,capability) do update set state=excluded.state,
    valid_until=excluded.valid_until,last_verified_at=excluded.last_verified_at,updated_at=now();
end $$;
revoke all on function billing_private.recompute_entitlements_v1(uuid,text) from public, anon, authenticated;

-- Edge service_role only. All identity fields are store-verified before call.
-- A database transaction/advisory lock makes source binding and capability writes atomic.
create or replace function public.billing_commit_verification_v1(
  p_user_id uuid,p_platform text,p_environment text,p_identity_hash text,
  p_original_identity text,p_product_id text,p_state text,
  p_valid_from timestamptz,p_valid_until timestamptz,p_token text,
  p_acknowledged boolean,p_ack_pending boolean
) returns text language plpgsql security definer set search_path = '' as $$
declare v_existing billing_private.store_purchases%rowtype; v_id uuid;
begin
  if p_user_id is null or p_platform not in ('apple','google') or
     p_environment not in ('production','sandbox') or
     p_state not in ('active','gracePeriod','cancelledButActive','billingRetry','onHold','paused','pending','expired','revoked','inactive') or
     length(p_identity_hash)<>64 or coalesce(p_product_id,'')='' then return 'REJECTED'; end if;
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_platform||':'||p_environment||':'||p_identity_hash,0));
  if p_platform='apple' and p_original_identity is not null then
    perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended('apple-original:'||p_environment||':'||p_original_identity,0));
  end if;
  select * into v_existing from billing_private.store_purchases
    where platform=p_platform and environment=p_environment and identity_hash=p_identity_hash for update;
  if found and v_existing.user_id<>p_user_id then return 'ACCOUNT_MISMATCH'; end if;
  if p_platform='apple' and p_original_identity is not null and exists (
    select 1 from billing_private.store_purchases p where p.platform='apple'
    and p.environment=p_environment and p.original_identity=p_original_identity and p.user_id<>p_user_id
  ) then return 'ACCOUNT_MISMATCH'; end if;
  if found and v_existing.original_identity is not null and p_original_identity is not null
     and v_existing.original_identity<>p_original_identity then return 'REJECTED'; end if;
  insert into billing_private.store_purchases(platform,environment,identity_hash,original_identity,user_id,product_id,state,valid_from,valid_until,purchase_token,acknowledged,acknowledgement_pending)
  values(p_platform,p_environment,p_identity_hash,p_original_identity,p_user_id,p_product_id,p_state,p_valid_from,p_valid_until,p_token,p_acknowledged,p_ack_pending)
  on conflict(platform,environment,identity_hash) do update set
    original_identity=coalesce(billing_private.store_purchases.original_identity,excluded.original_identity),
    product_id=excluded.product_id,state=excluded.state,valid_from=excluded.valid_from,
    valid_until=excluded.valid_until,purchase_token=coalesce(billing_private.store_purchases.purchase_token,excluded.purchase_token),
    acknowledged=billing_private.store_purchases.acknowledged or excluded.acknowledged,
    acknowledgement_pending=excluded.acknowledgement_pending and not billing_private.store_purchases.acknowledged,
    last_verified_at=now(),updated_at=now()
  returning id into v_id;
  insert into billing_private.verification_events(purchase_id,user_id,event_code) values(v_id,p_user_id,'verified_'||p_state);
  perform billing_private.recompute_entitlements_v1(p_user_id,p_environment);
  return 'COMMITTED';
end $$;
revoke all on function public.billing_commit_verification_v1(uuid,text,text,text,text,text,text,timestamptz,timestamptz,text,boolean,boolean) from public, anon, authenticated;
grant execute on function public.billing_commit_verification_v1(uuid,text,text,text,text,text,text,timestamptz,timestamptz,text,boolean,boolean) to service_role;

create or replace function public.billing_mark_acknowledged_v1(p_platform text,p_environment text,p_identity_hash text)
returns boolean language plpgsql security definer set search_path = '' as $$
declare v_id uuid; v_user uuid;
begin
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_platform||':'||p_environment||':'||p_identity_hash,0));
  update billing_private.store_purchases set acknowledged=true,acknowledgement_pending=false,updated_at=now()
  where platform=p_platform and environment=p_environment and identity_hash=p_identity_hash and state in ('active','gracePeriod','cancelledButActive')
  returning id,user_id into v_id,v_user;
  if v_id is null then return false; end if;
  insert into billing_private.verification_events(purchase_id,user_id,event_code) values(v_id,v_user,'acknowledged');
  return true;
end $$;
revoke all on function public.billing_mark_acknowledged_v1(text,text,text) from public, anon, authenticated;
grant execute on function public.billing_mark_acknowledged_v1(text,text,text) to service_role;

create or replace function public.billing_refresh_entitlements_v1(p_user_id uuid,p_environment text)
returns table(capability text,state text,valid_until timestamptz,verified_at timestamptz)
language plpgsql security definer set search_path = '' as $$
begin
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_user_id::text,1));
  perform billing_private.recompute_entitlements_v1(p_user_id,p_environment);
  return query select e.capability,e.state,e.valid_until,e.last_verified_at
    from public.billing_entitlements e where e.user_id=p_user_id and e.environment=p_environment;
end $$;
revoke all on function public.billing_refresh_entitlements_v1(uuid,text) from public, anon, authenticated;
grant execute on function public.billing_refresh_entitlements_v1(uuid,text) to service_role;
