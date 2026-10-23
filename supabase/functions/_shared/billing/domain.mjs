export const entitled = new Set(['active', 'gracePeriod', 'cancelledButActive']);
export function appleSubscription(status, paidExpiryMs, graceExpiryMs, autoRenewStatus, revoked, nowMs) {
  if (revoked || status === 5) return {state:'revoked', validUntilMs:paidExpiryMs};
  if (status === 4) {
    // An incomplete current-status response must not replace a valid source
    // with an invented expiry. The caller retries verification later.
    if (!Number.isFinite(graceExpiryMs) || graceExpiryMs <= 0)
      throw new Error('Apple grace expiry unavailable');
    return {state:graceExpiryMs > nowMs ? 'gracePeriod' : 'expired', validUntilMs:graceExpiryMs};
  }
  if (status === 3) return {state:'billingRetry', validUntilMs:paidExpiryMs};
  if (status === 1 && paidExpiryMs > nowMs)
    return {state:autoRenewStatus === 0 ? 'cancelledButActive' : 'active', validUntilMs:paidExpiryMs};
  return {state:'expired', validUntilMs:paidExpiryMs};
}
export function validateAppleRenewal(renewal, originalId, storeAccountId, environment, products) {
  if (!renewal || renewal.originalTransactionId !== originalId ||
      renewal.environment?.toLowerCase() !== environment ||
      (renewal.appAccountToken && renewal.appAccountToken !== storeAccountId) ||
      (renewal.productId && !products.has(renewal.productId)) ||
      (renewal.autoRenewProductId && !products.has(renewal.autoRenewProductId)))
    throw Object.assign(new Error('unrelated Apple renewal'),{permanent:true});
}
export function googleStoreAccount(data, {outOfApp = false} = {}) {
  const current = data.externalAccountIdentifiers?.obfuscatedExternalAccountId;
  if (current) return current;
  // A previous account identifier is only a re-subscription recovery hint.
  // Ordinary client verification never opts into this fallback.
  return outOfApp ? data.outOfAppPurchaseContext?.expiredExternalAccountIdentifiers?.obfuscatedExternalAccountId ?? null : null;
}
export function validateGoogleEnvironment(data, environment) {
  if ((environment === 'production' && !!data.testPurchase) ||
      (environment === 'sandbox' && !data.testPurchase))
    throw Object.assign(new Error('Play purchase environment mismatch'),{permanent:true});
}
export function selectGoogleLine(items, requestedProduct, products, plans) {
  const eligible=items.filter(item=>(!requestedProduct || item.productId===requestedProduct) &&
    products.has(item.productId) && (plans[item.productId] ?? []).includes(item.offerDetails?.basePlanId));
  eligible.sort((a,b)=>(Date.parse(b.expiryTime ?? '') || 0)-(Date.parse(a.expiryTime ?? '') || 0));
  return eligible[0] ?? null;
}
export function googleState(status, expiryMs, cancelled, nowMs) {
  if (status === 'SUBSCRIPTION_STATE_PENDING') return 'pending';
  if (status === 'SUBSCRIPTION_STATE_IN_GRACE_PERIOD' && expiryMs > nowMs) return 'gracePeriod';
  if (status === 'SUBSCRIPTION_STATE_ON_HOLD') return 'onHold';
  if (status === 'SUBSCRIPTION_STATE_PAUSED') return 'paused';
  if (status === 'SUBSCRIPTION_STATE_CANCELED' && expiryMs > nowMs) return 'cancelledButActive';
  if (status === 'SUBSCRIPTION_STATE_ACTIVE' && expiryMs > nowMs) return cancelled ? 'cancelledButActive' : 'active';
  return 'expired';
}
export function deriveCapability(sources, nowMs, environment) {
  const valid = sources.filter(s => s.environment === environment && entitled.has(s.state) && Date.parse(s.validUntil) > nowMs);
  return { active: valid.length > 0, validUntil: valid.length ? new Date(Math.max(...valid.map(s => Date.parse(s.validUntil)))).toISOString() : null };
}
export function validateBinding(storeAccount, authenticatedAccount, existingAccount) {
  if (!storeAccount || storeAccount.toLowerCase() !== authenticatedAccount.toLowerCase()) return 'ACCOUNT_MISMATCH';
  if (existingAccount && existingAccount !== authenticatedAccount) return 'ACCOUNT_MISMATCH';
  return null;
}
export async function fingerprint(raw) {
  const bytes = new TextEncoder().encode(raw);
  return [...new Uint8Array(await crypto.subtle.digest('SHA-256', bytes))].map(b => b.toString(16).padStart(2,'0')).join('');
}
