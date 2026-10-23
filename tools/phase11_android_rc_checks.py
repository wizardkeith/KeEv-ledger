#!/usr/bin/env python3
"""Source-only Android RC guard; does not claim native build or merged-manifest success."""
from pathlib import Path
import re
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
gradle = (root / 'android/app/build.gradle.kts').read_text()
settings = (root / 'android/settings.gradle.kts').read_text()
props = (root / 'android/gradle.properties').read_text()
wrapper = (root / 'android/gradle/wrapper/gradle-wrapper.properties').read_text()
manifest = ET.parse(root / 'android/app/src/main/AndroidManifest.xml').getroot()
android = '{http://schemas.android.com/apk/res/android}'

for field in ('compileSdk', 'targetSdk'):
    value = re.search(rf'\b{field}\s*=\s*(\d+)', gradle)
    assert value and int(value.group(1)) >= 36, f'{field} must target API 36+'
assert 'minSdk = flutter.minSdkVersion' in gradle, 'minSdk changed without evidence'
assert 'versionCode = flutter.versionCode' in gradle
assert 'versionName = flutter.versionName' in gradle
assert 'android.builtInKotlin=false' in props and 'android.newDsl=false' in props
plugins = re.search(r'(?s)^plugins\s*\{(.*?)\}', gradle)
assert plugins, 'missing app plugins block'
plugin_ids = re.findall(r'id\("([^"]+)"\)', plugins.group(1))
assert plugin_ids[:3] == [
    'com.android.application',
    'org.jetbrains.kotlin.android',
    'dev.flutter.flutter-gradle-plugin',
], 'legacy Kotlin Gradle plugin must precede Flutter Gradle plugin'
assert not (root / 'android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java').exists(), (
    'do not source-control generated Flutter plugin registration'
)
assert '.flutter-plugins-dependencies' in (root / '.gitignore').read_text()
assert 'gradle-9.3.1-' in wrapper and 'com.android.application") version "9.1.0"' in settings
assert all(f'KEEV_UPLOAD_{suffix}' in gradle for suffix in
           ('STORE_FILE', 'STORE_PASSWORD', 'KEY_ALIAS', 'KEY_PASSWORD'))
assert 'signingConfig = signingConfigs.getByName("debug")' not in gradle
ignore = (root / '.gitignore').read_text()
assert all(name in ignore for name in ('*.jks', '*.keystore', 'key.properties', 'android/local.properties'))

permissions = {node.attrib[android + 'name'] for node in manifest.findall('uses-permission')}
assert permissions == {
    'android.permission.RECORD_AUDIO', 'android.permission.INTERNET',
    'android.permission.ACCESS_NETWORK_STATE', 'android.permission.USE_BIOMETRIC',
}, 'unexpected first-party permission; inspect before release'
application = manifest.find('application')
assert application is not None
assert application.attrib.get(android + 'allowBackup') == 'false'
assert application.attrib.get(android + 'usesCleartextTraffic') != 'true'
exported = [node.attrib.get(android + 'name') for node in application.findall('activity')
            if node.attrib.get(android + 'exported') == 'true']
assert exported == [
    '.MainActivity',
    'com.aboutyou.dart_packages.sign_in_with_apple.SignInWithAppleCallback',
], 'unexpected exported first-party activity; inspect before release'
bootstrap = (root / 'lib/app/bootstrap.dart').read_text()
assert re.search(r"'PURCHASES_ENABLED',\s*defaultValue: false", bootstrap)
assert 'in_app_purchase_android:' in (root / 'pubspec.yaml').read_text()
print('Phase 11 Android RC source checks: PASS (API 36, Kotlin plugin, generated registration, signing, manifest, checkout gate)')
