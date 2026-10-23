import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger/core/result.dart';
import 'package:ledger/features/account/application/account_controller.dart';
import 'package:ledger/features/account/application/authentication_contracts.dart';
import 'package:ledger/features/account/domain/cloud_account.dart';
import 'package:ledger/features/account/presentation/account_screen.dart';
import 'package:ledger/localization/generated/app_localizations.dart';

void main() {
  testWidgets('account screen renders distinct session states', (tester) async {
    final controller = AccountController(
      gateway: const _Gateway(),
      sessionStore: _Store(),
    );
    addTearDown(controller.dispose);
    final cases = <AccountSessionState, String>{
      AccountSessionState.localOnly: 'Local Only',
      AccountSessionState.signedOut: 'Signed out',
      AccountSessionState.authenticating: 'Signing in…',
      AccountSessionState.authenticated:
          'This device has an authenticated KeEv cloud session.',
      AccountSessionState.requiresReauthentication:
          'Sign in again to continue using cloud account features.',
      AccountSessionState.temporarilyUnavailable: 'Cloud service is temporarily unavailable. Your secure session has been kept.',
    };
    for (final entry in cases.entries) {
      controller.state = entry.key;
      controller.failure =
          entry.key == AccountSessionState.temporarilyUnavailable
          ? FailureCode.networkUnavailable
          : null;
      await tester.pumpWidget(_App(controller));
      expect(find.text(entry.value), findsWidgets, reason: entry.key.name);
      if (entry.key == AccountSessionState.localOnly) {
        expect(find.text('Cloud Account'), findsNothing);
      } else {
        expect(find.text('Cloud Account'), findsOneWidget);
        expect(find.text('Local Only'), findsNothing);
      }
    }
  });

  testWidgets('configuration unavailable is distinct from Local Only', (
    tester,
  ) async {
    final controller =
        AccountController(
            gateway: const _Gateway(configured: false),
            sessionStore: _Store(),
          )
          ..state = AccountSessionState.temporarilyUnavailable
          ..failure = FailureCode.cloudConfigurationUnavailable;
    addTearDown(controller.dispose);
    await tester.pumpWidget(_App(controller));
    expect(
      find.text(
        'Cloud sign-in is not configured in this build. Local Only remains available.',
      ),
      findsWidgets,
    );
  });
}

class _App extends StatelessWidget {
  const _App(this.controller);
  final AccountController controller;
  @override
  Widget build(BuildContext context) => MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: AccountCloudScreen(controller: controller),
  );
}

final class _Store implements SecureSessionStore {
  @override
  Future<Result<void>> clear() async => const Success(null);
  @override
  Future<Result<AuthenticationBundle?>> read() async => const Success(null);
  @override
  Future<Result<void>> write(AuthenticationBundle bundle) async =>
      const Success(null);
}

final class _Gateway implements AuthenticationGateway {
  const _Gateway({this.configured = true});
  final bool configured;
  @override
  bool get isConfigured => configured;
  @override
  Future<Result<CloudAccount>> currentAccount(SessionSecrets secrets) async =>
      const Failure(FailureCode.backendUnavailable);
  @override
  Future<Result<AuthenticationBundle>> refreshSession(
    SessionSecrets secrets,
  ) async => const Failure(FailureCode.backendUnavailable);
  @override
  Future<Result<void>> requestEmailOtp(String email) async =>
      const Failure(FailureCode.backendUnavailable);
  @override
  Future<Result<void>> revokeAccount(SessionSecrets secrets) async =>
      const Failure(FailureCode.backendUnavailable);
  @override
  Future<Result<AuthenticationBundle>> restoreSession(
    SessionSecrets secrets,
  ) async => const Failure(FailureCode.backendUnavailable);
  @override
  Future<Result<AuthenticationBundle>> signIn(
    AuthenticationProvider provider,
  ) async => const Failure(FailureCode.backendUnavailable);
  @override
  Future<Result<void>> signOut(SessionSecrets secrets) async =>
      const Success(null);
  @override
  Future<Result<AuthenticationBundle>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async => const Failure(FailureCode.backendUnavailable);
}
