const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const buckets = ['ledger-backups', 'ledger-sync-receipts'];

// No caller-supplied user ID or Storage path enters this service.
export async function clearOwnedStorage(storage, accountId) {
  if (!uuid.test(accountId)) throw new Error('invalid account identity');
  for (const bucket of buckets) {
    const objects = storage.from(bucket);
    const folders = [accountId];
    let processed = 0;
    while (folders.length) {
      const folder = folders.pop();
      while (true) {
        const { data, error } = await objects.list(folder, { limit: 100, offset: 0 });
        if (error) throw new Error('storage list failed');
        const entries = data ?? [];
        if (!entries.length) break;
        const paths = [];
        for (const entry of entries) {
          const name = entry.name;
          if (!name || name === '.' || name === '..' || name.includes('/') || name.includes('\\')) {
            throw new Error('unsafe storage entry');
          }
          const path = `${folder}/${name}`;
          if (entry.id) paths.push(path);
          else folders.push(path);
        }
        if (paths.length) {
          const removed = await objects.remove(paths);
          if (removed.error) throw new Error('storage remove failed');
        }
        processed += entries.length;
        if (processed > 100000) throw new Error('storage cleanup bound exceeded');
        // Folder-only results are retried after descendants have been removed.
        if (!paths.length) break;
      }
    }
  }
}

export function hasRecentSignIn(lastSignInAt, now = Date.now()) {
  const signedIn = Date.parse(lastSignInAt ?? '');
  return Number.isFinite(signedIn) && signedIn <= now + 60000 && now - signedIn <= 10 * 60 * 1000;
}

export async function deleteCloudAccount({ accountId, lastSignInAt, now = Date.now(), storage, progress, deleteUser }) {
  if (!uuid.test(accountId)) return 'AUTH_REQUIRED';
  if (!hasRecentSignIn(lastSignInAt, now)) {
    return 'REAUTH_REQUIRED';
  }
  await progress(accountId, 'requested');
  await clearOwnedStorage(storage, accountId);
  await progress(accountId, 'storageCleared');
  const state = await progress(accountId, 'billingMinimized');
  if (state !== 'billingMinimized') throw new Error('deletion state incomplete');
  await deleteUser(accountId);
  return 'DELETED';
}
