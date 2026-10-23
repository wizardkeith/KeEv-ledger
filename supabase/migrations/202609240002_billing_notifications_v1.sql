-- Phase 8B-B: private provider events, bounded recovery and observed-state ordering.
create table billing_private.provider_events (
  id bigint generated always as identity primary key,
  provider text not null check(provider in ('apple','google')),
  environment text not null check(environment in ('production','sandbox')),
  provider_event_id text not null check(length(provider_event_id) between 1 and 256),
  event_type text not null check(length(event_type) between 1 and 96),
  provider_event_time timestamptz,
  source_identity_hash text check(source_identity_hash is null or length(source_identity_hash)=64),
  processing_state text not null default 'received' check(processing_state in ('received','processing','processed','retryableFailure','permanentIgnored')),
  attempt_count integer not null default 0 check(attempt_count >= 0),
  claim_id uuid,
  lease_until timestamptz,
  last_error_code text check(last_error_code is null or length(last_error_code)<=64),
  received_at timestamptz not null default now(),
  processed_at timestamptz,
  unique(provider,environment,provider_event_id)
);
revoke all on billing_private.provider_events from public, anon, authenticated;
grant select,insert,update on billing_private.provider_events to service_role;
grant usage,select on sequence billing_private.provider_events_id_seq to service_role;
alter table billing_private.store_purchases
  add column source_observed_at timestamptz not null default '-infinity'::timestamptz,
  add column next_reconcile_at timestamptz not null default now();
create index billing_reconcile_due_idx on billing_private.store_purchases(environment,next_reconcile_at);

-- The old service-role writer lacks observation ordering; retire its grant.
revoke execute on function public.billing_commit_verification_v1(uuid,text,text,text,text,text,text,timestamptz,timestamptz,text,boolean,boolean) from service_role;
create function public.billing_commit_verification_v2(
  p_user_id uuid,p_platform text,p_environment text,p_identity_hash text,
  p_original_identity text,p_product_id text,p_state text,
  p_valid_from timestamptz,p_valid_until timestamptz,p_token text,
  p_acknowledged boolean,p_ack_pending boolean,p_observed_at timestamptz
) returns text language plpgsql security definer set search_path = '' as $$
declare v_existing billing_private.store_purchases%rowtype; v_id uuid;
begin
  if p_user_id is null or p_platform not in ('apple','google') or
     p_environment not in ('production','sandbox') or
     p_state not in ('active','gracePeriod','cancelledButActive','billingRetry','onHold','paused','pending','expired','revoked','inactive') or
     length(p_identity_hash)<>64 or coalesce(p_product_id,'')='' or p_observed_at is null or
     p_observed_at > now()+interval '1 minute' then return 'REJECTED'; end if;
  -- Serialize capability recomputation across Apple and Play sources for one user.
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_user_id::text,1));
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
  if found and v_existing.source_observed_at >= p_observed_at then return 'STALE'; end if;
  insert into billing_private.store_purchases(platform,environment,identity_hash,original_identity,user_id,product_id,state,
    valid_from,valid_until,purchase_token,acknowledged,acknowledgement_pending,source_observed_at,next_reconcile_at)
  values(p_platform,p_environment,p_identity_hash,p_original_identity,p_user_id,p_product_id,p_state,
    p_valid_from,p_valid_until,p_token,p_acknowledged,p_ack_pending,p_observed_at,
    now()+case when p_ack_pending then interval '15 minutes' else interval '6 hours' end)
  on conflict(platform,environment,identity_hash) do update set
    original_identity=coalesce(billing_private.store_purchases.original_identity,excluded.original_identity),
    product_id=excluded.product_id,state=excluded.state,valid_from=excluded.valid_from,
    valid_until=excluded.valid_until,purchase_token=coalesce(billing_private.store_purchases.purchase_token,excluded.purchase_token),
    acknowledged=billing_private.store_purchases.acknowledged or excluded.acknowledged,
    acknowledgement_pending=excluded.acknowledgement_pending and not billing_private.store_purchases.acknowledged,
    source_observed_at=excluded.source_observed_at,next_reconcile_at=excluded.next_reconcile_at,
    last_verified_at=now(),updated_at=now()
  returning id into v_id;
  insert into billing_private.verification_events(purchase_id,user_id,event_code) values(v_id,p_user_id,'verified_'||p_state);
  perform billing_private.recompute_entitlements_v1(p_user_id,p_environment);
  return 'COMMITTED';
end $$;
revoke all on function public.billing_commit_verification_v2(uuid,text,text,text,text,text,text,timestamptz,timestamptz,text,boolean,boolean,timestamptz) from public, anon, authenticated;
grant execute on function public.billing_commit_verification_v2(uuid,text,text,text,text,text,text,timestamptz,timestamptz,text,boolean,boolean,timestamptz) to service_role;

create function public.billing_begin_provider_event_v1(
  p_provider text,p_environment text,p_event_id text,p_event_type text,p_event_time timestamptz,p_identity_hash text
) returns jsonb language plpgsql security definer set search_path = '' as $$
declare v billing_private.provider_events%rowtype; v_claim uuid;
begin
  if p_provider not in ('apple','google') or p_environment not in ('production','sandbox') or
     length(p_event_id) not between 1 and 256 or length(p_event_type) not between 1 and 96 or
     (p_identity_hash is not null and length(p_identity_hash)<>64) then return pg_catalog.jsonb_build_object('state','REJECTED'); end if;
  insert into billing_private.provider_events(provider,environment,provider_event_id,event_type,provider_event_time,source_identity_hash)
  values(p_provider,p_environment,p_event_id,p_event_type,p_event_time,p_identity_hash)
  on conflict(provider,environment,provider_event_id) do nothing;
  select * into v from billing_private.provider_events
    where provider=p_provider and environment=p_environment and provider_event_id=p_event_id for update;
  if v.processing_state in ('processed','permanentIgnored') then return pg_catalog.jsonb_build_object('state','DONE'); end if;
  if v.processing_state='processing' and v.lease_until>now() then return pg_catalog.jsonb_build_object('state','BUSY'); end if;
  v_claim:=gen_random_uuid();
  update billing_private.provider_events set processing_state='processing',claim_id=v_claim,
    lease_until=now()+interval '2 minutes',attempt_count=attempt_count+1,last_error_code=null
  where id=v.id;
  return pg_catalog.jsonb_build_object('state','CLAIMED','claimId',v_claim);
end $$;
revoke all on function public.billing_begin_provider_event_v1(text,text,text,text,timestamptz,text) from public, anon, authenticated;
grant execute on function public.billing_begin_provider_event_v1(text,text,text,text,timestamptz,text) to service_role;

create function public.billing_finish_provider_event_v1(
  p_provider text,p_environment text,p_event_id text,p_claim_id uuid,p_state text,p_error_code text
) returns boolean language plpgsql security definer set search_path = '' as $$
begin
  if p_state not in ('processed','retryableFailure','permanentIgnored') or length(coalesce(p_error_code,''))>64 then return false; end if;
  update billing_private.provider_events set processing_state=p_state,claim_id=null,lease_until=null,
    last_error_code=p_error_code,processed_at=case when p_state='retryableFailure' then null else now() end
  where provider=p_provider and environment=p_environment and provider_event_id=p_event_id
    and claim_id=p_claim_id and processing_state='processing';
  return found;
end $$;
revoke all on function public.billing_finish_provider_event_v1(text,text,text,uuid,text,text) from public, anon, authenticated;
grant execute on function public.billing_finish_provider_event_v1(text,text,text,uuid,text,text) to service_role;

create function public.billing_lookup_source_v1(p_platform text,p_environment text,p_identity_hash text)
returns table(user_id uuid,product_id text,purchase_token text,original_identity text,state text,acknowledgement_pending boolean)
language sql security definer set search_path = '' as $$
  select p.user_id,p.product_id,p.purchase_token,p.original_identity,p.state,p.acknowledgement_pending
  from billing_private.store_purchases p
  where p.platform=p_platform and p.environment=p_environment and p.identity_hash=p_identity_hash;
$$;
revoke all on function public.billing_lookup_source_v1(text,text,text) from public, anon, authenticated;
grant execute on function public.billing_lookup_source_v1(text,text,text) to service_role;

create function public.billing_account_exists_v1(p_user_id uuid) returns boolean
language sql security definer set search_path = '' as $$
  select exists(select 1 from auth.users u where u.id=p_user_id);
$$;
revoke all on function public.billing_account_exists_v1(uuid) from public, anon, authenticated;
grant execute on function public.billing_account_exists_v1(uuid) to service_role;

-- Claim a bounded page; a crashed run becomes eligible again after 20 minutes.
create function public.billing_claim_reconcile_v1(p_environment text,p_limit integer)
returns table(user_id uuid,platform text,environment text,identity_hash text,original_identity text,purchase_token text)
language sql security definer set search_path = '' as $$
  with due as (
    select p.id from billing_private.store_purchases p
    where p.environment=p_environment and p.next_reconcile_at<=now() and
      (p.state in ('active','gracePeriod','cancelledButActive','billingRetry','onHold','paused','pending') or
       p.acknowledgement_pending or p.last_verified_at>now()-interval '30 days')
    order by p.next_reconcile_at,p.id limit least(greatest(coalesce(p_limit,1),1),25) for update skip locked
  )
  update billing_private.store_purchases p set next_reconcile_at=now()+interval '20 minutes'
  from due where p.id=due.id
  returning p.user_id,p.platform,p.environment,p.identity_hash,p.original_identity,p.purchase_token;
$$;
revoke all on function public.billing_claim_reconcile_v1(text,integer) from public, anon, authenticated;
grant execute on function public.billing_claim_reconcile_v1(text,integer) to service_role;
