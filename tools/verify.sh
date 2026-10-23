#!/usr/bin/env bash
set -euo pipefail
export CI=true
export FLUTTER_SUPPRESS_ANALYTICS=true
flutter --version
flutter pub get --enforce-lockfile
flutter gen-l10n
dart run build_runner build
dart format --output=none --set-exit-if-changed lib test tools/capture_shell_test.dart tools/capture_typography_test.dart
flutter analyze
flutter test
