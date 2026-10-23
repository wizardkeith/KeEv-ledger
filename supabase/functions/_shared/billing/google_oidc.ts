import {createRemoteJWKSet,jwtVerify} from 'npm:jose@6.1.3';
import {verifyPushIdentity} from './webhooks.mjs';
const keys=createRemoteJWKSet(new URL('https://www.googleapis.com/oauth2/v3/certs'));
export async function authenticatePubSub(request:Request) {
  const audience=Deno.env.get('BILLING_PUBSUB_AUDIENCE');
  const email=Deno.env.get('BILLING_PUBSUB_PUSH_SERVICE_ACCOUNT');
  const bearer=request.headers.get('authorization')?.match(/^Bearer ([A-Za-z0-9._-]+)$/i)?.[1];
  if(!audience || !email || !bearer || bearer.length>8192) throw Error('Pub/Sub authentication missing');
  await verifyPushIdentity(bearer,async (token:string,expectedAudience:string)=>{
    const {payload}=await jwtVerify(token,keys,{issuer:['accounts.google.com','https://accounts.google.com'],audience:expectedAudience,
      algorithms:['RS256'],clockTolerance:30});
    return payload;
  },audience,email);
}
