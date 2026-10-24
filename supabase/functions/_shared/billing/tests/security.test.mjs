import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
const sql=readFileSync(new URL('../../../../migrations/202609240001_billing_verification_v1.sql',import.meta.url),'utf8');
const notificationsSql=readFileSync(new URL('../../../../migrations/202609240002_billing_notifications_v1.sql',import.meta.url),'utf8');
const config=readFileSync(new URL('../../../../config.toml',import.meta.url),'utf8');
const client=readFileSync(new URL('../../../../../lib/app/bootstrap.dart',import.meta.url),'utf8');
const apple=readFileSync(new URL('../apple.ts',import.meta.url),'utf8');
const google=readFileSync(new URL('../google.ts',import.meta.url),'utf8');
const configuredCatalogueGuard=/supabase\s*!=\s*null\s*&&\s*configuredIds\.trim\(\)\.isNotEmpty/;
test('billing metadata is server-private; RLS only allows own sanitized state',()=>{
 assert.match(sql,/revoke all on schema billing_private from public, anon, authenticated/);
 assert.match(sql,/alter table public\.billing_entitlements enable row level security/);
 assert.match(sql,/for select to authenticated using \(user_id = \(select auth\.uid\(\)\)\)/);
 assert.match(sql,/revoke all on public\.billing_entitlements from public, anon, authenticated/);
 assert.doesNotMatch(sql,/grant\s+(insert|update|delete|all)\s+on\s+public\.billing_entitlements\s+to\s+authenticated/i);
});
test('commit, refresh and acknowledgement RPCs are service-role only',()=>{
 for(const name of ['billing_commit_verification_v1','billing_refresh_entitlements_v1','billing_mark_acknowledged_v1']){
  assert.match(sql,new RegExp(`revoke all on function public\\.${name}\\(`));
  assert.match(sql,new RegExp(`grant execute on function public\\.${name}\\([\\s\\S]*?to service_role;`));
 }
 assert.match(sql,/security definer set search_path = ''/);
 assert.match(sql,/pg_advisory_xact_lock/);
 assert.match(sql,/v_existing\.user_id<>p_user_id/);
});
test('checkout defaults disabled behind explicit opt-in; no client service role credential',()=>{
 assert.match(client,/bool\.fromEnvironment\(\s*'PURCHASES_ENABLED', defaultValue: false/);
 assert.match(client,configuredCatalogueGuard);
 const dart=readFileSync(new URL('../../../../../lib/features/purchases/infrastructure/supabase_purchase_remote.dart',import.meta.url),'utf8');
 assert.doesNotMatch(dart,/service_role|SERVICE_ROLE|private_key/);
 const purchases=readFileSync(new URL('../../../../../lib/features/purchases/application/purchase_controller.dart',import.meta.url),'utf8');
 assert.match(purchases,/if \(!purchaseEnabled\)/);
 assert.match(purchases,/if \(account == null\)/);
 assert.match(purchases,/!storeAvailable \|\| !catalogue\.productIds\.contains\(product\.id\)/);
 assert.match(purchases,/void resumed\(\)/);
 assert.match(purchases,/Duration\(minutes: 5\)/);
 const app=readFileSync(new URL('../../../../../lib/app/app.dart',import.meta.url),'utf8');
 assert.match(app,/widget\.purchaseController\?\.resumed\(\)/);
});
test('catalogue source guard accepts formatter line breaks',()=>{
 for(const source of [
  'supabase != null && configuredIds.trim().isNotEmpty',
  'supabase != null &&\n        configuredIds.trim().isNotEmpty',
 ]) assert.match(source,configuredCatalogueGuard);
});
test('catalogue source guard rejects removed or altered prerequisites',()=>{
 for(const source of [
  'configuredIds.trim().isNotEmpty',
  'supabase != null',
  'supabase != null || configuredIds.trim().isNotEmpty',
  'supabase == null && configuredIds.trim().isNotEmpty',
  'supabase != null && configuredIds.trim().isEmpty',
 ]) assert.doesNotMatch(source,configuredCatalogueGuard);
});
test('provider events stay private, unique and recoverable; source observations block stale writes',()=>{
 assert.match(notificationsSql,/create table billing_private\.provider_events/);
 assert.match(notificationsSql,/unique\(provider,environment,provider_event_id\)/);
 assert.match(notificationsSql,/revoke all on billing_private\.provider_events from public, anon, authenticated/);
 assert.match(notificationsSql,/lease_until=now\(\)\+interval '2 minutes'/);
 assert.match(notificationsSql,/v_existing\.source_observed_at >= p_observed_at then return 'STALE'/);
 assert.match(notificationsSql,/pg_advisory_xact_lock\(pg_catalog\.hashtextextended\(p_user_id::text,1\)\)/);
 assert.match(notificationsSql,/least\(greatest\(coalesce\(p_limit,1\),1\),25\)/);
 assert.match(notificationsSql,/revoke execute on function public\.billing_commit_verification_v1[\s\S]+from service_role/);
 for(const name of ['billing_commit_verification_v2','billing_begin_provider_event_v1','billing_finish_provider_event_v1','billing_lookup_source_v1','billing_account_exists_v1','billing_claim_reconcile_v1'])
  assert.match(notificationsSql,new RegExp(`grant execute on function public\\.${name}\\([\\s\\S]*?to service_role;`));
});
test('only external webhook and protected schedule functions disable platform JWT',()=>{
 assert.match(config,/\[functions\.verify-purchase\]\s*verify_jwt = true/);
 assert.match(config,/\[functions\.refresh-entitlements\]\s*verify_jwt = true/);
 for(const name of ['apple-store-notifications','google-play-rtdn','billing-reconcile'])
  assert.match(config,new RegExp(`\\[functions\\.${name}\\]\\s*verify_jwt = false`));
 const oidc=readFileSync(new URL('../google_oidc.ts',import.meta.url),'utf8');
 assert.match(oidc,/npm:jose@6\.1\.3/);assert.match(oidc,/jwtVerify\(token,keys/);
 assert.match(oidc,/https:\/\/www\.googleapis\.com\/oauth2\/v3\/certs/);
 const entry=readFileSync(new URL('../../../google-play-rtdn/index.ts',import.meta.url),'utf8');
 assert.match(entry,/await authenticatePubSub\(request\)/);
 assert.match(entry,/parsePubSubBody/);
});
test('Apple verifies renewal JWS before using grace and renewal status',()=>{
 assert.match(apple,/verifier\.verifyAndDecodeRenewalInfo\(jws\)/);
 assert.match(apple,/const renewal=await ctx\.signed\('renewal',chosen\.item\.signedRenewalInfo\)/);
 assert.match(apple,/validateAppleRenewal\(renewal,/);
 assert.match(apple,/renewal\.gracePeriodExpiresDate/);
 assert.match(apple,/validUntil:period\.validUntilMs/);
 assert.doesNotMatch(apple,/appleState\(/);
});
test('Play adapter uses environment isolation and ordinary account identity only',()=>{
 assert.match(google,/validateGoogleEnvironment\(data, config\.environment\)/);
 assert.match(google,/const ordinaryAccount = googleStoreAccount\(data\)/);
 assert.match(google,/async verify\([\s\S]*?this\.reconcile\(request\.proof,config,request\.productId\)/);
 assert.doesNotMatch(google,/googleStoreAccount\(data,\s*\{outOfApp:\s*true/);
});
