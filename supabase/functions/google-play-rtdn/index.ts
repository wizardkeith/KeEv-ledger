import {json} from '../_shared/billing/http.ts';
import {billingAdmin} from '../_shared/billing/admin.ts';
import {parsePubSubBody,readBoundedBody} from '../_shared/billing/webhooks.mjs';
import {processProviderEvent} from '../_shared/billing/lifecycle.mjs';
import {authenticatePubSub} from '../_shared/billing/google_oidc.ts';
import {apple} from '../_shared/billing/apple.ts';
import {google} from '../_shared/billing/google.ts';
Deno.serve(async request=>{
  if(request.method!=='POST') return json({outcome:'REJECTED'},405);
  try {await authenticatePubSub(request);}catch(_) {return json({outcome:'UNAUTHORIZED'},401);}
  if(Number(request.headers.get('content-length') ?? 0)>65536) return json({outcome:'REJECTED'},413);
  let event;
  try {event=parsePubSubBody(await readBoundedBody(request),Deno.env.get('GOOGLE_PLAY_PACKAGE_NAME'));}
  catch(_) {return json({outcome:'REJECTED'},400);}
  try {
    const {config,db}=billingAdmin();
    await processProviderEvent(event,{config,db,apple,google});
    return json({outcome:'OK'});
  } catch(_) {return json({outcome:'UNAVAILABLE'},503);}
});
