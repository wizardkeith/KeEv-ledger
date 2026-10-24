#!/usr/bin/env python3
"""Repository checks only; native merged manifests and deployed RLS need CI/live review."""
from pathlib import Path
import re
import plistlib
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
read = lambda p: (root / p).read_text()
manifest = ET.parse(root / 'android/app/src/main/AndroidManifest.xml').getroot()
android = '{http://schemas.android.com/apk/res/android}'
permissions = {node.get(android+'name') for node in manifest.findall('uses-permission')}
assert permissions <= {'android.permission.RECORD_AUDIO','android.permission.INTERNET',
                        'android.permission.ACCESS_NETWORK_STATE','android.permission.USE_BIOMETRIC'}
app = manifest.find('application')
assert app.get(android+'allowBackup') == 'false'
assert app.get(android+'usesCleartextTraffic') != 'true'
for component in app:
    if component.tag in {'service','receiver','provider'}:
        assert component.get(android+'exported') != 'true'
assert app.find('activity').get(android+'exported') == 'true'
ET.parse(root / 'android/app/src/main/res/xml/data_extraction_rules.xml')
privacy = plistlib.loads((root/'ios/Runner/PrivacyInfo.xcprivacy').read_bytes())
assert privacy['NSPrivacyTracking'] is False
expected = {'Name','EmailAddress','UserID','DeviceID','OtherFinancialInfo',
            'PhotosorVideos','OtherUserContent','PurchaseHistory'}
collected = privacy['NSPrivacyCollectedDataTypes']
assert {entry['NSPrivacyCollectedDataType'].removeprefix('NSPrivacyCollectedDataType')
        for entry in collected} == expected
for entry in collected:
    assert entry['NSPrivacyCollectedDataTypeLinked'] is True
    assert entry['NSPrivacyCollectedDataTypeTracking'] is False
    assert entry['NSPrivacyCollectedDataTypePurposes'] == [
        'NSPrivacyCollectedDataTypePurposeAppFunctionality']
assert 'NSPrivacyAccessedAPITypes' not in privacy
assert 'NSAllowsArbitraryLoads' not in read('ios/Runner/Info.plist')
assert 'PrivacyInfo.xcprivacy in Resources' in read('ios/Runner.xcodeproj/project.pbxproj')
cfg=read('supabase/config.toml')
for name in ('delete-account','verify-purchase','refresh-entitlements'):
    assert re.search(r'\[functions\.'+name+r'\]\s*verify_jwt = true',cfg)
for name in ('apple-store-notifications','google-play-rtdn'):
    assert re.search(r'\[functions\.'+name+r'\]\s*verify_jwt = false',cfg)
sql='\n'.join(p.read_text() for p in (root/'supabase/migrations').glob('*.sql'))
assert "bucket_id = 'ledger-backups'" in sql and "bucket_id='ledger-sync-receipts'" in sql
assert 'alter table public.billing_entitlements enable row level security' in sql
assert 'revoke all on billing_private.deleted_purchase_tombstones from public, anon, authenticated' in sql
assert 'revoke all on function public.account_deletion_progress_v1(uuid,text) from public, anon, authenticated' in sql
assert 'grant execute on function public.account_deletion_progress_v1(uuid,text) to service_role' in sql
assert "exists (select 1 from auth.users u where u.id=(select auth.uid()))" in sql
assert sql.count('and public.account_can_upload_v1()') == 2
assert 'create trigger reject_deleted_purchase' in sql
assert "references auth.users(id) on delete cascade" in sql
assert "defaultValue: false" in read('lib/app/bootstrap.dart') or "defaultValue: false" in read('lib/app/environment.dart')
assert 'persistSession: false' in read('lib/features/account/infrastructure/supabase/supabase_runtime.dart')
assert 'billingDescription: product.description' not in read('lib/features/purchases/infrastructure/flutter_store_gateway.dart')
deletion=read('supabase/functions/delete-account/index.ts')
assert 'auth.getUser(jwt)' in deletion and 'accountId:data.user.id' in deletion
assert deletion.index('prepareAppleDeletion(') < deletion.index('deleteCloudAccount(')
assert 'verifyAppleDeletionIdentity' in deletion and 'revokeAppleDeletionToken' in deletion
assert 'credential.appleAuthorizationCode' in read('supabase/functions/_shared/account_deletion/apple_deletion.mjs')
assert 'authorizationCode: credential.authorizationCode' in read('lib/features/account/infrastructure/supabase/native_identity_providers.dart')
assert 'request.json()' not in deletion and "admin.auth.admin.deleteUser(userId)" in deletion
assert "accountId:data.user.id" in deletion
assert 'widget.controller.deleteAccount()' in read('lib/features/account/presentation/account_screen.dart')
assert 'widget.syncController?.unlink()' in read('lib/features/account/presentation/account_screen.dart')
assert re.search(
    r"\bString\.fromEnvironment\(\s*'ACCOUNT_DELETION_URL'\s*,?\s*\)",
    read('lib/features/onboarding/presentation/onboarding_screen.dart'),
), 'missing account-deletion URL environment define'
assert 'ledger_backups' not in read('lib/features/backup/infrastructure/backup_archive_codec.dart')
for path in (root/'lib').rglob('*.dart'):
    source=path.read_text()
    assert not re.search(r'(?:debugPrint|print)\s*\(',source), str(path)
for path in (root/'supabase/functions').rglob('*'):
    if path.suffix not in {'.ts','.mjs'} or '/tests/' in str(path): continue
    assert not re.search(r'console\.(?:log|error)\s*\(',path.read_text()),str(path)
print('Phase 9 repository security checks: PASS (static scope)')
