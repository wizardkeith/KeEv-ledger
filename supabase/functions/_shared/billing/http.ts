import { createClient } from 'npm:@supabase/supabase-js@2.57.0';
import { persistence } from './persistence.ts';
export async function authenticated(request:Request) {
  const jwt = request.headers.get('authorization')?.match(/^Bearer (.+)$/i)?.[1];
  if (!jwt) return null;
  const url = Deno.env.get('SUPABASE_URL');
  const anon = Deno.env.get('SUPABASE_ANON_KEY');
  const server = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!url || !anon || !server) throw new Error('Supabase configuration missing');
  const auth = createClient(url,anon,{global:{headers:{Authorization:`Bearer ${jwt}`}},auth:{persistSession:false}});
  const {data,error} = await auth.auth.getUser(jwt);
  if (error || !data.user?.id) return null;
  const admin = createClient(url,server,{auth:{persistSession:false}});
  return {accountId:data.user.id,db:persistence(admin)};
}
export function configuration() {
  const environment = Deno.env.get('BILLING_ENVIRONMENT');
  const products = (Deno.env.get('BILLING_PREMIUM_PRODUCT_IDS') ?? '').split(',').map(x=>x.trim()).filter(Boolean);
  const plans = JSON.parse(Deno.env.get('GOOGLE_APPROVED_BASE_PLANS_JSON') ?? '{}');
  const packageName = Deno.env.get('GOOGLE_PLAY_PACKAGE_NAME');
  if (!['production','sandbox'].includes(environment ?? '') || !products.length || !packageName) throw new Error('Billing configuration incomplete');
  return {environment,products:new Set(products),plans,packageName};
}
export const json = (data:object,status=200) => new Response(JSON.stringify(data),{status,headers:{'content-type':'application/json','cache-control':'no-store'}});
