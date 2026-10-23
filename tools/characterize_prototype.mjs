// Read-only characterization of the supplied prototype, not production Flutter tests.
// Usage: node tools/characterize_prototype.mjs /absolute/path/to/prototype
import { readFile, writeFile, mkdtemp, rm } from 'node:fs/promises';
import { join, resolve } from 'node:path';
import { tmpdir } from 'node:os';
import { pathToFileURL } from 'node:url';
import { stripTypeScriptTypes } from 'node:module';
import assert from 'node:assert/strict';
const root = resolve(process.argv[2] ?? '../prototype');
const dir = await mkdtemp(join(tmpdir(), 'keev-characterization-'));
const results=[];
try {
  // A tiny UID-only shim satisfies unused constructors without installing React/CSS packages.
  await writeFile(join(dir,'utils.mjs'), 'export const uid = () => crypto.randomUUID();');
  for (const name of ['types','categories','accounts','projects','i18n','reports','fx','parse-voice','offline','local-db']) {
    const source=await readFile(join(root,'src/lib',name+'.ts'),'utf8');
    const js=stripTypeScriptTypes(source).replace(/from "\.\/([\w-]+)"/g,'from "./$1.mjs"');
    await writeFile(join(dir,name+'.mjs'),js);
  }
  const mod=async name=>import(pathToFileURL(join(dir,name+'.mjs')));
  const accounts=await mod('accounts'), reports=await mod('reports'), fx=await mod('fx');
  const voice=await mod('parse-voice'), offline=await mod('offline'), backup=await mod('local-db');
  const types=await mod('types');
  const store=new Map();
  globalThis.localStorage={getItem:k=>store.get(k)??null,setItem:(k,v)=>store.set(k,v),removeItem:k=>store.delete(k)};
  const account=(id,currency='HKD',kind='asset')=>({id,currency,kind,type:kind==='asset'?'cash':'credit_card',name:id,openingBalance:0,archived:false});
  const tx=(changes={})=>({id:'t1',type:'expense',amount:85,currency:'HKD',category:'food',note:'',occurredAt:'2026-09-19',createdAt:'2026-09-19T00:00:00Z',accountId:'cash',...changes});
  function check(id,meaning,run){try {const observation=run();results.push({id,status:'REPRODUCED',meaning,observation});}catch(e){results.push({id,status:'FAILED_TO_REPRODUCE',meaning,error:e.message});process.exitCode=1;}}
  check('C01','Same-currency transfer is excluded from income/expense',()=>{
    const t=tx({type:'transfer',amount:100,transferAccountId:'bank'});
    assert.equal(accounts.accountDelta(account('cash'),t),-100);
    assert.equal(accounts.accountDelta(account('bank'),t),100);
    assert.equal(reports.sumBy([t],'expense'),0);assert.equal(reports.sumBy([t],'income'),0);
    return 'preservable behaviour';
  });
  check('C02','Cross-currency transfer applies HKD numeral unchanged to USD',()=>{
    const delta=accounts.accountDelta(account('usd','USD'),tx({type:'transfer',amount:780,transferAccountId:'usd'}));
    assert.equal(delta,780);return {observedUsd:delta,desiredUsdForExample:100};
  });
  check('C03','Archiving funded account removes it from net worth',()=>{
    const a={...account('cash'),openingBalance:100};
    assert.equal(accounts.netWorth([a],[]).net,100);
    assert.equal(accounts.netWorth([{...a,archived:true}],[]).net,0);return '100 → 0 without spending';
  });
  check('C04','Absent exchange rate silently returns original amount',()=>{
    const converted=fx.convertAmount(100,'USD','HKD',{});assert.equal(converted,100);return converted;
  });
  check('C05','Cantonese numeral 八十五 not parsed as amount',()=>{
    const parsed=voice.parseVoiceLocal('今日午餐八十五蚊');assert.equal(parsed.amount,undefined);assert.equal(parsed.category,'food');return parsed;
  });
  check('C06','Unknown backup version accepted',()=>{
    const parsed=backup.parseSnapshot(JSON.stringify({version:999,profile:{},transactions:[],budgets:[]}));
    assert.ok(parsed);return 'version 999 accepted';
  });
  check('C07','Prototype privilege helper overrides unpaid state',()=>{
    const result=types.withAllFeatures({...types.DEFAULT_PROFILE,adsRemoved:false,reportsUnlocked:false});
    assert.equal(result.adsRemoved,true);assert.equal(result.reportsUnlocked,true);return 'both unlocked';
  });
  check('C08','Hard-deleted remote row resurrects from stale local copy',()=>{
    const rows=offline.mergeById([],[tx()],[],[]);assert.equal(rows.length,1);return 'local-only copy retained';
  });
  check('C09','Queue clear after snapshot loses later operation',()=>{
    offline.enqueueUpsertTx('user',tx());const snapshot=offline.loadPending('user');
    offline.enqueueUpsertTx('user',tx({id:'t2'}));assert.equal(snapshot.upsertTx.length,1);
    offline.clearPending('user');assert.equal(offline.loadPending('user').upsertTx.length,0);return 't2 removed without acknowledgement';
  });
  check('C10','Category CSV adds different currencies nominally',()=>{
    const csv=reports.categoryLedgerCsv('food','expense',[tx({amount:10}),tx({id:'t2',amount:10,currency:'JPY'})],'en',[]);
    assert.ok(csv.endsWith(',20.00'));return 'HKD 10 + JPY 10 → 20.00';
  });
  check('C11','Credit card payment reduces debt and does not add expense',()=>{
    const t=tx({type:'transfer',amount:200,transferAccountId:'card'});
    assert.equal(accounts.accountDelta(account('card','HKD','liability'),t),-200);assert.equal(reports.sumBy([t],'expense'),0);return 'preservable behaviour';
  });
  check('C12','Range CSV misses pre-range balance',()=>{
    const a={...account('cash'),openingBalance:100};
    const before=tx({amount:20,occurredAt:'2026-08-31'}),within=tx({amount:10});
    const displayed=accounts.accountBalance(a,[before,within]);
    const csv=reports.accountLedgerCsv(a,[within],'en',[a]);
    assert.equal(displayed,70);assert.ok(csv.includes('90.00'));return {correctBalance:70,rangeCsvBalance:90};
  });
  console.log(JSON.stringify({purpose:'characterization, not correctness approval',node:process.version,results},null,2));
} finally {await rm(dir,{recursive:true,force:true});}
