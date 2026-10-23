import 'dart:convert';
import 'dart:io';

const keys = <String>[
  'syncTitle',
  'syncEnable',
  'syncDescription',
  'syncNow',
  'syncPause',
  'syncResume',
  'syncDisable',
  'syncLocalData',
  'syncCloudData',
  'syncKeepLocal',
  'syncKeepCloud',
  'syncCancel',
  'syncNeedsReconciliation',
  'syncConflicts',
  'syncActive',
  'syncPaused',
  'syncUpToDate',
  'syncOffline',
  'syncAuthRequired',
  'syncPendingChanges',
  'syncLastSynced',
  'syncChecking',
  'syncInitializing',
  'syncDestructiveWarning',
  'syncUnlinkWarning',
  'syncConflictsTitle',
  'syncLocalDelete',
  'syncCloudDelete',
  'syncNoAutomaticMerge',
  'syncUploading',
  'syncDownloading',
  'syncVerifying',
  'syncFinalizing',
];

void main() {
  _insertAbstract();
  _insertLocale(
    'app_localizations_en.dart',
    'AppLocalizationsEn',
    'app_en.arb',
  );
  _insertLocale(
    'app_localizations_ja.dart',
    'AppLocalizationsJa',
    'app_ja.arb',
  );
  _insertLocale(
    'app_localizations_th.dart',
    'AppLocalizationsTh',
    'app_th.arb',
  );
  _insertLocale(
    'app_localizations_zh.dart',
    'AppLocalizationsZh',
    'app_zh.arb',
  );
  _insertLocale(
    'app_localizations_zh.dart',
    'AppLocalizationsZhCn',
    'app_zh_CN.arb',
  );
  _insertLocale(
    'app_localizations_zh.dart',
    'AppLocalizationsZhHk',
    'app_zh_HK.arb',
  );
}

void _insertAbstract() {
  final file = File('lib/localization/generated/app_localizations.dart');
  var source = file.readAsStringSync();
  final missing = keys.where((key) => !source.contains('String get $key;'));
  if (missing.isEmpty) return;
  final index = _classEnd(source, 'abstract class AppLocalizations');
  final declarations = missing.map((key) => '  String get $key;').join('\n');
  source = source.replaceRange(index, index, '\n$declarations\n');
  file.writeAsStringSync(source);
}

void _insertLocale(String name, String className, String arbName) {
  final file = File('lib/localization/generated/$name');
  var source = file.readAsStringSync();
  final classStart = source.indexOf('class $className ');
  final classEnd = _classEnd(source, 'class $className ');
  final classSource = source.substring(classStart, classEnd);
  final missing = keys.where((key) => !classSource.contains('get $key'));
  if (missing.isEmpty) return;
  final values =
      jsonDecode(File('lib/localization/arb/$arbName').readAsStringSync())
          as Map<String, dynamic>;
  String quote(String value) => value
      .replaceAll(r'\', r'\\')
      .replaceAll("'", r"\'")
      .replaceAll(r'$', r'\$');
  final getters = missing
      .map((key) {
        return "  @override\n  String get $key => '${quote(values[key] as String)}';";
      })
      .join('\n\n');
  source = source.replaceRange(classEnd, classEnd, '\n$getters\n');
  file.writeAsStringSync(source);
}

int _classEnd(String source, String marker) {
  final start = source.indexOf(marker);
  if (start < 0) throw StateError('Missing $marker');
  final open = source.indexOf('{', start);
  var depth = 0;
  for (var i = open; i < source.length; i++) {
    if (source.codeUnitAt(i) == 123) depth++;
    if (source.codeUnitAt(i) == 125 && --depth == 0) return i;
  }
  throw StateError('Unclosed $marker');
}
