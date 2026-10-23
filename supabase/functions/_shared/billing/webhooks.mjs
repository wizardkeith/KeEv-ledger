export async function readBoundedBody(request,maxBytes=65536) {
  if(!request.body) throw Error('empty body');
  const reader=request.body.getReader(),chunks=[];let size=0;
  try {
    while(true) {
      const {done,value}=await reader.read();if(done) break;
      size+=value.byteLength;if(size>maxBytes) throw Error('request too large');
      chunks.push(value);
    }
  } catch(error) {
    await reader.cancel().catch(()=>{});
    throw error;
  } finally {reader.releaseLock();}
  const bytes=new Uint8Array(size);let offset=0;
  for(const chunk of chunks) {bytes.set(chunk,offset);offset+=chunk.byteLength;}
  return new TextDecoder('utf-8',{fatal:true}).decode(bytes);
}
export function parseAppleBody(body) {
  if(typeof body!=='string' || new TextEncoder().encode(body).length>65536) throw Error('invalid Apple body');
  let value;try {value=JSON.parse(body);}catch(_) {throw Error('invalid Apple JSON');}
  if(!value || typeof value.signedPayload!=='string' || value.signedPayload.length<32 || value.signedPayload.length>60000 ||
     !/^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$/.test(value.signedPayload)) throw Error('invalid Apple JWS');
  return value.signedPayload;
}
export function validateGoogleClaims(payload,audience,email,nowSeconds=Math.floor(Date.now()/1000)) {
  if(!audience || !email || !['accounts.google.com','https://accounts.google.com'].includes(payload.iss) ||
    payload.aud!==audience || payload.email!==email || payload.email_verified!==true ||
    !Number.isFinite(payload.exp) || payload.exp<=nowSeconds ||
    !Number.isFinite(payload.iat) || payload.iat>nowSeconds+60)
    throw Error('invalid Pub/Sub identity');
}
export async function verifyPushIdentity(token,verifyJwt,audience,email) {
  // verifyJwt must cryptographically validate the Google JWKS, issuer,
  // audience, algorithm and standard JWT time claims before returning.
  const payload=await verifyJwt(token,audience);
  validateGoogleClaims(payload,audience,email);
}
export function parsePubSubBody(body,packageName) {
  if(typeof body!=='string' || new TextEncoder().encode(body).length>65536) throw Error('invalid Pub/Sub body');
  let envelope;try {envelope=JSON.parse(body);}catch(_) {throw Error('invalid Pub/Sub JSON');}
  const msg=envelope?.message;
  if(!msg || typeof msg.messageId!=='string' || !/^[A-Za-z0-9_-]{1,256}$/.test(msg.messageId) ||
    typeof msg.data!=='string' || msg.data.length<4 || msg.data.length>40000 ||
    !/^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$/.test(msg.data)) throw Error('invalid Pub/Sub envelope');
  let decoded;try {decoded=JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(Uint8Array.from(atob(msg.data),c=>c.charCodeAt(0))));}
  catch(_) {throw Error('invalid RTDN data');}
  const milliseconds=decoded?.eventTimeMillis===undefined ? Date.parse(msg.publishTime) : Number(decoded.eventTimeMillis);
  if(decoded?.packageName!==packageName || !Number.isFinite(milliseconds) || milliseconds<=0 || milliseconds>8640000000000000)
    throw Error('invalid RTDN package/time');
  const eventTime=new Date(milliseconds).toISOString();
  if(decoded.testNotification && !decoded.subscriptionNotification) return {provider:'google',id:msg.messageId,time:eventTime,type:'testNotification',identity:null};
  const notice=decoded.subscriptionNotification;
  if(!notice || decoded.testNotification || typeof notice.purchaseToken!=='string' || notice.purchaseToken.length<8 ||
    notice.purchaseToken.length>4096 || !Number.isInteger(notice.notificationType)) throw Error('invalid subscription RTDN');
  return {provider:'google',id:msg.messageId,time:eventTime,type:`subscription.${notice.notificationType}`,identity:notice.purchaseToken};
}
