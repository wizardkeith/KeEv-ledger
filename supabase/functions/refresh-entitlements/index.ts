import { authenticated, configuration, json } from '../_shared/billing/http.ts';
Deno.serve(async request => {
  if (request.method !== 'POST') return json({outcome:'REJECTED'},405);
  try {
    const session = await authenticated(request);
    if (!session) return json({outcome:'AUTH_REQUIRED'},401);
    const entitlement = await session.db.refresh(session.accountId,configuration().environment);
    return json({outcome:'OK',accountId:session.accountId,entitlement});
  } catch (_) { return json({outcome:'TRANSIENT_FAILURE'},503); }
});
