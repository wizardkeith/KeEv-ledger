import {entitled,fingerprint} from './domain.mjs';
const uuid=/^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
function permanent(message) {throw Object.assign(new Error(message),{permanent:true});}

// Store reads are shared by client verification and both asynchronous paths.
// Identity is always checked against the immutable private source before commit.
export async function reconcileSource(source,config,db,google,{notificationAccount=null}={}) {
  const identityHash=await fingerprint(source.identity);
  const existing=await db.lookup(source.platform,config.environment,identityHash);
  if(notificationAccount && notificationAccount.toLowerCase()!==(source.storeAccountId ?? existing?.user_id)?.toLowerCase()) permanent('notification account mismatch');
  if(source.storeAccountId && !uuid.test(source.storeAccountId)) permanent('invalid store account');
  if(existing && source.storeAccountId && existing.user_id.toLowerCase()!==source.storeAccountId.toLowerCase()) permanent('immutable account mismatch');
  if(!existing && !uuid.test(source.storeAccountId ?? '')) permanent('unbound store purchase');
  if(source.platform==='google' && source.previousToken && !existing) {
    // A previous out-of-app identifier alone is not enough to claim a new token.
    const previous=await db.lookup('google',config.environment,await fingerprint(source.previousToken));
    if(!previous || previous.user_id.toLowerCase()!==source.storeAccountId.toLowerCase()) permanent('unproven previous binding');
  }
  if(!existing && !await db.accountExists(source.storeAccountId)) permanent('unknown KeEv account');
  const userId=existing?.user_id ?? source.storeAccountId;
  const committed=await db.commit({...source,identityHash,userId,
    acknowledgementPending:source.platform==='google' && entitled.has(source.state) && !source.acknowledged});
  if(committed==='ACCOUNT_MISMATCH' || committed==='REJECTED') permanent('source commit rejected');
  if(committed==='STALE') return {state:'STALE',userId};
  if(committed!=='COMMITTED') throw new Error('source commit unavailable');
  let acknowledgementPending=source.platform==='google' && entitled.has(source.state) && !source.acknowledged;
  if(acknowledgementPending) {
    try {await google.acknowledge(source,config);await db.markAcknowledged(source.platform,config.environment,identityHash);acknowledgementPending=false;}
    catch (_) { /* Durable pending acknowledgement is retried by the scheduler. */ }
  }
  return {state:'COMMITTED',userId,acknowledgementPending};
}
export async function processProviderEvent(event,{config,db,apple,google}) {
  const claim=await db.beginEvent({provider:event.provider,environment:config.environment,id:event.id,type:event.type,
    time:event.time,identityHash:event.identity ? await fingerprint(event.identity) : null});
  if(claim.state==='DONE') return {state:'DONE'};
  if(claim.state==='BUSY') throw new Error('event already processing');
  if(claim.state!=='CLAIMED' || !claim.claimId) permanent('invalid event claim');
  try {
    let result;
    if(event.type==='TEST' || event.type==='testNotification') result={state:'TEST'};
    else if(!event.identity) permanent('unresolved store identity');
    else if(event.provider==='apple') {
      const source=await apple.reconcile(event.identity,config);
      result=await reconcileSource(source,config,db,google,{notificationAccount:event.accountId});
    } else {
      const source=await google.reconcile(event.identity,config,undefined,true);
      result=await reconcileSource(source,config,db,google);
    }
    if(!await db.finishEvent({provider:event.provider,environment:config.environment,id:event.id},claim.claimId,'processed'))
      throw new Error('event lease lost');
    return result;
  } catch(error) {
    const state=error?.permanent ? 'permanentIgnored' : 'retryableFailure';
    // Never mark a transient failure processed. An expired lease can recover if this write fails.
    if(!await db.finishEvent({provider:event.provider,environment:config.environment,id:event.id},claim.claimId,state,
      error?.permanent ? 'UNRESOLVED_OR_INVALID' : 'STORE_OR_DATABASE_UNAVAILABLE')) throw new Error('event finish unavailable');
    if(error?.permanent) return {state:'IGNORED'};
    throw error;
  }
}
export async function runPeriodic({config,db,apple,google},limit=25) {
  const candidates=await db.claimCandidates(config.environment,Math.min(25,Math.max(1,limit)));
  let processed=0,failed=0;
  for(const item of candidates) {
    try {
      if(!item.identity_hash || !item.user_id) throw new Error('invalid candidate');
      const source=item.platform==='apple' ? await apple.reconcile(item.original_identity,config) :
        await google.reconcile(item.purchase_token,config,undefined,true);
      const currentHash=await fingerprint(source.identity);
      if(currentHash!==item.identity_hash || (source.storeAccountId && source.storeAccountId.toLowerCase()!==item.user_id.toLowerCase()))
        permanent('candidate identity mismatch');
      await reconcileSource(source,config,db,google);
      processed++;
    } catch(_) {failed++;}
  }
  return {claimed:candidates.length,processed,failed};
}
