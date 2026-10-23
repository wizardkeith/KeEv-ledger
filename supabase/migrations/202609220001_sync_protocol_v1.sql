-- Phase 6A: live-sync protocol v1 foundation. This is separate from encrypted backups.
-- KeEv Global Services Limited: Hong Kong. Preferred project region: Singapore.

create sequence if not exists public.sync_server_revision_seq as bigint;
revoke all on sequence public.sync_server_revision_seq from public, anon, authenticated;

create table if not exists public.sync_profiles (
  user_id uuid not null references auth.users(id) on delete cascade,
  id uuid not null,
  base_currency_code text not null check (base_currency_code in ('HKD','USD','EUR','GBP','JPY','THB','CNY')),
  server_version bigint not null check (server_version >= 1),
  server_revision bigint not null unique check (server_revision > 0),
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  primary key (user_id, id)
);

create table if not exists public.sync_accounts (
  user_id uuid not null references auth.users(id) on delete cascade,
  id uuid not null,
  profile_id uuid not null,
  name text not null check (length(trim(name)) between 1 and 120),
  kind text not null check (kind in ('cash','bank','creditCard','eWallet','other')),
  currency_code text not null check (currency_code in ('HKD','USD','EUR','GBP','JPY','THB','CNY')),
  opening_minor_units bigint not null,
  opening_date date not null,
  is_archived boolean not null default false,
  server_version bigint not null check (server_version >= 1),
  server_revision bigint not null unique check (server_revision > 0),
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  primary key (user_id, id),
  foreign key (user_id, profile_id) references public.sync_profiles(user_id, id)
);

create table if not exists public.sync_categories (
  user_id uuid not null references auth.users(id) on delete cascade,
  id uuid not null,
  profile_id uuid not null,
  name text not null check (length(trim(name)) between 1 and 120),
  kind text not null check (kind in ('income','expense')),
  is_archived boolean not null default false,
  server_version bigint not null check (server_version >= 1),
  server_revision bigint not null unique check (server_revision > 0),
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  primary key (user_id, id),
  foreign key (user_id, profile_id) references public.sync_profiles(user_id, id)
);

create table if not exists public.sync_projects (
  user_id uuid not null references auth.users(id) on delete cascade,
  id uuid not null,
  profile_id uuid not null,
  name text not null check (length(trim(name)) between 1 and 120),
  description text check (description is null or length(description) <= 500),
  is_archived boolean not null default false,
  server_version bigint not null check (server_version >= 1),
  server_revision bigint not null unique check (server_revision > 0),
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  primary key (user_id, id),
  foreign key (user_id, profile_id) references public.sync_profiles(user_id, id)
);

create table if not exists public.sync_budgets (
  user_id uuid not null references auth.users(id) on delete cascade,
  id uuid not null,
  profile_id uuid not null,
  name text not null check (length(trim(name)) between 1 and 120),
  amount_minor_units bigint not null check (amount_minor_units >= 0),
  currency_code text not null check (currency_code in ('HKD','USD','EUR','GBP','JPY','THB','CNY')),
  month text not null check (month ~ '^\d{4}-\d{2}$'),
  category_id uuid,
  warning_threshold_percent integer not null check (warning_threshold_percent between 1 and 100),
  is_archived boolean not null default false,
  server_version bigint not null check (server_version >= 1),
  server_revision bigint not null unique check (server_revision > 0),
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  primary key (user_id, id),
  foreign key (user_id, profile_id) references public.sync_profiles(user_id, id),
  foreign key (user_id, category_id) references public.sync_categories(user_id, id)
);

create table if not exists public.sync_transactions (
  user_id uuid not null references auth.users(id) on delete cascade,
  id uuid not null,
  profile_id uuid not null,
  account_id uuid not null,
  category_id uuid not null,
  project_id uuid,
  kind text not null check (kind in ('income','expense')),
  amount_minor_units bigint not null check (amount_minor_units > 0),
  currency_code text not null check (currency_code in ('HKD','USD','EUR','GBP','JPY','THB','CNY')),
  business_date date not null,
  note text,
  server_version bigint not null check (server_version >= 1),
  server_revision bigint not null unique check (server_revision > 0),
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  primary key (user_id, id),
  foreign key (user_id, profile_id) references public.sync_profiles(user_id, id),
  foreign key (user_id, account_id) references public.sync_accounts(user_id, id),
  foreign key (user_id, category_id) references public.sync_categories(user_id, id),
  foreign key (user_id, project_id) references public.sync_projects(user_id, id)
);

create table if not exists public.sync_transfers (
  user_id uuid not null references auth.users(id) on delete cascade,
  id uuid not null,
  profile_id uuid not null,
  source_account_id uuid not null,
  destination_account_id uuid not null check (destination_account_id <> source_account_id),
  source_minor_units bigint not null check (source_minor_units > 0),
  source_currency_code text not null check (source_currency_code in ('HKD','USD','EUR','GBP','JPY','THB','CNY')),
  destination_minor_units bigint not null check (destination_minor_units > 0),
  destination_currency_code text not null check (destination_currency_code in ('HKD','USD','EUR','GBP','JPY','THB','CNY')),
  business_date date not null,
  note text,
  server_version bigint not null check (server_version >= 1),
  server_revision bigint not null unique check (server_revision > 0),
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  primary key (user_id, id),
  foreign key (user_id, profile_id) references public.sync_profiles(user_id, id),
  foreign key (user_id, source_account_id) references public.sync_accounts(user_id, id),
  foreign key (user_id, destination_account_id) references public.sync_accounts(user_id, id)
);

create table if not exists public.sync_receipt_attachments (
  user_id uuid not null references auth.users(id) on delete cascade,
  id uuid not null,
  profile_id uuid not null,
  transaction_id uuid not null,
  storage_path text not null,
  mime_type text not null check (mime_type = 'image/jpeg'),
  byte_size bigint not null check (byte_size between 1 and 10485760),
  sha256_hex text not null check (sha256_hex ~ '^[0-9a-f]{64}$'),
  position integer not null check (position between 0 and 4),
  server_version bigint not null check (server_version >= 1),
  server_revision bigint not null unique check (server_revision > 0),
  created_at timestamptz not null,
  updated_at timestamptz not null,
  deleted_at timestamptz,
  primary key (user_id, id),
  unique (user_id, storage_path),
  foreign key (user_id, profile_id) references public.sync_profiles(user_id, id),
  foreign key (user_id, transaction_id) references public.sync_transactions(user_id, id)
);

create table if not exists public.sync_change_log (
  sequence bigint primary key check (sequence > 0),
  user_id uuid not null references auth.users(id) on delete cascade,
  entity_type text not null check (entity_type in ('profile','account','category','transaction','transfer','project','budget','receipt_attachment')),
  entity_id uuid not null,
  server_version bigint not null check (server_version >= 1),
  operation text not null check (operation in ('upsert','delete')),
  changed_at timestamptz not null default now()
);

create table if not exists public.sync_mutation_receipts (
  user_id uuid not null references auth.users(id) on delete cascade,
  mutation_id uuid not null,
  device_id uuid not null,
  entity_type text not null,
  entity_id uuid not null,
  outcome text not null check (outcome in ('APPLIED','CONFLICT','REJECTED')),
  resulting_server_version bigint,
  resulting_server_revision bigint,
  applied_at timestamptz not null default now(),
  primary key (user_id, mutation_id)
);

create index if not exists sync_change_log_user_sequence on public.sync_change_log(user_id, sequence);
create index if not exists sync_mutation_user_id on public.sync_mutation_receipts(user_id, mutation_id);
create index if not exists sync_accounts_user_revision on public.sync_accounts(user_id, server_revision);
create index if not exists sync_categories_user_revision on public.sync_categories(user_id, server_revision);
create index if not exists sync_projects_user_revision on public.sync_projects(user_id, server_revision);
create index if not exists sync_budgets_user_revision on public.sync_budgets(user_id, server_revision);
create index if not exists sync_transactions_user_revision on public.sync_transactions(user_id, server_revision);
create index if not exists sync_transfers_user_revision on public.sync_transfers(user_id, server_revision);
create index if not exists sync_receipts_user_revision on public.sync_receipt_attachments(user_id, server_revision);

do $$
declare t text;
begin
  foreach t in array array['sync_profiles','sync_accounts','sync_categories','sync_projects','sync_budgets','sync_transactions','sync_transfers','sync_receipt_attachments','sync_change_log','sync_mutation_receipts'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('revoke all on table public.%I from public, anon, authenticated', t);
  end loop;
end $$;

grant select on table public.sync_profiles, public.sync_accounts, public.sync_categories,
  public.sync_projects, public.sync_budgets, public.sync_transactions,
  public.sync_transfers, public.sync_receipt_attachments, public.sync_change_log
  to authenticated;

create policy "sync_profiles_select_own" on public.sync_profiles for select to authenticated using ((select auth.uid()) = user_id);
create policy "sync_accounts_select_own" on public.sync_accounts for select to authenticated using ((select auth.uid()) = user_id);
create policy "sync_categories_select_own" on public.sync_categories for select to authenticated using ((select auth.uid()) = user_id);
create policy "sync_projects_select_own" on public.sync_projects for select to authenticated using ((select auth.uid()) = user_id);
create policy "sync_budgets_select_own" on public.sync_budgets for select to authenticated using ((select auth.uid()) = user_id);
create policy "sync_transactions_select_own" on public.sync_transactions for select to authenticated using ((select auth.uid()) = user_id);
create policy "sync_transfers_select_own" on public.sync_transfers for select to authenticated using ((select auth.uid()) = user_id);
create policy "sync_receipts_select_own" on public.sync_receipt_attachments for select to authenticated using ((select auth.uid()) = user_id);
create policy "sync_change_log_select_own" on public.sync_change_log for select to authenticated using ((select auth.uid()) = user_id);

-- Security-definer is required because mobile roles deliberately have no direct
-- canonical write grants. All table names and branches are fixed and allow-listed.
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
  v_current bigint;
  v_revision bigint;
  v_version bigint;
  v_now timestamptz := now();
begin
  if v_user is null then return jsonb_build_object('status','REJECTED','reason','AUTH_REQUIRED'); end if;
  select * into v_prior from public.sync_mutation_receipts
    where user_id = v_user and mutation_id = p_mutation_id;
  if found then
    return jsonb_build_object(
      'status', case when v_prior.outcome = 'APPLIED' then 'ALREADY_APPLIED' else v_prior.outcome end,
      'server_version', v_prior.resulting_server_version,
      'server_revision', v_prior.resulting_server_revision
    );
  end if;
  if p_entity_type not in ('profile','account','category','transaction','transfer','project','budget','receipt_attachment')
     or p_operation not in ('create','update','delete')
     or p_base_server_version < 0 then
    return jsonb_build_object('status','REJECTED','reason','INVALID_REQUEST');
  end if;

  if p_entity_type = 'profile' then select server_version into v_current from public.sync_profiles where user_id=v_user and id=p_entity_id for update;
  elsif p_entity_type = 'account' then select server_version into v_current from public.sync_accounts where user_id=v_user and id=p_entity_id for update;
  elsif p_entity_type = 'category' then select server_version into v_current from public.sync_categories where user_id=v_user and id=p_entity_id for update;
  elsif p_entity_type = 'project' then select server_version into v_current from public.sync_projects where user_id=v_user and id=p_entity_id for update;
  elsif p_entity_type = 'budget' then select server_version into v_current from public.sync_budgets where user_id=v_user and id=p_entity_id for update;
  elsif p_entity_type = 'transaction' then select server_version into v_current from public.sync_transactions where user_id=v_user and id=p_entity_id for update;
  elsif p_entity_type = 'transfer' then select server_version into v_current from public.sync_transfers where user_id=v_user and id=p_entity_id for update;
  else select server_version into v_current from public.sync_receipt_attachments where user_id=v_user and id=p_entity_id for update;
  end if;

  if (p_operation = 'create' and v_current is not null) or
     (p_operation <> 'create' and (v_current is null or v_current <> p_base_server_version)) or
     (p_operation = 'create' and p_base_server_version <> 0) then
    insert into public.sync_mutation_receipts(user_id,mutation_id,device_id,entity_type,entity_id,outcome,resulting_server_version)
      values(v_user,p_mutation_id,p_device_id,p_entity_type,p_entity_id,'CONFLICT',v_current);
    return jsonb_build_object('status','CONFLICT','server_version',v_current);
  end if;

  v_version := case when p_operation='create' then 1 else v_current + 1 end;
  v_revision := nextval('public.sync_server_revision_seq');

  if p_operation = 'delete' then
    if p_entity_type='profile' then update public.sync_profiles set deleted_at=v_now,updated_at=v_now,server_version=v_version,server_revision=v_revision where user_id=v_user and id=p_entity_id;
    elsif p_entity_type='account' then update public.sync_accounts set deleted_at=v_now,updated_at=v_now,server_version=v_version,server_revision=v_revision where user_id=v_user and id=p_entity_id;
    elsif p_entity_type='category' then update public.sync_categories set deleted_at=v_now,updated_at=v_now,server_version=v_version,server_revision=v_revision where user_id=v_user and id=p_entity_id;
    elsif p_entity_type='project' then update public.sync_projects set deleted_at=v_now,updated_at=v_now,server_version=v_version,server_revision=v_revision where user_id=v_user and id=p_entity_id;
    elsif p_entity_type='budget' then update public.sync_budgets set deleted_at=v_now,updated_at=v_now,server_version=v_version,server_revision=v_revision where user_id=v_user and id=p_entity_id;
    elsif p_entity_type='transaction' then update public.sync_transactions set deleted_at=v_now,updated_at=v_now,server_version=v_version,server_revision=v_revision where user_id=v_user and id=p_entity_id;
    elsif p_entity_type='transfer' then update public.sync_transfers set deleted_at=v_now,updated_at=v_now,server_version=v_version,server_revision=v_revision where user_id=v_user and id=p_entity_id;
    else update public.sync_receipt_attachments set deleted_at=v_now,updated_at=v_now,server_version=v_version,server_revision=v_revision where user_id=v_user and id=p_entity_id;
    end if;
  elsif p_entity_type='profile' then
    if p_operation='create' then insert into public.sync_profiles values(v_user,p_entity_id,p_payload->>'base_currency_code',v_version,v_revision,(p_payload->>'created_at')::timestamptz,v_now,null);
    else update public.sync_profiles set base_currency_code=p_payload->>'base_currency_code',updated_at=v_now,deleted_at=null,server_version=v_version,server_revision=v_revision where user_id=v_user and id=p_entity_id; end if;
  elsif p_entity_type='account' then
    if p_operation='create' then insert into public.sync_accounts values(v_user,p_entity_id,(p_payload->>'profile_id')::uuid,p_payload->>'name',p_payload->>'kind',p_payload->>'currency_code',(p_payload->>'opening_minor_units')::bigint,(p_payload->>'opening_date')::date,coalesce((p_payload->>'is_archived')::boolean,false),v_version,v_revision,(p_payload->>'created_at')::timestamptz,v_now,null);
    else update public.sync_accounts set name=p_payload->>'name',kind=p_payload->>'kind',currency_code=p_payload->>'currency_code',opening_minor_units=(p_payload->>'opening_minor_units')::bigint,opening_date=(p_payload->>'opening_date')::date,is_archived=coalesce((p_payload->>'is_archived')::boolean,false),updated_at=v_now,deleted_at=null,server_version=v_version,server_revision=v_revision where user_id=v_user and id=p_entity_id; end if;
  elsif p_entity_type='category' then
    if p_operation='create' then insert into public.sync_categories values(v_user,p_entity_id,(p_payload->>'profile_id')::uuid,p_payload->>'name',p_payload->>'kind',coalesce((p_payload->>'is_archived')::boolean,false),v_version,v_revision,(p_payload->>'created_at')::timestamptz,v_now,null);
    else update public.sync_categories set name=p_payload->>'name',kind=p_payload->>'kind',is_archived=coalesce((p_payload->>'is_archived')::boolean,false),updated_at=v_now,deleted_at=null,server_version=v_version,server_revision=v_revision where user_id=v_user and id=p_entity_id; end if;
  elsif p_entity_type='project' then
    if p_operation='create' then insert into public.sync_projects values(v_user,p_entity_id,(p_payload->>'profile_id')::uuid,p_payload->>'name',p_payload->>'description',coalesce((p_payload->>'is_archived')::boolean,false),v_version,v_revision,(p_payload->>'created_at')::timestamptz,v_now,null);
    else update public.sync_projects set name=p_payload->>'name',description=p_payload->>'description',is_archived=coalesce((p_payload->>'is_archived')::boolean,false),updated_at=v_now,deleted_at=null,server_version=v_version,server_revision=v_revision where user_id=v_user and id=p_entity_id; end if;
  elsif p_entity_type='budget' then
    if p_operation='create' then insert into public.sync_budgets values(v_user,p_entity_id,(p_payload->>'profile_id')::uuid,p_payload->>'name',(p_payload->>'amount_minor_units')::bigint,p_payload->>'currency_code',p_payload->>'month',nullif(p_payload->>'category_id','')::uuid,(p_payload->>'warning_threshold_percent')::integer,coalesce((p_payload->>'is_archived')::boolean,false),v_version,v_revision,(p_payload->>'created_at')::timestamptz,v_now,null);
    else update public.sync_budgets set name=p_payload->>'name',amount_minor_units=(p_payload->>'amount_minor_units')::bigint,currency_code=p_payload->>'currency_code',month=p_payload->>'month',category_id=nullif(p_payload->>'category_id','')::uuid,warning_threshold_percent=(p_payload->>'warning_threshold_percent')::integer,is_archived=coalesce((p_payload->>'is_archived')::boolean,false),updated_at=v_now,deleted_at=null,server_version=v_version,server_revision=v_revision where user_id=v_user and id=p_entity_id; end if;
  elsif p_entity_type='transaction' then
    if p_operation='create' then insert into public.sync_transactions values(v_user,p_entity_id,(p_payload->>'profile_id')::uuid,(p_payload->>'account_id')::uuid,(p_payload->>'category_id')::uuid,nullif(p_payload->>'project_id','')::uuid,p_payload->>'kind',(p_payload->>'amount_minor_units')::bigint,p_payload->>'currency_code',(p_payload->>'business_date')::date,p_payload->>'note',v_version,v_revision,(p_payload->>'created_at')::timestamptz,v_now,null);
    else update public.sync_transactions set account_id=(p_payload->>'account_id')::uuid,category_id=(p_payload->>'category_id')::uuid,project_id=nullif(p_payload->>'project_id','')::uuid,kind=p_payload->>'kind',amount_minor_units=(p_payload->>'amount_minor_units')::bigint,currency_code=p_payload->>'currency_code',business_date=(p_payload->>'business_date')::date,note=p_payload->>'note',updated_at=v_now,deleted_at=null,server_version=v_version,server_revision=v_revision where user_id=v_user and id=p_entity_id; end if;
  elsif p_entity_type='transfer' then
    if p_operation='create' then insert into public.sync_transfers values(v_user,p_entity_id,(p_payload->>'profile_id')::uuid,(p_payload->>'source_account_id')::uuid,(p_payload->>'destination_account_id')::uuid,(p_payload->>'source_minor_units')::bigint,p_payload->>'source_currency_code',(p_payload->>'destination_minor_units')::bigint,p_payload->>'destination_currency_code',(p_payload->>'business_date')::date,p_payload->>'note',v_version,v_revision,(p_payload->>'created_at')::timestamptz,v_now,null);
    else update public.sync_transfers set source_account_id=(p_payload->>'source_account_id')::uuid,destination_account_id=(p_payload->>'destination_account_id')::uuid,source_minor_units=(p_payload->>'source_minor_units')::bigint,source_currency_code=p_payload->>'source_currency_code',destination_minor_units=(p_payload->>'destination_minor_units')::bigint,destination_currency_code=p_payload->>'destination_currency_code',business_date=(p_payload->>'business_date')::date,note=p_payload->>'note',updated_at=v_now,deleted_at=null,server_version=v_version,server_revision=v_revision where user_id=v_user and id=p_entity_id; end if;
  else
    if p_operation='create' then insert into public.sync_receipt_attachments values(v_user,p_entity_id,(p_payload->>'profile_id')::uuid,(p_payload->>'transaction_id')::uuid,p_payload->>'storage_path',p_payload->>'mime_type',(p_payload->>'byte_size')::bigint,p_payload->>'sha256_hex',(p_payload->>'position')::integer,v_version,v_revision,(p_payload->>'created_at')::timestamptz,v_now,null);
    else update public.sync_receipt_attachments set storage_path=p_payload->>'storage_path',mime_type=p_payload->>'mime_type',byte_size=(p_payload->>'byte_size')::bigint,sha256_hex=p_payload->>'sha256_hex',position=(p_payload->>'position')::integer,updated_at=v_now,deleted_at=null,server_version=v_version,server_revision=v_revision where user_id=v_user and id=p_entity_id; end if;
  end if;

  insert into public.sync_change_log(sequence,user_id,entity_type,entity_id,server_version,operation)
    values(v_revision,v_user,p_entity_type,p_entity_id,v_version,case when p_operation='delete' then 'delete' else 'upsert' end);
  insert into public.sync_mutation_receipts(user_id,mutation_id,device_id,entity_type,entity_id,outcome,resulting_server_version,resulting_server_revision)
    values(v_user,p_mutation_id,p_device_id,p_entity_type,p_entity_id,'APPLIED',v_version,v_revision);
  return jsonb_build_object('status','APPLIED','server_version',v_version,'server_revision',v_revision);
exception when unique_violation or foreign_key_violation or check_violation or invalid_text_representation then
  return jsonb_build_object('status','REJECTED','reason','VALIDATION_FAILED');
end;
$$;

revoke all on function public.sync_apply_mutation_v1(uuid,uuid,text,uuid,text,bigint,jsonb) from public, anon;
grant execute on function public.sync_apply_mutation_v1(uuid,uuid,text,uuid,text,bigint,jsonb) to authenticated;

insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('ledger-sync-receipts','ledger-sync-receipts',false,10485760,array['image/jpeg'])
on conflict(id) do update set public=false,file_size_limit=excluded.file_size_limit,allowed_mime_types=excluded.allowed_mime_types;

create policy "sync_receipt_objects_select_own" on storage.objects for select to authenticated using (
  bucket_id='ledger-sync-receipts' and (storage.foldername(name))[1]=(select auth.uid())::text
);
create policy "sync_receipt_objects_insert_own" on storage.objects for insert to authenticated with check (
  bucket_id='ledger-sync-receipts' and (storage.foldername(name))[1]=(select auth.uid())::text
);
create policy "sync_receipt_objects_delete_own" on storage.objects for delete to authenticated using (
  bucket_id='ledger-sync-receipts' and (storage.foldername(name))[1]=(select auth.uid())::text
);
