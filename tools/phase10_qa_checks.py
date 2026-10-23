#!/usr/bin/env python3
"""Phase 10 source validation. This cannot substitute for flutter test/analyze."""
from pathlib import Path
import json
import plistlib
import re

root = Path(__file__).resolve().parents[1]
arb = root / 'lib/localization/arb'
locales = ('en', 'zh_HK', 'ja', 'th')
messages = {name: json.loads((arb / f'app_{name}.arb').read_text()) for name in locales}
keys = {name: {k for k in data if not k.startswith('@')} for name, data in messages.items()}
assert all(keys[name] == keys['en'] for name in locales), 'missing localization key'
for key in keys['en']:
    # ICU argument placeholders must agree across translations.
    arguments = lambda value: set(re.findall(r'\{([a-zA-Z][a-zA-Z0-9_]*)\}', value))
    assert all(arguments(messages[name][key]) == arguments(messages['en'][key])
               for name in locales), f'placeholder mismatch: {key}'

db = (root / 'lib/infrastructure/local/ledger_database.dart').read_text()
assert 'int get schemaVersion => 8;' in db
generated = root / 'test/generated_migrations/ledger_database/generated'
assert all((generated / f'schema_v{v}.dart').exists() for v in (5, 6, 7, 8))
migration = (root / 'test/generated_migrations/ledger_database/migration_test.dart').read_text()
assert all(f'migration from v{v} to v{v + 1}' in migration for v in (5, 6))
assert 'v7 linked state migrates' in (root / 'test/unit/sync_onboarding_test.dart').read_text()

migrations = sorted(p.name for p in (root / 'supabase/migrations').glob('*.sql'))
assert len(migrations) == len(set(migrations)) and migrations == sorted(migrations)
assert any('billing_notifications_v1' in m for m in migrations)
assert any('account_deletion_v1' in m for m in migrations)

bootstrap = (root / 'lib/app/bootstrap.dart').read_text()
assert re.search(r"'PURCHASES_ENABLED',\s*defaultValue: false", bootstrap)
assert plistlib.loads((root / 'ios/Runner/PrivacyInfo.xcprivacy').read_bytes())['NSPrivacyTracking'] is False
print(f'Phase 10 source QA: PASS ({len(keys["en"])} message keys in four locales; schema v8/migration fixtures; fail-closed checkout)')
