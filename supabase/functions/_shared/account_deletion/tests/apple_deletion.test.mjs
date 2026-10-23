import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {prepareAppleDeletion,appleSubjects} from '../apple_deletion.mjs';
import {deleteCloudAccount} from '../deletion.mjs';

const A='11111111-1111-4111-8111-111111111111';
const fresh=new Date(Date.now()-30000).toISOString();
const apple=(id='apple-sub-A')=>({provider:'apple',id,identity_id:A,identity_data:{sub:id}});
const user=(identities=[apple()])=>({id:A,last_sign_in_at:fresh,identities});
const credential={appleIdentityToken:'signed',appleAuthorizationCode:'fresh-code',appleRawNonce:'nonce'};
function fixture(overrides={}) {
  const steps=[];
  const deps={user:user(),credential,verifyIdentity:async ()=>{steps.push('verify');return {subject:'apple-sub-A',clientId:'keev.bundle'};},
    exchangeCode:async (code,id,subject)=>{assert.equal(code,'fresh-code');assert.equal(id,'keev.bundle');assert.equal(subject,'apple-sub-A');steps.push('exchange');return {value:'private',type:'refresh_token'};},
    revokeToken:async (token,id)=>{assert.equal(token.type,'refresh_token');assert.equal(id,'keev.bundle');steps.push('revoke');},...overrides};
  return {deps,steps};
}

test('fresh, matching Apple credential is revoked before deletion begins',async()=>{
  const {deps,steps}=fixture();
  assert.equal(await prepareAppleDeletion(deps),'READY');
  assert.deepEqual(steps,['verify','exchange','revoke']);
  const status=await deleteCloudAccount({accountId:A,lastSignInAt:fresh,
    progress:async (_,state)=>{steps.push(state);return state;},
    storage:{from:()=>({list:async()=>({data:[]})})},
    deleteUser:async()=>steps.push('auth')});
  assert.equal(status,'DELETED');assert.equal(steps.indexOf('revoke')+1,steps.indexOf('requested'));
});
test('Apple-linked deletion requires fresh credentials, including on multi-provider accounts',async()=>{
  for (const identities of [[apple()],[{provider:'google',id:'google'},apple()]]) {
    const {deps,steps}=fixture({user:user(identities),credential:{}});
    assert.equal(await prepareAppleDeletion(deps),'APPLE_REAUTH_REQUIRED');assert.deepEqual(steps,[]);
  }
});
test('no Apple link needs no Apple prompt or token service',async()=>{
  const {deps,steps}=fixture({user:user([{provider:'email',id:'email'}]),credential:{}});
  assert.equal(await prepareAppleDeletion(deps),'READY');assert.deepEqual(steps,[]);
});
test('missing identity list cannot bypass Apple revocation',async()=>{
  const {deps,steps}=fixture({user:{id:A,last_sign_in_at:fresh,
    app_metadata:{providers:['apple']}}});
  assert.equal(await prepareAppleDeletion(deps),'APPLE_REAUTH_REQUIRED');assert.deepEqual(steps,[]);
});
test('old KeEv sign-in blocks revocation and deletion',async()=>{
  const {deps,steps}=fixture({user:{...user(),last_sign_in_at:new Date(0).toISOString()}});
  assert.equal(await prepareAppleDeletion(deps),'REAUTH_REQUIRED');assert.deepEqual(steps,[]);
});
test('a different Apple subject cannot delete or revoke Account A',async()=>{
  const {deps,steps}=fixture({verifyIdentity:async()=>({subject:'apple-sub-B',clientId:'keev.bundle'})});
  assert.equal(await prepareAppleDeletion(deps),'ACCOUNT_MISMATCH');assert.deepEqual(steps,[]);
});
test('Supabase internal identity row ID is not the provider subject',()=>{
  assert.deepEqual(appleSubjects([apple()]),['apple-sub-A']);
  assert.deepEqual(appleSubjects([{provider:'apple',provider_id:'apple-sub-A',identity_data:{sub:'apple-sub-A'}}]),['apple-sub-A']);
  assert.deepEqual(appleSubjects([{provider:'apple',identity_id:A,identity_data:{sub:'apple-sub-A'}}]),['apple-sub-A']);
  assert.deepEqual(appleSubjects([{provider:'apple',id:'different',identity_data:{sub:'apple-sub-A'}}]),[null]);
});
for (const name of ['signature','issuer','audience','expiry','nonce']) {
  test(`invalid Apple ${name} stops exchange and deletion`,async()=>{
    const {deps,steps}=fixture({verifyIdentity:async()=>{throw Error(name);}});
    assert.equal(await prepareAppleDeletion(deps),'APPLE_REAUTH_REQUIRED');assert.deepEqual(steps,[]);
  });
}
test('token exchange failure leaves cloud untouched',async()=>{
  const {deps,steps}=fixture({exchangeCode:async()=>{throw Error('offline');}});
  assert.equal(await prepareAppleDeletion(deps),'TEMPORARY_FAILURE');assert.deepEqual(steps,['verify']);
});
test('exchanged authorization code for another Apple subject cannot delete Account A',async()=>{
  const {deps,steps}=fixture({exchangeCode:async()=>{throw Object.assign(Error('mismatch'),{code:'ACCOUNT_MISMATCH'});}});
  assert.equal(await prepareAppleDeletion(deps),'ACCOUNT_MISMATCH');assert.deepEqual(steps,['verify']);
});
test('revoke failure leaves cloud untouched and is retryable',async()=>{
  const {deps,steps}=fixture({revokeToken:async()=>{throw Error('offline');}});
  assert.equal(await prepareAppleDeletion(deps),'TEMPORARY_FAILURE');assert.deepEqual(steps,['verify','exchange']);
});
test('Apple HTTP 200, including already-revoked semantics, proceeds',async()=>{
  const {deps}=fixture({revokeToken:async()=>{}});
  assert.equal(await prepareAppleDeletion(deps),'READY');
});
test('server adapter pins JWKS cryptographic checks and posts token then revoke',()=>{
  const code=readFileSync(new URL('../apple_revoke.ts',import.meta.url),'utf8');
  for(const fragment of ["npm:jose@6.1.3","createRemoteJWKSet(new URL('https://appleid.apple.com/auth/keys'))",
    'jwtVerify(token, appleKeys','issuer, audience:allowed',"algorithms:['RS256']",'payload.nonce !== nonce',
    "setProtectedHeader({alg:'ES256'", "setExpirationTime('5m')", "applePost('token'", "applePost('revoke'"]) assert.ok(code.includes(fragment),fragment);
});
