import {createRemoteJWKSet, importPKCS8, jwtVerify, SignJWT} from 'npm:jose@6.1.3';

const appleKeys = createRemoteJWKSet(new URL('https://appleid.apple.com/auth/keys'));
const issuer = 'https://appleid.apple.com';
function appleError(code:string) {return Object.assign(new Error('Apple authorization failed'),{code});}

function configuration() {
  const team = Deno.env.get('APPLE_SIGNIN_TEAM_ID');
  const keyId = Deno.env.get('APPLE_SIGNIN_KEY_ID');
  const privateKey = Deno.env.get('APPLE_SIGNIN_PRIVATE_KEY');
  const allowed = (Deno.env.get('APPLE_SIGNIN_ALLOWED_CLIENT_IDS') ?? '')
    .split(',').map(s => s.trim()).filter(Boolean);
  if (!team || !keyId || !privateKey || !allowed.length) throw new Error('Apple sign-in configuration unavailable');
  const redirects = JSON.parse(Deno.env.get('APPLE_SIGNIN_REDIRECT_URIS_JSON') || '{}');
  if (typeof redirects !== 'object' || redirects === null || Array.isArray(redirects)) {
    throw new Error('Apple redirect mapping unavailable');
  }
  return {team,keyId,privateKey,allowed,redirects};
}

export async function verifyAppleDeletionIdentity(token:string, rawNonce:string) {
  const {allowed} = configuration();
  const {payload} = await jwtVerify(token, appleKeys, {
    issuer, audience:allowed, algorithms:['RS256'],
  });
  const nonceBytes = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(rawNonce));
  const nonce = [...new Uint8Array(nonceBytes)].map(n => n.toString(16).padStart(2,'0')).join('');
  if (!payload.sub || typeof payload.aud !== 'string' || payload.nonce !== nonce ||
      !allowed.includes(payload.aud)) throw new Error('Apple identity invalid');
  return {subject:payload.sub,clientId:payload.aud};
}

async function clientSecret(clientId:string) {
  const {team,keyId,privateKey,allowed} = configuration();
  if (!allowed.includes(clientId)) throw new Error('Apple client not allowed');
  const key = await importPKCS8(privateKey.replace(/\\n/g,'\n'),'ES256');
  return new SignJWT({}).setProtectedHeader({alg:'ES256',kid:keyId})
    .setIssuer(team).setSubject(clientId).setAudience(issuer)
    .setIssuedAt().setExpirationTime('5m').sign(key);
}

async function applePost(path:string, fields:Record<string,string>) {
  const response = await fetch(`${issuer}/auth/${path}`,{
    method:'POST',headers:{'content-type':'application/x-www-form-urlencoded'},
    body:new URLSearchParams(fields),signal:AbortSignal.timeout(10000),
  });
  if (!response.ok) throw appleError(path === 'token' && response.status === 400
    ? 'APPLE_REAUTH_REQUIRED' : 'TEMPORARY_FAILURE');
  return response;
}

export async function exchangeAppleDeletionCode(code:string, clientId:string, expectedSubject:string) {
  const {redirects} = configuration();
  const fields:Record<string,string> = {client_id:clientId,
    client_secret:await clientSecret(clientId),code,grant_type:'authorization_code'};
  if (Object.hasOwn(redirects,clientId)) {
    const redirect = redirects[clientId];
    if (typeof redirect !== 'string' || !redirect.startsWith('https://')) {
      throw new Error('Apple redirect configuration invalid');
    }
    fields.redirect_uri = redirect;
  }
  const result = await (await applePost('token',fields)).json();
  if (typeof result.id_token !== 'string') throw new Error('Apple exchange identity missing');
  const {payload} = await jwtVerify(result.id_token,appleKeys,{
    issuer,audience:clientId,algorithms:['RS256'],
  });
  if (payload.sub !== expectedSubject) throw appleError('ACCOUNT_MISMATCH');
  if (typeof result.refresh_token === 'string' && result.refresh_token) {
    return {value:result.refresh_token,type:'refresh_token'};
  }
  if (typeof result.access_token === 'string' && result.access_token) {
    return {value:result.access_token,type:'access_token'};
  }
  throw new Error('Apple token response invalid');
}

export async function revokeAppleDeletionToken(token:{value:string,type:string}, clientId:string) {
  await applePost('revoke',{client_id:clientId,client_secret:await clientSecret(clientId),
    token:token.value,token_type_hint:token.type});
}
