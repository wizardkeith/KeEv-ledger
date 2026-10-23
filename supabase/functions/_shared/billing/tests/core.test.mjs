import test from 'node:test';
import assert from 'node:assert/strict';
import {verifyPurchase} from '../core.mjs';
import {appleSubscription,validateAppleRenewal,googleState,googleStoreAccount,validateGoogleEnvironment,selectGoogleLine,deriveCapability,fingerprint} from '../domain.mjs';
const accountA='aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa';
const accountB='bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb';
const product='keev.premium.test';
const config={environment:'sandbox',products:new Set([product]),packageName:'com.keev.test',plans:{[product]:['base']}};
const request={platform:'apple',proof:'signed.test.proof',transactionId:'123',productId:product,accountId:accountA};
const future='2031-01-01T00:00:00.000Z';
function harness(overrides={}) {
  const stored=new Map(), calls={commit:0,ack:0,verify:0};
  const source={platform:'apple',environment:'sandbox',identity:'original-123',originalIdentity:'original-123',productId:product,storeAccountId:accountA,state:'active',validUntil:future,validFrom:'2026-01-01T00:00:00Z',acknowledged:true,token:null,...overrides};
  const persistence={
    async commit(s){ calls.commit++; const key=s.platform+':'+s.environment+':'+s.identityHash;
      if(stored.has(key) && stored.get(key).userId!==s.userId) return 'ACCOUNT_MISMATCH'; stored.set(key,s); return 'COMMITTED'; },
    async refresh(id,env){const result=deriveCapability([...stored.values()].filter(s=>s.userId===id),Date.parse('2026-09-24'),env);return {...result,adFree:result.active,premium:result.active,verifiedAt:'2026-09-24T00:00:00Z'};},
    async markAcknowledged(){calls.ack++;},
  };
  const apple={async verify(){calls.verify++;return source;}};
  const google={async verify(){calls.verify++;return source;},async acknowledge(){calls.ack++;}};
  return {stored,calls,persistence,apple,google,source};
}
const run=(h,r=request,a=accountA)=>verifyPurchase({request:r,accountId:a,config,apple:h.apple,google:h.google,persistence:h.persistence});
test('Apple verified active, duplicate identity commits one source',async()=>{
 const h=harness();assert.equal((await run(h)).outcome,'VERIFIED_ACTIVE');assert.equal((await run(h)).outcome,'VERIFIED_ACTIVE');assert.equal(h.stored.size,1);
});
test('untrusted account, unknown product and invalid proof fail closed',async()=>{
 const h=harness();assert.equal((await run(h,{...request,accountId:accountB})).outcome,'ACCOUNT_MISMATCH');
 assert.equal((await run(h,{...request,productId:'fake.premium'})).outcome,'REJECTED');
 assert.equal((await run(h,{...request,proof:'bad'})).outcome,'REJECTED');assert.equal(h.calls.verify,0);
});
test('store account mismatch never commits',async()=>{
 const h=harness({storeAccountId:accountB});assert.equal((await run(h)).outcome,'ACCOUNT_MISMATCH');assert.equal(h.calls.commit,0);
});
test('invalid Apple signature is rejected; Apple API outage is retryable',async()=>{
 const h=harness();h.apple.verify=async()=>{throw Object.assign(new Error('invalid signature'),{permanent:true});};
 assert.equal((await run(h)).outcome,'REJECTED');assert.equal(h.calls.commit,0);
 h.apple.verify=async()=>{throw Error('Apple API unavailable');};
 assert.equal((await run(h)).outcome,'TRANSIENT_FAILURE');
});
test('invalid signed Apple renewal cannot confer Premium',async()=>{
 const h=harness();h.apple.verify=async()=>{throw Object.assign(new Error('invalid Apple renewal signature'),{permanent:true});};
 assert.equal((await run(h)).outcome,'REJECTED');assert.equal(h.calls.commit,0);
});
test('same purchase token cannot be claimed by another account',async()=>{
 const h=harness();await run(h);
 h.source.storeAccountId=accountB;
 assert.equal((await run(h,{...request,accountId:accountB},accountB)).outcome,'ACCOUNT_MISMATCH');
 assert.equal(h.stored.size,1);
});
test('store observation environment and product cannot be forged',async()=>{
 const h=harness({environment:'production'});assert.equal((await run(h)).outcome,'REJECTED');
 h.source.environment='sandbox';h.source.productId='fake.premium';assert.equal((await run(h)).outcome,'REJECTED');
});
test('Apple paid expiry, realistic grace expiry, billing retry and revocation',()=>{
 const now=1000;
 assert.deepEqual(appleSubscription(1,2000,undefined,1,false,now),{state:'active',validUntilMs:2000});
 assert.deepEqual(appleSubscription(4,500,3000,1,false,now),{state:'gracePeriod',validUntilMs:3000});
 assert.deepEqual(appleSubscription(4,500,900,1,false,now),{state:'expired',validUntilMs:900});
 assert.equal(appleSubscription(3,500,3000,1,false,now).state,'billingRetry');
 assert.equal(appleSubscription(1,500,undefined,1,false,now).state,'expired');
 assert.equal(appleSubscription(1,2000,undefined,1,true,now).state,'revoked');
 assert.equal(appleSubscription(5,2000,3000,1,false,now).state,'revoked');
 assert.deepEqual(appleSubscription(1,2000,undefined,0,false,now),{state:'cancelledButActive',validUntilMs:2000});
 assert.throws(()=>appleSubscription(4,500,undefined,1,false,now),/grace expiry unavailable/);
 assert.equal(deriveCapability([{state:'gracePeriod',environment:'sandbox',validUntil:new Date(3000).toISOString()}],now,'sandbox').active,true);
 assert.equal(deriveCapability([{state:'gracePeriod',environment:'sandbox',validUntil:new Date(3000).toISOString()}],3001,'sandbox').active,false);
});
test('Apple signed renewal identity, environment, product chain and binding are checked',()=>{
 const products=new Set([product,'keev.premium.annual']);
 const r={originalTransactionId:'O1',environment:'Sandbox',productId:'keev.premium.annual',autoRenewProductId:product,appAccountToken:accountA};
 assert.doesNotThrow(()=>validateAppleRenewal(r,'O1',accountA,'sandbox',products));
 for(const invalid of [{...r,originalTransactionId:'O2'},{...r,environment:'Production'},
   {...r,appAccountToken:accountB},{...r,productId:'unknown'},{...r,autoRenewProductId:'unknown'}])
  assert.throws(()=>validateAppleRenewal(invalid,'O1',accountA,'sandbox',products),error=>error.permanent===true);
});
test('Apple current approved product can change within a verified chain; Google remains strict',async()=>{
 const annual='keev.premium.annual';const h=harness({productId:annual});const approved={...config,products:new Set([product,annual])};
 const runApproved=(r)=>verifyPurchase({request:r,accountId:accountA,config:approved,apple:h.apple,google:h.google,persistence:h.persistence});
 assert.equal((await runApproved(request)).outcome,'VERIFIED_ACTIVE');
 assert.equal([...h.stored.values()][0].productId,annual);
 h.source.productId='unknown';assert.equal((await runApproved(request)).outcome,'REJECTED');
 h.source.productId=annual;h.source.storeAccountId=accountB;assert.equal((await runApproved(request)).outcome,'ACCOUNT_MISMATCH');
 h.source.storeAccountId=accountA;h.source.platform='google';
 assert.equal((await runApproved({...request,platform:'google',proof:'play-token-3',packageId:config.packageName})).outcome,'REJECTED');
});
test('Google sandbox requires test marker; production excludes test purchases',()=>{
 assert.doesNotThrow(()=>validateGoogleEnvironment({testPurchase:{}},'sandbox'));
 assert.doesNotThrow(()=>validateGoogleEnvironment({},'production'));
 assert.throws(()=>validateGoogleEnvironment({},'sandbox'),error=>error.permanent===true);
 assert.throws(()=>validateGoogleEnvironment({testPurchase:{}},'production'),error=>error.permanent===true);
});
test('Google out-of-app prior identity is opt-in only',()=>{
 const data={outOfAppPurchaseContext:{expiredExternalAccountIdentifiers:{obfuscatedExternalAccountId:accountA}}};
 assert.equal(googleStoreAccount(data),null);
 assert.equal(googleStoreAccount(data,{outOfApp:true}),accountA);
 assert.equal(googleStoreAccount({...data,externalAccountIdentifiers:{obfuscatedExternalAccountId:accountB}},{outOfApp:true}),accountB);
});
test('Google lifecycle chooses approved current line, while client proof remains product-bound',()=>{
 const lines=[{productId:product,offerDetails:{basePlanId:'base'},expiryTime:'2026-01-01T00:00:00Z'},
  {productId:'keev.premium.annual',offerDetails:{basePlanId:'annual'},expiryTime:'2031-01-01T00:00:00Z'},
  {productId:'unapproved',offerDetails:{basePlanId:'base'},expiryTime:'2040-01-01T00:00:00Z'}];
 const products=new Set([product,'keev.premium.annual']),plans={[product]:['base'],'keev.premium.annual':['annual']};
 assert.equal(selectGoogleLine(lines,undefined,products,plans).productId,'keev.premium.annual');
 assert.equal(selectGoogleLine(lines,product,products,plans).productId,product);
 assert.equal(selectGoogleLine(lines,'unapproved',products,plans),null);
});
test('Google grace, hold, cancellation with paid time, pending and expiry',()=>{
 const now=1000;assert.equal(googleState('SUBSCRIPTION_STATE_ACTIVE',2000,false,now),'active');
 assert.equal(googleState('SUBSCRIPTION_STATE_IN_GRACE_PERIOD',2000,false,now),'gracePeriod');
 assert.equal(googleState('SUBSCRIPTION_STATE_ON_HOLD',2000,false,now),'onHold');
 assert.equal(googleState('SUBSCRIPTION_STATE_CANCELED',2000,true,now),'cancelledButActive');
 assert.equal(googleState('SUBSCRIPTION_STATE_CANCELED',500,true,now),'expired');
 assert.equal(googleState('SUBSCRIPTION_STATE_PENDING',0,false,now),'pending');
});
test('Google ack only after durable entitlement grant; failure retains pending',async()=>{
 const h=harness({platform:'google',identity:'play-token-1',token:'play-token-1',acknowledged:false});
 h.google.acknowledge=async()=>{assert.equal(h.stored.size,1);h.calls.ack++;throw Error('offline');};
 const r=await run(h,{...request,platform:'google',proof:'play-token-1',packageId:config.packageName});
 assert.equal(r.outcome,'VERIFIED_ACTIVE');assert.equal(r.acknowledgementPending,true);assert.equal([...h.stored.values()][0].acknowledgementPending,true);
});
test('Google already acknowledged, invalid, mismatch or pending never acknowledges',async()=>{
 const h=harness({platform:'google',identity:'play-token-2',token:'play-token-2',acknowledged:true});
 const r={...request,platform:'google',proof:'play-token-2',packageId:config.packageName};
 await run(h,r);assert.equal(h.calls.ack,0);
 h.source.acknowledged=false;h.source.state='pending';await run(h,r);assert.equal(h.calls.ack,0);
 h.source.state='active';h.source.storeAccountId=accountB;await run(h,r);assert.equal(h.calls.ack,0);
});
test('Apple expired with Google active retains effective capability',()=>{
 const sources=[{state:'expired',environment:'sandbox',validUntil:future},{state:'active',environment:'sandbox',validUntil:future}];
 assert.equal(deriveCapability(sources,Date.parse('2026-09-24'),'sandbox').active,true);
 assert.equal(deriveCapability([{...sources[0],state:'revoked'}],Date.parse('2026-09-24'),'sandbox').active,false);
 assert.equal(deriveCapability(sources,Date.parse('2026-09-24'),'production').active,false);
});
test('concurrent duplicate requests preserve one identity',async()=>{
 const h=harness();const results=await Promise.all(Array.from({length:12},()=>run(h)));
 assert(results.every(x=>x.outcome==='VERIFIED_ACTIVE'));assert.equal(h.stored.size,1);
});
test('older store observation retains client journal; no premature Play completion',async()=>{
 const h=harness({platform:'google',identity:'play-token-stale',token:'play-token-stale',acknowledged:false});
 h.persistence.commit=async()=> 'STALE';
 const r=await run(h,{...request,platform:'google',proof:'play-token-stale',packageId:config.packageName});
 assert.equal(r.outcome,'TRANSIENT_FAILURE');assert.equal(h.calls.ack,0);
});
test('fingerprint is stable SHA-256 without exposing raw token',async()=>{
 const a=await fingerprint('secret-play-token');assert.equal(a.length,64);assert.equal(a,await fingerprint('secret-play-token'));assert(!a.includes('secret'));
});
