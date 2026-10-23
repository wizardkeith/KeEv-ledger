import { entitled, fingerprint, validateBinding } from './domain.mjs';

// Store adapters return only verified, current store observations. Persistence
// atomically enforces immutable identity binding even under concurrent calls.
export async function verifyPurchase({ request, accountId, config, apple, google, persistence }) {
  if (!request || !['apple','google'].includes(request.platform) ||
      typeof request.proof !== 'string' || request.proof.length < 8 || request.proof.length > 20000 ||
      typeof request.productId !== 'string' || !config.products.has(request.productId))
    return { outcome: 'REJECTED' };
  if (request.accountId && request.accountId !== accountId) return { outcome: 'ACCOUNT_MISMATCH' };
  if (request.platform === 'google' && request.packageId !== config.packageName) return { outcome: 'REJECTED' };
  let source;
  try {
    source = await (request.platform === 'apple' ? apple.verify(request, config) : google.verify(request, config));
  } catch (error) {
    return { outcome: error?.permanent ? 'REJECTED' : 'TRANSIENT_FAILURE' };
  }
  // Apple verifies the submitted historical transaction and the current
  // original-transaction chain separately; the current product can change.
  // A Play token must still match the requested line-item product.
  if (!source || !config.products.has(source.productId) ||
      (request.platform === 'google' && source.productId !== request.productId) ||
      source.environment !== config.environment) return { outcome: 'REJECTED' };
  if (validateBinding(source.storeAccountId, accountId)) return { outcome: 'ACCOUNT_MISMATCH' };
  if (!source.identity || !source.productId || !source.state) return { outcome: 'REJECTED' };
  const identityHash = await fingerprint(source.identity);
  const committed = await persistence.commit({ ...source, identityHash, userId: accountId,
    acknowledged: source.acknowledged ?? false,
    acknowledgementPending: source.platform === 'google' && entitled.has(source.state) && !source.acknowledged });
  if (committed === 'STALE') {
    // A newer concurrent observation may still have Play acknowledgement
    // pending. Retain the local journal and retry with a fresh store read.
    return {outcome:'TRANSIENT_FAILURE'};
  }
  if (committed !== 'COMMITTED') return { outcome: committed === 'ACCOUNT_MISMATCH' ? committed : 'REJECTED' };
  // Only the backend acknowledges Play, after the entitlement transaction.
  let acknowledgementPending = source.platform === 'google' && entitled.has(source.state) && !source.acknowledged;
  if (acknowledgementPending) {
    try {
      await google.acknowledge(source, config);
      await persistence.markAcknowledged(source.platform, source.environment, identityHash);
      acknowledgementPending = false;
    } catch (_) {
      // Durable server pending state survives the failure. Retry the same
      // token on a later client verification, before the store deadline.
    }
  }
  const entitlement = await persistence.refresh(accountId, config.environment);
  return { outcome: entitlement.active ? 'VERIFIED_ACTIVE' :
    source.state === 'pending' ? 'PENDING' : 'VERIFIED_INACTIVE',
    entitlement, acknowledgementPending };
}
