import { googleState, googleStoreAccount, validateGoogleEnvironment, selectGoogleLine } from './domain.mjs';
const scope = 'https://www.googleapis.com/auth/androidpublisher';
function base64url(data: Uint8Array) { return btoa(String.fromCharCode(...data)).replaceAll('+','-').replaceAll('/','_').replaceAll('=',''); }
async function accessToken() {
  const raw = Deno.env.get('GOOGLE_PLAY_SERVICE_ACCOUNT_JSON');
  if (!raw) throw new Error('Google credentials missing');
  const creds = JSON.parse(raw);
  if (!creds.client_email || !creds.private_key || creds.token_uri !== 'https://oauth2.googleapis.com/token') throw new Error('Google credentials invalid');
  const pem = creds.private_key.replace(/-----[^-]+-----|\s/g,'');
  const der = Uint8Array.from(atob(pem), c => c.charCodeAt(0));
  const key = await crypto.subtle.importKey('pkcs8', der, {name:'RSASSA-PKCS1-v1_5',hash:'SHA-256'}, false, ['sign']);
  const now = Math.floor(Date.now()/1000);
  const header = base64url(new TextEncoder().encode(JSON.stringify({alg:'RS256',typ:'JWT'})));
  const payload = base64url(new TextEncoder().encode(JSON.stringify({iss:creds.client_email,scope,aud:creds.token_uri,iat:now,exp:now+300})));
  const unsigned = header+'.'+payload;
  const signature = base64url(new Uint8Array(await crypto.subtle.sign('RSASSA-PKCS1-v1_5',key,new TextEncoder().encode(unsigned))));
  const body = new URLSearchParams({grant_type:'urn:ietf:params:oauth:grant-type:jwt-bearer',assertion:unsigned+'.'+signature});
  const response = await fetch(creds.token_uri,{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body});
  if (!response.ok) throw new Error('Google OAuth unavailable');
  const token = (await response.json()).access_token;
  if (typeof token !== 'string') throw new Error('Google OAuth unavailable');
  return token;
}
function apiUrl(packageName:string, token:string) {
  return `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${encodeURIComponent(packageName)}/purchases/subscriptionsv2/tokens/${encodeURIComponent(token)}`;
}
export const google = {
  async verify(request: Record<string,string>, config: Record<string,any>) {
    return this.reconcile(request.proof,config,request.productId);
  },
  async reconcile(token:string, config: Record<string,any>, requestedProduct?:string, allowOutOfApp=false) {
    const observedAt = new Date().toISOString();
    const bearer = await accessToken();
    const response = await fetch(apiUrl(config.packageName,token),{headers:{Authorization:`Bearer ${bearer}`}});
    if (response.status === 404 || response.status === 400) throw Object.assign(new Error('invalid token'),{permanent:true});
    if (!response.ok) throw new Error('Play API unavailable');
    const data = await response.json();
    if (data.kind !== 'androidpublisher#subscriptionPurchaseV2' || !Array.isArray(data.lineItems)) throw Object.assign(new Error('invalid Play response'),{permanent:true});
    validateGoogleEnvironment(data, config.environment);
    const ordinaryAccount = googleStoreAccount(data);
    const account = googleStoreAccount(data,{outOfApp:allowOutOfApp});
    if (!account && !allowOutOfApp) throw Object.assign(new Error('unbound Play purchase'),{permanent:true});
    // RTDN/periodic paths may encounter multiple line items during a product
    // replacement. Choose the approved current entitlement period, not array order.
    const line = selectGoogleLine(data.lineItems,requestedProduct,config.products,config.plans);
    if (!line || (data.subscriptionState !== 'SUBSCRIPTION_STATE_PENDING' &&
      (!line.expiryTime || !Number.isFinite(Date.parse(line.expiryTime)))))
      throw Object.assign(new Error('unknown subscription'),{permanent:true});
    const expiry = line.expiryTime ? Date.parse(line.expiryTime) : 0;
    const state = googleState(data.subscriptionState, expiry, !!data.canceledStateContext, Date.now());
    return { platform:'google', environment:config.environment, identity:token, originalIdentity:null,
      productId:line.productId, storeAccountId:account, state,
      validFrom:data.startTime ?? null, validUntil:expiry ? new Date(expiry).toISOString() : null, token,
      observedAt,previousToken:!ordinaryAccount && allowOutOfApp ? data.outOfAppPurchaseContext?.expiredPurchaseToken ?? null : null,
      acknowledged:data.acknowledgementState === 'ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED' };
  },
  async acknowledge(source: Record<string,any>, config: Record<string,any>) {
    if (!['active','gracePeriod','cancelledButActive'].includes(source.state)) throw new Error('not entitled');
    const bearer = await accessToken();
    // Google currently exposes the acknowledgement write under the v3
    // subscriptions resource even though reads use subscriptionsv2.get.
    const url = `https://androidpublisher.googleapis.com/androidpublisher/v3/applications/${encodeURIComponent(config.packageName)}/purchases/subscriptions/${encodeURIComponent(source.productId)}/tokens/${encodeURIComponent(source.token)}:acknowledge`;
    const response = await fetch(url,{method:'POST',headers:{Authorization:`Bearer ${bearer}`,'Content-Type':'application/json'},body:'{}'});
    if (!response.ok) {
      // A concurrent successful acknowledgement is idempotently confirmed by
      // a fresh subscriptionsv2 read rather than assuming any error means done.
      const check = await fetch(apiUrl(config.packageName,source.token),{headers:{Authorization:`Bearer ${bearer}`}});
      if (!check.ok || (await check.json()).acknowledgementState !== 'ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED') throw new Error('ack pending');
    }
  },
};
