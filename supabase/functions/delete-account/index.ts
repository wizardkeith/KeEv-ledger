import { createClient } from 'npm:@supabase/supabase-js@2.57.0';
import { deleteCloudAccount } from '../_shared/account_deletion/deletion.mjs';
import {prepareAppleDeletion} from '../_shared/account_deletion/apple_deletion.mjs';
import {verifyAppleDeletionIdentity,exchangeAppleDeletionCode,revokeAppleDeletionToken}
  from '../_shared/account_deletion/apple_revoke.ts';

const reply = (status:string, code=200) => new Response(JSON.stringify({status}),
  {status:code,headers:{'content-type':'application/json','cache-control':'no-store'}});
async function boundedBody(request:Request) {
  const reader=request.body?.getReader();
  if (!reader) return '';
  let size=0;
  const chunks:Uint8Array[]=[];
  while (true) {
    const {done,value}=await reader.read();
    if (done) break;
    size+=value.byteLength;
    if (size>12288) {await reader.cancel();throw new Error('body too large');}
    chunks.push(value);
  }
  const body=new Uint8Array(size);let offset=0;
  for (const chunk of chunks) {body.set(chunk,offset);offset+=chunk.byteLength;}
  return new TextDecoder('utf-8',{fatal:true}).decode(body);
}

Deno.serve(async request => {
  if (request.method !== 'POST') return reply('INVALID_REQUEST',405);
  if (Number(request.headers.get('content-length') ?? 0) > 12288) return reply('INVALID_REQUEST',413);
  const jwt = request.headers.get('authorization')?.match(/^Bearer (.+)$/i)?.[1];
  if (!jwt) return reply('AUTH_REQUIRED',401);
  const url = Deno.env.get('SUPABASE_URL');
  const anon = Deno.env.get('SUPABASE_ANON_KEY');
  const service = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!url || !anon || !service) return reply('TEMPORARY_FAILURE',503);
  try {
    const userClient = createClient(url,anon,{auth:{persistSession:false}});
    const {data,error} = await userClient.auth.getUser(jwt);
    if (error || !data.user) return reply('AUTH_REQUIRED',401);
    // The credential is memory-only and never enters deletion progress or logs.
    let raw;
    try {raw=await boundedBody(request);} catch (_) {return reply('INVALID_REQUEST',413);}
    let credential;
    try { credential = JSON.parse(raw); }
    catch (_) { return reply('INVALID_REQUEST',400); }
    if (!credential || typeof credential !== 'object' || Array.isArray(credential))
      return reply('INVALID_REQUEST',400);
    const appleStatus = await prepareAppleDeletion({user:data.user,credential,
      verifyIdentity:verifyAppleDeletionIdentity,exchangeCode:exchangeAppleDeletionCode,
      revokeToken:revokeAppleDeletionToken});
    if (appleStatus !== 'READY') return reply(appleStatus,
      appleStatus === 'TEMPORARY_FAILURE' ? 503 : 200);
    const admin = createClient(url,service,{auth:{persistSession:false}});
    const progress = async (userId:string,state:string) => {
      const {data,error} = await admin.rpc('account_deletion_progress_v1',{p_user_id:userId,p_state:state});
      if (error || !data || data === 'REJECTED') throw new Error('deletion progress failed');
      return data;
    };
    const status = await deleteCloudAccount({accountId:data.user.id,
      lastSignInAt:data.user.last_sign_in_at,storage:admin.storage,progress,
      deleteUser:async (userId:string) => {
        const {error} = await admin.auth.admin.deleteUser(userId);
        if (error) throw new Error('auth deletion failed');
      }});
    // A valid but old session gets a typed response the mobile client can
    // present without depending on platform exception parsing for HTTP 403.
    return reply(status);
  } catch (_) { return reply('TEMPORARY_FAILURE',503); }
});
