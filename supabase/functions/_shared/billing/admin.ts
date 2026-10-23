import {createClient} from 'npm:@supabase/supabase-js@2.57.0';
import {configuration} from './http.ts';
import {persistence} from './persistence.ts';
export function billingAdmin() {
  const url=Deno.env.get('SUPABASE_URL');
  const key=Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if(!url || !key) throw Error('billing admin unavailable');
  return {config:configuration(),db:persistence(createClient(url,key,{auth:{persistSession:false}}))};
}
export async function internalScheduleAuthorized(request:Request) {
  const expected=Deno.env.get('BILLING_RECONCILE_SECRET');
  const supplied=request.headers.get('authorization')?.match(/^Bearer (.+)$/i)?.[1] ?? '';
  if(!expected || expected.length<32 || supplied.length>512) return false;
  const digest=async (s:string)=>new Uint8Array(await crypto.subtle.digest('SHA-256',new TextEncoder().encode(s)));
  const a=await digest(expected),b=await digest(supplied);
  let difference=0;for(let i=0;i<a.length;i++) difference|=a[i]^b[i];
  return difference===0;
}
