// Root-anchored Apple verification shared by client, Notifications V2 and recovery.
import { AppStoreServerAPIClient, Environment, SignedDataVerifier, VerificationException, VerificationStatus } from 'npm:@apple/app-store-server-library@3.1.0';
import { Buffer } from 'node:buffer';
import { appleSubscription, validateAppleRenewal } from './domain.mjs';
import {interpretAppleNotice} from './apple_notice.mjs';

function invalid(message:string):never { throw Object.assign(new Error(message),{permanent:true}); }
function context(config:Record<string,any>) {
  const production=config.environment==='production';
  const environment=production ? Environment.PRODUCTION : Environment.SANDBOX;
  const bundle=Deno.env.get('APPLE_BUNDLE_ID');
  const appId=Number(Deno.env.get('APPLE_APP_ID'));
  const privateKey=Deno.env.get('APPLE_IAP_PRIVATE_KEY');
  const keyId=Deno.env.get('APPLE_IAP_KEY_ID');
  const issuerId=Deno.env.get('APPLE_IAP_ISSUER_ID');
  const roots=Deno.env.get('APPLE_ROOT_CERTIFICATES_BASE64');
  if(!bundle || !privateKey || !keyId || !issuerId || !roots || (production && !appId)) throw new Error('Apple configuration missing');
  const verifier=new SignedDataVerifier(roots.split(',').map(x=>Buffer.from(x.trim(),'base64')),true,environment,bundle,production ? appId : undefined);
  const api=new AppStoreServerAPIClient(privateKey.replaceAll('\\n','\n'),keyId,issuerId,bundle,environment);
  async function signed(kind:'transaction'|'renewal'|'notification',jws:string):Promise<any> {
    try {
      if(kind==='transaction') return await verifier.verifyAndDecodeTransaction(jws);
      if(kind==='renewal') return await verifier.verifyAndDecodeRenewalInfo(jws);
      return await verifier.verifyAndDecodeNotification(jws);
    } catch(error) {
      if(error instanceof VerificationException && error.status!==VerificationStatus.RETRYABLE_VERIFICATION_FAILURE)
        invalid('invalid Apple signature');
      throw error;
    }
  }
  return {api,bundle,signed};
}
async function currentSubscription(originalId:string,config:Record<string,any>,ctx:ReturnType<typeof context>,observedAt:string) {
  const statuses=await ctx.api.getAllSubscriptionStatuses(originalId);
  if(statuses.bundleId!==ctx.bundle || statuses.environment?.toLowerCase()!==config.environment) invalid('app mismatch');
  const items=(statuses.data ?? []).flatMap(group=>group.lastTransactions ?? [])
    .filter(item=>item.originalTransactionId===originalId && !!item.signedTransactionInfo);
  const current=await Promise.all(items.map(async item=>({item,transaction:await ctx.signed('transaction',item.signedTransactionInfo!)})));
  const same=current.filter(x=>x.transaction.originalTransactionId===originalId);
  same.sort((a,b)=>(b.transaction.purchaseDate ?? 0)-(a.transaction.purchaseDate ?? 0));
  const chosen=same[0];
  if(!chosen) throw new Error('current Apple subscription unavailable');
  const tx=chosen.transaction;
  if(!tx.appAccountToken || !config.products.has(tx.productId)) invalid('current subscription mismatch');
  if(!chosen.item.signedRenewalInfo) throw new Error('Apple renewal information unavailable');
  const renewal=await ctx.signed('renewal',chosen.item.signedRenewalInfo);
  validateAppleRenewal(renewal,originalId,tx.appAccountToken,config.environment,config.products);
  const period=appleSubscription(chosen.item.status,tx.expiresDate ?? 0,
    renewal.gracePeriodExpiresDate,renewal.autoRenewStatus,!!tx.revocationDate,Date.now());
  return {platform:'apple',environment:config.environment,identity:originalId,originalIdentity:originalId,
    productId:tx.productId!,storeAccountId:tx.appAccountToken!,state:period.state,
    validFrom:new Date(tx.purchaseDate ?? Date.now()).toISOString(),
    validUntil:period.validUntilMs ? new Date(period.validUntilMs).toISOString() : null,
    token:null,acknowledged:true,observedAt};
}
export const apple={
  async verify(request:Record<string,string>,config:Record<string,any>) {
    const observedAt=new Date().toISOString();
    const ctx=context(config);
    let client;
    if(request.proof.split('.').length===3) {
      client=await ctx.signed('transaction',request.proof);
      if(client.transactionId!==request.transactionId || client.productId!==request.productId || !client.appAccountToken)
        invalid('invalid client transaction');
    }
    const result=await ctx.api.getTransactionInfo(request.transactionId);
    if(!result.signedTransactionInfo) throw new Error('Apple transaction information unavailable');
    const verified=await ctx.signed('transaction',result.signedTransactionInfo);
    if(verified.transactionId!==request.transactionId || verified.productId!==request.productId ||
      !verified.originalTransactionId || !verified.appAccountToken || !config.products.has(verified.productId)) invalid('transaction mismatch');
    if(client && (client.originalTransactionId!==verified.originalTransactionId || client.appAccountToken!==verified.appAccountToken))
      invalid('client binding mismatch');
    const source=await currentSubscription(verified.originalTransactionId,config,ctx,observedAt);
    if(source.storeAccountId!==verified.appAccountToken) invalid('subscription binding mismatch');
    return source;
  },
  async reconcile(originalId:string,config:Record<string,any>) {
    const observedAt=new Date().toISOString();
    return currentSubscription(originalId,config,context(config),observedAt);
  },
  async notification(payload:string,config:Record<string,any>) {
    const ctx=context(config);
    const outer=await ctx.signed('notification',payload);
    return interpretAppleNotice(outer,{bundle:ctx.bundle,environment:config.environment,products:config.products,
      verifyTransaction:(jws:string)=>ctx.signed('transaction',jws),verifyRenewal:(jws:string)=>ctx.signed('renewal',jws)});
  },
};
