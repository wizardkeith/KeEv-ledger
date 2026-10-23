import {hasRecentSignIn} from './deletion.mjs';

const nonempty = value => typeof value === 'string' && value.length > 0;

// Identity.id is the Supabase provider ID; identity_id is the internal row UUID.
// If identity_data.sub is present, it must agree with the provider ID.
export function appleSubjects(identities) {
  return (identities ?? []).filter(i => i.provider === 'apple').map(i => {
    const providerId = i.provider_id ?? i.id;
    const subject = i.identity_data?.sub ?? providerId;
    if (!nonempty(subject) || (nonempty(i.identity_data?.sub) &&
        nonempty(providerId) && i.identity_data.sub !== providerId)) return null;
    return subject;
  });
}

export async function prepareAppleDeletion({user, credential, verifyIdentity, exchangeCode,
  revokeToken, now = Date.now()}) {
  if (!hasRecentSignIn(user.last_sign_in_at, now)) return 'REAUTH_REQUIRED';
  // Never infer "no Apple link" from an incomplete Auth user response.
  if (!Array.isArray(user.identities)) return 'APPLE_REAUTH_REQUIRED';
  const subjects = appleSubjects(user.identities);
  if (user.app_metadata?.providers?.includes('apple') && !subjects.length)
    return 'APPLE_REAUTH_REQUIRED';
  if (!subjects.length) return 'READY';
  if (subjects.some(subject => !subject) || subjects.length !== 1) return 'APPLE_REAUTH_REQUIRED';
  if (!credential || !nonempty(credential.appleIdentityToken) ||
      !nonempty(credential.appleAuthorizationCode) || !nonempty(credential.appleRawNonce)) {
    return 'APPLE_REAUTH_REQUIRED';
  }
  let verified;
  try {
    verified = await verifyIdentity(credential.appleIdentityToken, credential.appleRawNonce);
  } catch (_) { return 'APPLE_REAUTH_REQUIRED'; }
  if (verified.subject !== subjects[0]) return 'ACCOUNT_MISMATCH';
  let token;
  try {
    token = await exchangeCode(credential.appleAuthorizationCode, verified.clientId, verified.subject);
  } catch (error) { return error?.code === 'ACCOUNT_MISMATCH' ? 'ACCOUNT_MISMATCH' :
    error?.code === 'APPLE_REAUTH_REQUIRED' ? 'APPLE_REAUTH_REQUIRED' : 'TEMPORARY_FAILURE'; }
  if (!token || !nonempty(token.value) || !['refresh_token','access_token'].includes(token.type)) {
    return 'TEMPORARY_FAILURE';
  }
  try {
    await revokeToken(token, verified.clientId);
  } catch (_) { return 'TEMPORARY_FAILURE'; }
  return 'READY';
}
