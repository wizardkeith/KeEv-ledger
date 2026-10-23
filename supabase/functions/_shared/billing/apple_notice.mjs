import {validateAppleRenewal} from './domain.mjs';
function invalid(message) {throw Object.assign(new Error(message),{permanent:true});}
// The outer JWS has already been verified. Each nested JWS is independently
// verified by the supplied SignedDataVerifier methods before reading fields.
export async function interpretAppleNotice(outer,{bundle,environment,products,verifyTransaction,verifyRenewal}) {
  if(!outer.notificationUUID || !Number.isFinite(outer.signedDate) || outer.version!=='2.0') invalid('invalid V2 notification');
  if(outer.notificationType==='TEST') return {id:outer.notificationUUID,time:outer.signedDate,type:'TEST',subtype:null,originalId:null,accountId:null};
  const data=outer.data;
  if(!data || data.bundleId!==bundle || data.environment?.toLowerCase()!==environment) invalid('notification app mismatch');
  const transaction=data.signedTransactionInfo ? await verifyTransaction(data.signedTransactionInfo) : null;
  const renewal=data.signedRenewalInfo ? await verifyRenewal(data.signedRenewalInfo) : null;
  if(transaction && renewal && (transaction.originalTransactionId!==renewal.originalTransactionId ||
    (renewal.appAccountToken && renewal.appAccountToken!==transaction.appAccountToken))) invalid('nested identity mismatch');
  const originalId=transaction?.originalTransactionId ?? renewal?.originalTransactionId ?? null;
  const accountId=transaction?.appAccountToken ?? renewal?.appAccountToken ?? null;
  if(renewal && originalId && accountId) validateAppleRenewal(renewal,originalId,accountId,environment,products);
  if(transaction && !products.has(transaction.productId)) invalid('unknown Apple product');
  return {id:outer.notificationUUID,time:outer.signedDate,type:outer.notificationType ?? 'UNKNOWN',
    subtype:outer.subtype ?? null,originalId,accountId};
}
