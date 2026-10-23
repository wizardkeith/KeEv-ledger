import 'package:flutter/material.dart';

import '../../../design_system/components.dart';
import '../../../localization/generated/app_localizations.dart';
import '../../../localization/locale_resolution.dart';
import '../application/settings_controller.dart';

class LanguageChoices extends StatelessWidget {
  const LanguageChoices({super.key, required this.controller});
  final SettingsController controller;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final labels = [
      l.languageHongKong,
      l.languageChinese,
      l.languageEnglish,
      l.languageJapanese,
      l.languageThai,
    ];
    return Column(
      children: [
        ListTile(
          key: const Key('locale-system'),
          title: Text(l.followSystem),
          selected: controller.locale == null,
          trailing: controller.locale == null ? const Icon(Icons.check) : null,
          enabled: !controller.busy,
          onTap: () => controller.setLocale(null),
        ),
        for (var i = 0; i < supportedLocales.length; i++)
          ListTile(
            key: Key('locale-${supportedLocales[i]}'),
            title: Text(labels[i]),
            selected: controller.locale == supportedLocales[i],
            trailing: controller.locale == supportedLocales[i]
                ? const Icon(Icons.check)
                : null,
            enabled: !controller.busy,
            onTap: () => controller.setLocale(supportedLocales[i]),
          ),
      ],
    );
  }
}

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key, required this.controller});
  final SettingsController controller;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final l = AppLocalizations.of(context);
      return KeEvScaffold(
        title: l.language,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l.sessionNotice),
            LanguageChoices(controller: controller),
            if (controller.failure != null)
              KeEvErrorCard(message: l.preferencesError),
          ],
        ),
      );
    },
  );
}

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key, required this.controller});
  final SettingsController controller;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final l = AppLocalizations.of(context);
      final labels = [l.systemTheme, l.lightTheme, l.darkTheme];
      return KeEvScaffold(
        title: l.appearance,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l.sessionNotice),
            for (var i = 0; i < ThemeMode.values.length; i++)
              ListTile(
                key: Key('theme-${ThemeMode.values[i].name}'),
                title: Text(labels[i]),
                selected: controller.themeMode == ThemeMode.values[i],
                trailing: controller.themeMode == ThemeMode.values[i]
                    ? const Icon(Icons.check)
                    : null,
                enabled: !controller.busy,
                onTap: () => controller.setTheme(ThemeMode.values[i]),
              ),
            if (controller.failure != null)
              KeEvErrorCard(message: l.preferencesError),
          ],
        ),
      );
    },
  );
}
