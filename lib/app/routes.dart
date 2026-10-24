import 'package:flutter/material.dart';

import '../design_system/components.dart';
import '../localization/generated/app_localizations.dart';
import '../features/settings/application/settings_controller.dart';
import '../features/settings/presentation/settings_screens.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/bookkeeping/application/bookkeeping_session.dart';
import '../features/bookkeeping/presentation/history_view.dart';
import '../features/planning/presentation/planning_screens.dart';
import '../features/reports/presentation/reports_screen.dart';
import '../features/app_lock/application/app_lock_controller.dart';
import '../features/app_lock/presentation/app_lock_screens.dart';
import '../features/account/application/account_controller.dart';
import '../features/account/presentation/account_screen.dart';
import '../features/backup/presentation/backup_screen.dart';
import '../features/sync/presentation/sync_settings_screen.dart';
import '../features/ads/application/ads_controller.dart';
import '../features/ads/presentation/privacy_advertising_screen.dart';
import '../features/purchases/application/purchase_controller.dart';
import '../features/purchases/presentation/premium_screen.dart';
import 'bookkeeping_runtime.dart';

enum AppPage {
  accounts,
  projects,
  reports,
  settings,
  language,
  appearance,
  backup,
  authentication,
  sync,
  premium,
  privacyAdvertising,
}

String pageTitle(AppLocalizations l, AppPage page) => switch (page) {
  AppPage.accounts => l.accounts,
  AppPage.projects => l.projects,
  AppPage.reports => l.reports,
  AppPage.settings => l.settings,
  AppPage.language => l.language,
  AppPage.appearance => l.appearance,
  AppPage.backup => l.backup,
  AppPage.authentication => l.authentication,
  AppPage.sync => l.syncTitle,
  AppPage.premium => l.premium,
  AppPage.privacyAdvertising => l.privacyAdvertising,
};
Future<void> openPage(
  BuildContext context,
  AppPage page,
  SettingsController controller, {
  BookkeepingSession? session,
  AppLockController? appLockController,
  AccountController? accountController,
  AdsController? adsController,
  PurchaseController? purchaseController,
}) => Navigator.of(context).push<void>(
  PageRouteBuilder<void>(
    settings: RouteSettings(name: page.name),
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    pageBuilder: (context, _, __) => switch (page) {
      AppPage.language => LanguageScreen(controller: controller),
      AppPage.appearance => AppearanceScreen(controller: controller),
      AppPage.settings => SettingsScreen(
        controller: controller,
        appLockController: appLockController,
        accountController: accountController,
        session: session,
        adsController: adsController,
        purchaseController: purchaseController,
      ),
      AppPage.accounts when session != null => AccountOverview(
        session: session,
      ),
      AppPage.projects when session != null => ProjectScreen(session: session),
      AppPage.reports when session != null => ReportsScreen(
        session: session,
        adsController: adsController,
      ),
      AppPage.privacyAdvertising when adsController != null =>
        PrivacyAdvertisingScreen(controller: adsController),
      AppPage.premium when purchaseController != null => PremiumScreen(
        controller: purchaseController,
      ),
      AppPage.authentication when accountController != null =>
        AccountCloudScreen(
          controller: accountController,
          syncController: session is BookkeepingRuntime
              ? session.syncController
              : null,
        ),
      AppPage.sync
          when session is BookkeepingRuntime &&
              session.syncController != null =>
        SyncSettingsScreen(controller: session.syncController!),
      AppPage.backup when session is BookkeepingRuntime => BackupRestoreScreen(
        runtime: session,
        accountController: accountController,
      ),
      _ => FeatureShell(page: page),
    },
  ),
);

class FeatureShell extends StatelessWidget {
  const FeatureShell({super.key, required this.page});
  final AppPage page;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return KeEvScaffold(
      title: pageTitle(l, page),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l.preview),
          const SizedBox(height: 24),
          const KeEvEmptyState(),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.controller,
    required this.appLockController,
    required this.accountController,
    this.session,
    this.adsController,
    this.purchaseController,
  });
  final SettingsController controller;
  final AppLockController? appLockController;
  final AccountController? accountController;
  final BookkeepingSession? session;
  final AdsController? adsController;
  final PurchaseController? purchaseController;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return KeEvScaffold(
      title: l.settings,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final page in [AppPage.language, AppPage.appearance])
            ListTile(
              key: Key('route-${page.name}'),
              title: Text(pageTitle(l, page)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => openPage(context, page, controller),
            ),
          if (appLockController != null)
            ListTile(
              key: const Key('route-app-lock'),
              title: Text(l.appLock),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  settings: const RouteSettings(name: 'app-lock'),
                  builder: (_) =>
                      AppLockSettingsScreen(controller: appLockController!),
                ),
              ),
            ),
          if (accountController != null)
            ListenableBuilder(
              listenable: accountController!,
              builder: (context, _) => ListTile(
                key: const Key('route-authentication'),
                title: Text(l.authentication),
                subtitle: Text(accountStatusLabel(l, accountController!)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openPage(
                  context,
                  AppPage.authentication,
                  controller,
                  accountController: accountController,
                ),
              ),
            ),
          if (purchaseController != null)
            ListTile(
              key: const Key('route-premium'),
              title: Text(l.premium),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => openPage(
                context,
                AppPage.premium,
                controller,
                purchaseController: purchaseController,
              ),
            ),
          if (session is BookkeepingRuntime &&
              (session as BookkeepingRuntime).syncController != null)
            ListenableBuilder(
              listenable: (session as BookkeepingRuntime).syncController!,
              builder: (context, _) => ListTile(
                key: const Key('route-sync'),
                title: Text(l.syncTitle),
                subtitle: Text(
                  syncStatusLabel(
                    l,
                    (session as BookkeepingRuntime).syncController!,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openPage(
                  context,
                  AppPage.sync,
                  controller,
                  session: session,
                ),
              ),
            ),
          if (adsController?.configuration.enabled ?? false)
            ListTile(
              key: const Key('route-privacy-advertising'),
              title: Text(l.privacyAdvertising),
              subtitle: Text(l.privacyAdvertisingSummary),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => openPage(
                context,
                AppPage.privacyAdvertising,
                controller,
                adsController: adsController,
              ),
            ),
          if (configuredLegalUrl('PRIVACY_POLICY_URL') != null ||
              !const bool.fromEnvironment('dart.vm.product'))
            ListTile(
              title: Text(l.privacyPolicy),
              onTap: () => showLegal(
                context,
                l.privacyPolicy,
                url: configuredLegalUrl('PRIVACY_POLICY_URL'),
              ),
            ),
          if (configuredLegalUrl('TERMS_URL') != null ||
              !const bool.fromEnvironment('dart.vm.product'))
            ListTile(
              title: Text(l.terms),
              onTap: () => showLegal(
                context,
                l.terms,
                url: configuredLegalUrl('TERMS_URL'),
              ),
            ),
          const SizedBox(height: 16),
          Text(l.sessionNotice),
        ],
      ),
    );
  }
}
