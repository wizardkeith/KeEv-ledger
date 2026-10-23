import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../design_system/theme.dart';
import '../features/home/presentation/home_shell.dart';
import 'bookkeeping_runtime.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/settings/application/settings_controller.dart';
import '../localization/generated/app_localizations.dart';
import '../localization/locale_resolution.dart';
import 'environment.dart';
import '../features/app_lock/application/app_lock_controller.dart';
import '../features/app_lock/presentation/app_lock_screens.dart';
import '../features/account/application/account_controller.dart';
import '../features/ads/application/ads_controller.dart';
import '../features/purchases/application/purchase_controller.dart';

class KeEvApp extends StatefulWidget {
  const KeEvApp({
    super.key,
    required this.controller,
    required this.configuration,
    required this.appLockController,
    required this.accountController,
    this.adsController,
    this.purchaseController,
    this.bookkeepingRuntime,
  });
  final SettingsController controller;
  final AppConfiguration configuration;
  final AppLockController appLockController;
  final AccountController accountController;
  final AdsController? adsController;
  final PurchaseController? purchaseController;
  final BookkeepingRuntime? bookkeepingRuntime;
  @override
  State<KeEvApp> createState() => _KeEvAppState();
}

class _KeEvAppState extends State<KeEvApp> with WidgetsBindingObserver {
  bool entered = false;
  bool privacyCovered = false;
  BookkeepingRuntime? _ownedRuntime;
  String? _purchaseAccountId;
  BookkeepingRuntime get runtime =>
      widget.bookkeepingRuntime ?? (_ownedRuntime ??= _createRuntime());

  BookkeepingRuntime _createRuntime() {
    SupabaseClient? client;
    if (widget.configuration.supabase != null) {
      try {
        client = Supabase.instance.client;
      } on Object {
        client = null;
      }
    }
    return BookkeepingRuntime.openLocal(
      accountController: widget.accountController,
      syncClient: client,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.appLockController.addListener(_appLockChanged);
    _purchaseAccountId = widget.accountController.account?.id;
    widget.accountController.addListener(_accountChanged);
    _appLockChanged();
  }

  void _appLockChanged() => widget.adsController?.setAppLocked(
    widget.appLockController.state == AppLockState.locked,
  );

  void _accountChanged() {
    final current = widget.accountController.account?.id;
    if (current == _purchaseAccountId) return;
    _purchaseAccountId = current;
    widget.purchaseController?.accountChanged();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) setState(() => privacyCovered = false);
      if (entered) unawaited(runtime.syncCoordinator?.resumed());
      widget.purchaseController?.resumed();
      return;
    }
    if (mounted) setState(() => privacyCovered = true);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      widget.appLockController.lock();
      if (entered) unawaited(runtime.syncCoordinator?.leftForeground());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.appLockController.removeListener(_appLockChanged);
    widget.accountController.removeListener(_accountChanged);
    widget.adsController?.dispose();
    widget.purchaseController?.dispose();
    _ownedRuntime?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) => MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final themed = Theme(
          data: keevTheme(
            Theme.of(context).brightness,
            locale: Localizations.localeOf(context),
          ),
          child: child ?? const SizedBox.shrink(),
        );
        return Stack(
          children: [
            AppLockGate(controller: widget.appLockController, child: themed),
            if (privacyCovered) const Positioned.fill(child: AppPrivacyCover()),
          ],
        );
      },
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: keevTheme(Brightness.light),
      darkTheme: keevTheme(Brightness.dark),
      themeMode: widget.controller.themeMode,
      themeAnimationDuration: Duration.zero,
      locale: widget.controller.locale,
      supportedLocales: supportedLocales,
      localeListResolutionCallback: (locales, _) => resolveLocale(locales),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: entered
          ? HomeShell(
              controller: widget.controller,
              runtime: runtime,
              appLockController: widget.appLockController,
              accountController: widget.accountController,
              adsController: widget.adsController,
              purchaseController: widget.purchaseController,
            )
          : OnboardingScreen(
              controller: widget.controller,
              onStart: () {
                setState(() => entered = true);
                // Do not stack a CMP form over first-launch onboarding. The
                // ledger renders first; consent work then proceeds separately.
                unawaited(widget.adsController?.start());
                if (widget.bookkeepingRuntime == null) {
                  unawaited(runtime.reconcileReceipts());
                }
                unawaited(runtime.syncCoordinator?.coldStart());
              },
            ),
    ),
  );
}
