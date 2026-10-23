import test from 'node:test';
import assert from 'node:assert/strict';
import {processProviderEvent,runPeriodic} from '../lifecycle.mjs';
import {deriveCapability,fingerprint} from '../domain.mjs';
import {parseAppleBody,parsePubSubBody,validateGoogleClaims,verifyPushIdentity,readBoundedBody} from '../webhooks.mjs';
import {interpretAppleNotice} from '../apple_notice.mjs';
const A='aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa', B='bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb';
const config={environment:'sandbox',packageName:'com.keev.test',products:new Set(['premium.monthly','premium.annual'])};
const future='2031-01-01T00:00:00Z', past='2020-01-01T00:00:00Z';
const source=(platform,identity,options={})=>({platform,environment:'sandbox',identity,originalIdentity:platform==='apple'?identity:null,
  productId:'premium.monthly',storeAccountId:A,state:'active',validFrom:'2020-01-01T00:00:00Z',validUntil:future,
  observedAt:'2026-09-24T01:00:00Z',token:platform==='google'?identity:null,acknowledged:true,...options});
function rig() {
 const events=new Map(),sources=new Map(),calls={apple:0,google:0,ack:0,commit:0},users=new Set([A,B]);
 let appleResult=source('apple','O1'), googleResult=source('google','token-12345678'),failApple=false,failAck=false;
 const db={
  async beginEvent(e){let row=events.get(e.provider+e.environment+e.id);
   if(row?.state==='processed'||row?.state==='permanentIgnored') return {state:'DONE'};
   if(row?.state==='processing') return {state:'BUSY'};
   row={state:'processing',attempts:(row?.attempts??0)+1,claimId:'claim-'+(row?.attempts??0)};
   events.set(e.provider+e.environment+e.id,row);return {state:'CLAIMED',claimId:row.claimId};},
  async finishEvent(e,claim,state){const row=events.get(e.provider+e.environment+e.id);
   if(row.claimId!==claim) return false;row.state=state;return true;},
  async lookup(platform,env,hash){return sources.get(platform+env+hash)??null;},
  async accountExists(id){return users.has(id);},
  async commit(s){calls.commit++;const key=s.platform+s.environment+s.identityHash,old=sources.get(key);
   if(old?.user_id!==undefined && old.user_id!==s.userId) return 'ACCOUNT_MISMATCH';
   if(old && old.source_observed_at>=s.observedAt) return 'STALE';
   sources.set(key,{...s,user_id:s.userId,source_observed_at:s.observedAt});return 'COMMITTED';},
  async markAcknowledged(platform,env,hash){const row=sources.get(platform+env+hash);row.acknowledgementPending=false;row.acknowledged=true;},
  async claimCandidates(){return [...sources.values()].map(s=>({platform:s.platform,identity_hash:s.identityHash,user_id:s.user_id,
    original_identity:s.originalIdentity,purchase_token:s.token}));},
 };
 const apple={async reconcile(){calls.apple++;if(failApple) throw Error('temporary Apple outage');return {...appleResult};}};
 const google={async reconcile(){calls.google++;return {...googleResult};},async acknowledge(){calls.ack++;if(failAck) throw Error('ack outage');}};
 const deps={config,db,apple,google};
 return {events,sources,calls,db,deps,setApple:s=>appleResult=s,setGoogle:s=>googleResult=s,failApple:v=>failApple=v,failAck:v=>failAck=v};
}
const appleEvent=(id='N1',type='DID_RENEW')=>({provider:'apple',id,type,time:'2026-09-24T00:00:00Z',identity:'O1',accountId:A});
const googleEvent=(id='M1',type='subscription.3')=>({provider:'google',id,type,time:'2026-09-24T00:00:00Z',identity:'token-12345678'});
test('Apple V2 duplicate, TEST, renewal and current-state refund; out-of-order hint cannot rollback',async()=>{
 const r=rig();await processProviderEvent(appleEvent(),r.deps);await processProviderEvent(appleEvent(),r.deps);
 assert.equal(r.calls.apple,1);assert.equal(r.events.size,1);
 await processProviderEvent({...appleEvent('T1','TEST'),identity:null},r.deps);assert.equal(r.calls.apple,1);
 r.setApple(source('apple','O1',{state:'revoked',validUntil:past,observedAt:'2026-09-24T03:00:00Z'}));
 await processProviderEvent(appleEvent('N2','REFUND'),r.deps);
 await processProviderEvent({...appleEvent('N0','DID_RENEW'),time:'2026-09-23T00:00:00Z'},r.deps);
 const row=[...r.sources.values()][0];assert.equal(row.state,'revoked');
 assert.equal(deriveCapability([...r.sources.values()],Date.parse('2026-09-24'),'sandbox').active,false);
});
test('Apple grace, retry, cancelled paid and multi-source refund preserve other store',async()=>{
 const r=rig();r.setApple(source('apple','O1',{state:'gracePeriod',validUntil:future}));
 await processProviderEvent(appleEvent(),r.deps);
 assert.equal(deriveCapability([...r.sources.values()],Date.parse('2026-09-24'),'sandbox').active,true);
 r.setGoogle(source('google','token-12345678'));
 await processProviderEvent(googleEvent(),r.deps);
 r.setApple(source('apple','O1',{state:'revoked',validUntil:past,observedAt:'2026-09-24T03:00:00Z'}));
 await processProviderEvent(appleEvent('N2','REVOKE'),r.deps);
 assert.equal(deriveCapability([...r.sources.values()],Date.parse('2026-09-24'),'sandbox').active,true);
 r.setGoogle(source('google','token-12345678',{state:'expired',validUntil:past,observedAt:'2026-09-24T04:00:00Z'}));
 await processProviderEvent(googleEvent('M2'),r.deps);
 assert.equal(deriveCapability([...r.sources.values()],Date.parse('2026-09-24'),'sandbox').active,false);
});
test('event crash before reconcile retries same ID and lease; malformed signature never starts event',async()=>{
 const r=rig();r.failApple(true);
 await assert.rejects(processProviderEvent(appleEvent(),r.deps));
 assert.equal([...r.events.values()][0].state,'retryableFailure');r.failApple(false);
 await processProviderEvent(appleEvent(),r.deps);assert.equal([...r.events.values()][0].attempts,2);
 assert.equal([...r.events.values()][0].state,'processed');
});
test('RTDN type never determines status; test and duplicates do no store work',async()=>{
 const r=rig();r.setGoogle(source('google','token-12345678',{state:'cancelledButActive'}));
 await processProviderEvent(googleEvent('M1','subscription.3'),r.deps);
 assert.equal([...r.sources.values()][0].state,'cancelledButActive');
 await processProviderEvent(googleEvent('M1','subscription.99'),r.deps);
 await processProviderEvent({...googleEvent('MT','testNotification'),identity:null},r.deps);
 assert.equal(r.calls.google,1);
 r.setGoogle(source('google','token-12345678',{state:'gracePeriod',observedAt:'2026-09-24T03:00:00Z'}));
 await processProviderEvent(googleEvent('M2','subscription.6'),r.deps);
 assert.equal([...r.sources.values()][0].state,'gracePeriod');
 r.setGoogle(source('google','token-12345678',{state:'onHold',observedAt:'2026-09-24T04:00:00Z'}));
 await processProviderEvent(googleEvent('M3','subscription.6'),r.deps);
 assert.equal([...r.sources.values()][0].state,'onHold');
});
test('unseen trusted account binds, unknown account does not, prior out-of-app token requires previous binding',async()=>{
 const r=rig();await processProviderEvent(googleEvent(),r.deps);
 assert.equal([...r.sources.values()][0].user_id,A);
 const r2=rig();r2.setGoogle(source('google','token-12345678',{storeAccountId:B,previousToken:'old-token-12345678'}));
 await processProviderEvent(googleEvent(),r2.deps);
 assert.equal(r2.sources.size,0);assert.equal([...r2.events.values()][0].state,'permanentIgnored');
 const old=source('google','old-token-12345678');await r2.db.commit({...old,userId:B,storeAccountId:B,identityHash:await fingerprint(old.identity)});
 await processProviderEvent(googleEvent('M2'),r2.deps);assert.equal(r2.sources.size,2);
 const r3=rig();r3.setGoogle(source('google','token-12345678',{storeAccountId:'cccccccc-cccc-4ccc-8ccc-cccccccccccc'}));
 await processProviderEvent(googleEvent(),r3.deps);assert.equal(r3.sources.size,0);
});
test('existing Play token retains immutable account when current API omits account identifiers',async()=>{
 const r=rig();await processProviderEvent(googleEvent(),r.deps);
 r.setGoogle(source('google','token-12345678',{storeAccountId:null,state:'onHold',observedAt:'2026-09-24T04:00:00Z'}));
 await processProviderEvent(googleEvent('M2'),r.deps);
 const stored=[...r.sources.values()][0];assert.equal(stored.user_id,A);assert.equal(stored.state,'onHold');
 const unseen=rig();unseen.setGoogle(source('google','token-12345678',{storeAccountId:null}));
 await processProviderEvent(googleEvent(),unseen.deps);assert.equal(unseen.sources.size,0);
});
test('identity mismatch and old concurrent observation cannot overwrite latest',async()=>{
 const r=rig();await processProviderEvent(appleEvent(),r.deps);
 r.setApple(source('apple','O1',{storeAccountId:B,observedAt:'2026-09-24T02:00:00Z'}));
 await processProviderEvent(appleEvent('N2'),r.deps);assert.equal([...r.sources.values()][0].user_id,A);
 r.setApple(source('apple','O1',{state:'revoked',validUntil:past,observedAt:'2026-09-24T03:00:00Z'}));
 await processProviderEvent(appleEvent('N3'),r.deps);
 r.setApple(source('apple','O1',{state:'active',validUntil:future,observedAt:'2026-09-24T01:00:00Z'}));
 await processProviderEvent(appleEvent('N4'),r.deps);
 assert.equal([...r.sources.values()][0].state,'revoked');
});
test('periodic repairs missed Apple and Google signals and retries backend ack',async()=>{
 const r=rig();await processProviderEvent(appleEvent(),r.deps);await processProviderEvent(googleEvent(),r.deps);
 r.setApple(source('apple','O1',{state:'revoked',validUntil:past,observedAt:'2026-09-24T02:00:00Z'}));
 r.setGoogle(source('google','token-12345678',{state:'active',acknowledged:false,observedAt:'2026-09-24T03:00:00Z'}));
 r.failAck(true);let result=await runPeriodic(r.deps);assert.equal(result.processed,2);
 assert.equal([...r.sources.values()].find(s=>s.platform==='google').acknowledgementPending,true);
 r.failAck(false);r.setGoogle(source('google','token-12345678',{state:'active',acknowledged:false,observedAt:'2026-09-24T04:00:00Z'}));
 result=await runPeriodic(r.deps);assert.equal(result.processed,2);
 assert.equal([...r.sources.values()].find(s=>s.platform==='google').acknowledgementPending,false);
});
test('Apple input and Google RTDN envelope validation',()=>{
 assert.throws(()=>parseAppleBody('{}'));assert.throws(()=>parseAppleBody('not json'));
 assert.equal(parseAppleBody(JSON.stringify({signedPayload:'a'.repeat(32)+'.b.c'})).length,36);
 const data={packageName:'com.keev.test',eventTimeMillis:'1780000000000',subscriptionNotification:{purchaseToken:'token-12345678',notificationType:3}};
 const envelope=(d,id='123')=>JSON.stringify({message:{messageId:id,data:btoa(JSON.stringify(d))}});
 assert.equal(parsePubSubBody(envelope(data),'com.keev.test').identity,'token-12345678');
 assert.equal(parsePubSubBody(envelope({...data,subscriptionNotification:undefined,testNotification:{version:'1'}}),'com.keev.test').type,'testNotification');
 assert.throws(()=>parsePubSubBody(envelope({...data,packageName:'other'}),'com.keev.test'));
 assert.throws(()=>parsePubSubBody(JSON.stringify({message:{messageId:'1',data:'###'}}),'com.keev.test'));
});
test('webhook streams stop at byte limit before JSON/JWS work',async()=>{
 assert.equal(await readBoundedBody(new Request('https://example.test',{method:'POST',body:'ok'}),2),'ok');
 await assert.rejects(readBoundedBody(new Request('https://example.test',{method:'POST',body:'123'}),2),/request too large/);
});
test('Pub/Sub verified claims require issuer, audience, exact service account and expiry',()=>{
 const now=1780000000,claims={iss:'https://accounts.google.com',aud:'https://billing.example/rt',email:'push@example.iam.gserviceaccount.com',email_verified:true,exp:now+3600,iat:now};
 assert.doesNotThrow(()=>validateGoogleClaims(claims,claims.aud,claims.email,now));
 for(const changes of [{iss:'attacker'},{aud:'wrong'},{email:'other@example.com'},{email_verified:false},{exp:now-1},{iat:now+61}])
  assert.throws(()=>validateGoogleClaims({...claims,...changes},claims.aud,claims.email,now));
});
test('Apple nested JWS are independently verified; wrong app, environment and signatures fail',async()=>{
 const outer={notificationUUID:'N1',signedDate:1780000000000,version:'2.0',notificationType:'DID_RENEW',
  data:{bundleId:'com.keev.ledger',environment:'Sandbox',signedTransactionInfo:'signed-tx',signedRenewalInfo:'signed-renewal'}};
 const transaction={originalTransactionId:'O1',appAccountToken:A,productId:'premium.monthly'};
 const renewal={originalTransactionId:'O1',appAccountToken:A,environment:'Sandbox',productId:'premium.monthly'};
 let transactionChecks=0,renewalChecks=0;
 const deps={bundle:'com.keev.ledger',environment:'sandbox',products:config.products,
  verifyTransaction:async()=>{transactionChecks++;return transaction;},
  verifyRenewal:async()=>{renewalChecks++;return renewal;}};
 assert.equal((await interpretAppleNotice(outer,deps)).originalId,'O1');
 assert.equal(transactionChecks,1);assert.equal(renewalChecks,1);
 await assert.rejects(interpretAppleNotice(outer,{...deps,verifyTransaction:async()=>{throw Error('bad signature');}}));
 await assert.rejects(interpretAppleNotice(outer,{...deps,verifyRenewal:async()=>{throw Error('bad signature');}}));
 await assert.rejects(interpretAppleNotice({...outer,data:{...outer.data,bundleId:'other'}},deps));
 await assert.rejects(interpretAppleNotice({...outer,data:{...outer.data,environment:'Production'}},deps));
 assert.equal((await interpretAppleNotice({...outer,notificationType:'TEST',data:undefined},deps)).type,'TEST');
});
test('Pub/Sub cryptographic verifier failure or wrong claims blocks processing',async()=>{
 const now=Math.floor(Date.now()/1000),aud='https://example.test/functions/v1/google-play-rtdn',email='push@example.iam.gserviceaccount.com';
 const payload={iss:'https://accounts.google.com',aud,email,email_verified:true,exp:now+300,iat:now};
 let calls=0;
 await verifyPushIdentity('signed-jwt',async()=>{calls++;return payload;},aud,email);
 await assert.rejects(verifyPushIdentity('bad-jwt',async()=>{calls++;throw Error('invalid signature');},aud,email));
 await assert.rejects(verifyPushIdentity('signed-jwt',async()=>({...payload,aud:'wrong'}),aud,email));
 assert.equal(calls,2);
});
