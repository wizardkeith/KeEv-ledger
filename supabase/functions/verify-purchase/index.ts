import { authenticated, configuration, json } from '../_shared/billing/http.ts';
import { apple } from '../_shared/billing/apple.ts';
import { google } from '../_shared/billing/google.ts';
import { verifyPurchase } from '../_shared/billing/core.mjs';
Deno.serve(async request => {
  if (request.method !== 'POST') return json({outcome:'REJECTED'},405);
  try {
    const session = await authenticated(request);
    if (!session) return json({outcome:'AUTH_REQUIRED'},401);
    const body = await request.json();
    const result = await verifyPurchase({request:body,accountId:session.accountId,config:configuration(),apple,google,persistence:session.db});
    return json({...result,accountId:session.accountId});
  } catch (_) { return json({outcome:'TRANSIENT_FAILURE'},503); }
});
