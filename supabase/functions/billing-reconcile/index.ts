import {json} from '../_shared/billing/http.ts';
import {billingAdmin,internalScheduleAuthorized} from '../_shared/billing/admin.ts';
import {runPeriodic} from '../_shared/billing/lifecycle.mjs';
import {apple} from '../_shared/billing/apple.ts';
import {google} from '../_shared/billing/google.ts';
Deno.serve(async request=>{
  if(request.method!=='POST') return json({outcome:'REJECTED'},405);
  if(!await internalScheduleAuthorized(request)) return json({outcome:'UNAUTHORIZED'},401);
  try {return json({outcome:'OK',...await runPeriodic({...billingAdmin(),apple,google},25)});}
  catch(_) {return json({outcome:'UNAVAILABLE'},503);}
});
