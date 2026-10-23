import test from 'node:test';
import assert from 'node:assert/strict';
import { clearOwnedStorage, deleteCloudAccount } from '../deletion.mjs';

const A = '11111111-1111-4111-8111-111111111111';
const B = '22222222-2222-4222-8222-222222222222';
function fixture() {
  const files = new Set([
    `ledger-backups/${A}/one.keevbackup`,
    `ledger-sync-receipts/${A}/r.jpeg`,
    `ledger-backups/${B}/other.keevbackup`,
  ]);
  let failOnce = false;
  const storage = {from(bucket) {return {
    async list(prefix) {return {data:[...files].filter(p=>p.startsWith(`${bucket}/${prefix}/`))
      .map(p=>p.slice(`${bucket}/${prefix}/`.length)).filter(n=>!n.includes('/'))
      .map(name=>({name,id:name})),error:null};},
    async remove(paths) {
      if (failOnce) {failOnce=false;return {error:new Error('offline')};}
      for (const p of paths) files.delete(`${bucket}/${p}`);
      return {error:null};
    },
  };}};
  return {files,storage,failNext(){failOnce=true;}};
}

test('only authenticated account prefixes are cleaned; local storage and another user stay untouched', async () => {
  const f=fixture(); const steps=[];
  const result=await deleteCloudAccount({accountId:A,lastSignInAt:new Date(900000).toISOString(),now:1000000,
    storage:f.storage,progress:async (id,state)=>{assert.equal(id,A);steps.push(state);return state;},
    deleteUser:async id=>{assert.equal(id,A);steps.push('auth');}});
  assert.equal(result,'DELETED');
  assert.deepEqual(steps,['requested','storageCleared','billingMinimized','auth']);
  assert.deepEqual([...f.files],[`ledger-backups/${B}/other.keevbackup`]);
});

test('recent authentication required before any destructive call', async () => {
  let called=false;
  const result=await deleteCloudAccount({accountId:A,lastSignInAt:new Date(1).toISOString(),now:1000000,
    storage:null,progress:()=>{called=true;},deleteUser:()=>{called=true;}});
  assert.equal(result,'REAUTH_REQUIRED');assert.equal(called,false);
});

test('partial storage failure is retryable; auth identity is last', async () => {
  const f=fixture(); f.failNext();let deleted=false;
  const options={accountId:A,lastSignInAt:new Date(900000).toISOString(),now:1000000,
    storage:f.storage,progress:async (_,state)=>state,deleteUser:async ()=>{deleted=true;}};
  await assert.rejects(deleteCloudAccount(options));assert.equal(deleted,false);
  assert.equal(await deleteCloudAccount(options),'DELETED');assert.equal(deleted,true);
  assert.equal(await deleteCloudAccount(options),'DELETED');
});

test('malformed identity cannot traverse Storage prefix', async () => {
  await assert.rejects(clearOwnedStorage(fixture().storage,'../other'));
});
