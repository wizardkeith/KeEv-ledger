import {json} from '../_shared/billing/http.ts';
import {billingAdmin} from '../_shared/billing/admin.ts';
import {parseAppleBody,readBoundedBody} from '../_shared/billing/webhooks.mjs';
import {processProviderEvent} from '../_shared/billing/lifecycle.mjs';
import {apple} from '../_shared/billing/apple.ts';
import {google} from '../_shared/billing/google.ts';
Deno.serve(async request=>{
  if(request.method!=='POST') return json({outcome:'REJECTED'},405);
  if(Number(request.headers.get('content-length') ?? 0)>65536) return json({outcome:'REJECTED'},413);
  let payload:string;
  try {payload=parseAppleBody(await readBoundedBody(request));}
  catch(_) {return json({outcome:'REJECTED'},400);}
  try {
    const {config,db}=billingAdmin();
    const notice=await apple.notification(payload,config); // verifies outer and nested JWS before any event write
    await processProviderEvent({provider:'apple',id:notice.id,time:new Date(notice.time).toISOString(),
      type:notice.type,identity:notice.originalId,accountId:notice.accountId},{config,db,apple,google});
    return json({outcome:'OK'});
  } catch(error) {return json({outcome:'UNAVAILABLE'},error?.permanent ? 400 : 503);}
});
