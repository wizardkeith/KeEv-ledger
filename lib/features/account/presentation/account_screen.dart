import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/result.dart';
import '../../../design_system/components.dart';
import '../../../localization/generated/app_localizations.dart';
import '../application/account_controller.dart';
import '../domain/cloud_account.dart';
import '../../sync/application/sync_controller.dart';
import '../../sync/presentation/sync_settings_screen.dart';
import 'account_deletion_strings.dart';

String accountStatusLabel(AppLocalizations l, AccountController controller) =>
    switch (controller.state) {
      AccountSessionState.localOnly => l.localOnlyModeTitle,
      AccountSessionState.signedOut => l.cloudSignedOut,
      AccountSessionState.authenticating => l.cloudAuthenticating,
      AccountSessionState.authenticated => l.cloudAccountConnected,
      AccountSessionState.requiresReauthentication =>
        l.cloudReauthenticationRequired,
      AccountSessionState.temporarilyUnavailable =>
        controller.failure == FailureCode.cloudConfigurationUnavailable
            ? l.cloudConfigurationUnavailable
            : l.cloudTemporarilyUnavailable,
    };

class AccountCloudScreen extends StatefulWidget {
  const AccountCloudScreen({
    super.key,
    required this.controller,
    this.syncController,
  });
  final AccountController controller;
  final SyncController? syncController;

  @override
  State<AccountCloudScreen> createState() => _AccountCloudScreenState();
}

class _AccountCloudScreenState extends State<AccountCloudScreen> {
  Future<void> _deleteAccount() async {
    final strings = AccountDeletionStrings.of(context);
    final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) =>
      AlertDialog(
        title: Text(strings.title),
        content: SingleChildScrollView(child: Text(strings.warning)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(strings.cancel)),
          TextButton(key: const Key('confirm-cloud-account-deletion'),
            onPressed: () => Navigator.pop(dialogContext, true), child: Text(strings.confirm)),
        ],
      ));
    if (confirmed != true || !mounted) return;
    final result = await widget.controller.deleteAccount();
    if (result is Success<void>) await widget.syncController?.unlink();
    if (!mounted) return;
    if (result is Failure<void> &&
        result.code == FailureCode.cloudAuthenticationCancelled) return;
    final message = result is Success<void> ? strings.done :
        result is Failure<void> && result.code == FailureCode.sessionExpired
          ? strings.reauthenticate :
        result is Failure<void> && result.code == FailureCode.authenticationProviderFailure
          ? strings.appleReauthenticate : strings.failed;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final l = AppLocalizations.of(context);
      final controller = widget.controller;
      final localOnly = controller.state == AccountSessionState.localOnly;
      final authenticated =
          controller.state == AccountSessionState.authenticated;
      final busy = controller.state == AccountSessionState.authenticating || controller.deletingAccount;
      final maySignIn = controller.isCloudConfigured && !busy;
      return KeEvScaffold(
        title: l.authentication,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            KeEvCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  KeEvSectionHeader(
                    text: localOnly ? l.localOnlyModeTitle : l.cloudAccount,
                  ),
                  const SizedBox(height: 12),
                  Text(accountStatusLabel(l, controller)),
                  if (controller.state == AccountSessionState.localOnly) ...[
                    const SizedBox(height: 8),
                    Text(l.localOnlyDataNotice),
                  ],
                  if (controller.account?.email case final email?) ...[
                    const SizedBox(height: 8),
                    Text(email),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (authenticated)
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                KeEvSecondaryButton(
                  key: const Key('cloud-sign-out'),
                  label: l.signOut,
                  onPressed: busy ? null : controller.signOut,
                ),
                const SizedBox(height: 12),
                TextButton(key: const Key('delete-cloud-account'),
                  onPressed: busy ? null : _deleteAccount,
                  child: Text(AccountDeletionStrings.of(context).title)),
              ])
            else ...[
              Text(l.cloudOptionalDescription),
              const SizedBox(height: 16),
              if (controller.state == AccountSessionState.localOnly)
                KeEvSecondaryButton(
                  key: const Key('explore-cloud-account'),
                  label: l.cloudAccountOptions,
                  onPressed: controller.chooseCloudAccount,
                )
              else ...[
                KeEvSecondaryButton(
                  key: const Key('sign-in-apple'),
                  label: l.signInWithApple,
                  onPressed: maySignIn
                      ? () => controller.signIn(AuthenticationProvider.apple)
                      : null,
                ),
                const SizedBox(height: 8),
                KeEvSecondaryButton(
                  key: const Key('sign-in-google'),
                  label: l.signInWithGoogle,
                  onPressed: maySignIn
                      ? () => controller.signIn(AuthenticationProvider.google)
                      : null,
                ),
                const SizedBox(height: 8),
                KeEvSecondaryButton(
                  key: const Key('sign-in-email'),
                  label: l.signInWithEmail,
                  onPressed: maySignIn
                      ? () => showDialog<void>(
                          context: context,
                          builder: (_) =>
                              _EmailOtpDialog(controller: controller),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  controller.isCloudConfigured
                      ? l.cloudBackupNotActive
                      : l.cloudConfigurationUnavailable,
                ),
                const SizedBox(height: 12),
                TextButton(
                  key: const Key('continue-local-only'),
                  onPressed: controller.continueLocalOnly,
                  child: Text(l.continueLocalOnly),
                ),
              ],
            ],
            if (controller.failure != null) ...[
              const SizedBox(height: 16),
              KeEvErrorCard(message: _failureMessage(l, controller.failure!)),
            ],
            const SizedBox(height: 16),
            Text(l.cloudBackupNotActive),
            if (widget.syncController != null && authenticated) ...[
              const SizedBox(height: 12),
              ListenableBuilder(
                listenable: widget.syncController!,
                builder: (context, _) => ListTile(
                  key: const Key('cloud-sync-settings'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.syncTitle),
                  subtitle: Text(syncStatusLabel(l, widget.syncController!)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) =>
                        SyncSettingsScreen(controller: widget.syncController!),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(l.appLockCloudSeparation),
          ],
        ),
      );
    },
  );
}

String _failureMessage(AppLocalizations l, FailureCode code) => switch (code) {
  FailureCode.invalidOtp => l.invalidOtp,
  FailureCode.expiredOtp || FailureCode.invalidOrExpiredOtp => l.expiredOtp,
  FailureCode.rateLimited => l.authRateLimited,
  FailureCode.networkUnavailable => l.cloudNetworkUnavailable,
  FailureCode.cloudConfigurationUnavailable => l.cloudConfigurationUnavailable,
  _ => l.cloudAccountError,
};

class _EmailOtpDialog extends StatefulWidget {
  const _EmailOtpDialog({required this.controller});
  final AccountController controller;

  @override
  State<_EmailOtpDialog> createState() => _EmailOtpDialogState();
}

class _EmailOtpDialogState extends State<_EmailOtpDialog> {
  final _email = TextEditingController();
  final _otp = TextEditingController();
  Timer? _timer;
  bool _sent = false;
  bool _busy = false;
  FailureCode? _failure;

  @override
  void dispose() {
    _timer?.cancel();
    _email.dispose();
    _otp.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() {
      _busy = true;
      _failure = null;
    });
    final result = await widget.controller.requestEmailOtp(_email.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (result case Failure<void>(:final code)) {
        _failure = code;
      } else {
        _sent = true;
      }
    });
    if (_sent) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  Future<void> _verify() async {
    setState(() {
      _busy = true;
      _failure = null;
    });
    final result = await widget.controller.verifyEmailOtp(
      email: _email.text,
      otp: _otp.text,
    );
    if (!mounted) return;
    if (result is Success<void>) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _busy = false;
      _failure = (result as Failure<void>).code;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cooldown = widget.controller.otpCooldownRemaining.inSeconds;
    return AlertDialog(
      title: Text(l.signInWithEmail),
      content: SingleChildScrollView(
        child: AutofillGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const Key('cloud-email'),
                controller: _email,
                enabled: !_busy && !_sent,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(labelText: l.emailAddress),
              ),
              if (_sent) ...[
                const SizedBox(height: 12),
                Text(l.otpSent),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('cloud-otp'),
                  controller: _otp,
                  enabled: !_busy,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 6,
                  decoration: InputDecoration(labelText: l.otpCode),
                ),
              ],
              if (_failure != null) ...[
                const SizedBox(height: 8),
                Text(_failureMessage(l, _failure!)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l.close),
        ),
        if (!_sent)
          FilledButton(
            key: const Key('send-email-otp'),
            onPressed: _busy ? null : _send,
            child: Text(l.sendOtp),
          )
        else ...[
          TextButton(
            key: const Key('resend-email-otp'),
            onPressed: _busy || cooldown > 0 ? null : _send,
            child: Text(
              cooldown > 0 ? '${l.resendOtp} ($cooldown)' : l.resendOtp,
            ),
          ),
          FilledButton(
            key: const Key('verify-email-otp'),
            onPressed: _busy ? null : _verify,
            child: Text(l.verifyOtp),
          ),
        ],
      ],
    );
  }
}
