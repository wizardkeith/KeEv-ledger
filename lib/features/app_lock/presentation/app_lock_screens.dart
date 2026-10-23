import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/result.dart';
import '../../../design_system/components.dart';
import '../../../localization/generated/app_localizations.dart';
import '../application/app_lock_contracts.dart';
import '../application/app_lock_controller.dart';

class AppLockGate extends StatelessWidget {
  const AppLockGate({super.key, required this.controller, required this.child});

  final AppLockController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => switch (controller.state) {
      AppLockState.disabled || AppLockState.unlocked => child,
      AppLockState.locked => _standaloneOverlay(
        AppLockScreen(controller: controller),
      ),
      AppLockState.loading => const Scaffold(
        body: Center(child: KeEvLoadingState()),
      ),
      AppLockState.configurationError => _standaloneOverlay(
        const _LockConfigurationError(),
      ),
    },
  );

  Widget _standaloneOverlay(Widget content) =>
      Overlay(initialEntries: [OverlayEntry(builder: (_) => content)]);
}

class AppPrivacyCover extends StatelessWidget {
  const AppPrivacyCover({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Center(
          child: Semantics(
            label: l.privacyCover,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/brand/keev-logo-original.png',
                  width: 96,
                  height: 96,
                ),
                const SizedBox(height: 16),
                Text(l.appTitle, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(l.privacyCover),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key, required this.controller});
  final AppLockController controller;

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final pin = TextEditingController();

  @override
  void dispose() {
    pin.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    await widget.controller.unlockWithPin(pin.text);
    if (mounted && widget.controller.state == AppLockState.locked) {
      pin.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final controller = widget.controller;
    return Scaffold(
      key: const Key('app-lock-screen'),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: KeEvCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.lock_outline, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      l.appLocked,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Semantics(
                      label: l.enterPin,
                      child: TextField(
                        key: const Key('unlock-pin'),
                        controller: pin,
                        autofocus: true,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        maxLength: 6,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(labelText: l.enterPin),
                        onSubmitted: (_) => _unlock(),
                      ),
                    ),
                    if (controller.failure != null) ...[
                      const SizedBox(height: 8),
                      KeEvErrorCard(
                        message: lockFailureMessage(l, controller.failure!),
                      ),
                    ],
                    const SizedBox(height: 12),
                    KeEvPrimaryButton(
                      key: const Key('unlock-with-pin'),
                      label: controller.busy ? l.loading : l.unlock,
                      onPressed: controller.busy ? null : _unlock,
                    ),
                    if (controller.biometricsEnabled &&
                        controller.biometricCapability ==
                            BiometricCapability.available) ...[
                      const SizedBox(height: 8),
                      KeEvSecondaryButton(
                        key: const Key('unlock-with-biometrics'),
                        label: l.useBiometrics,
                        onPressed: controller.busy
                            ? null
                            : () => controller.unlockWithBiometrics(
                                l.biometricPromptReason,
                              ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(l.forgotPinGuidance, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LockConfigurationError extends StatelessWidget {
  const _LockConfigurationError();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: KeEvErrorCard(message: l.lockConfigurationError),
          ),
        ),
      ),
    );
  }
}

class AppLockSettingsScreen extends StatelessWidget {
  const AppLockSettingsScreen({super.key, required this.controller});
  final AppLockController controller;

  Future<void> _setup(BuildContext context) async {
    final values = await showDialog<List<String>>(
      context: context,
      builder: (_) => const _PinDialog(mode: _PinDialogMode.setup),
    );
    if (values != null) await controller.setupPin(values[0], values[1]);
  }

  Future<void> _change(BuildContext context) async {
    final values = await showDialog<List<String>>(
      context: context,
      builder: (_) => const _PinDialog(mode: _PinDialogMode.change),
    );
    if (values != null) {
      await controller.changePin(
        currentPin: values[0],
        newPin: values[1],
        confirmation: values[2],
      );
    }
  }

  Future<void> _disable(BuildContext context) async {
    final values = await showDialog<List<String>>(
      context: context,
      builder: (_) => const _PinDialog(mode: _PinDialogMode.authenticate),
    );
    if (values != null) await controller.disable(values.single);
  }

  Future<void> _biometrics(BuildContext context, bool enabled) async {
    final values = await showDialog<List<String>>(
      context: context,
      builder: (_) => const _PinDialog(mode: _PinDialogMode.authenticate),
    );
    if (values != null) {
      await controller.setBiometrics(
        enabled: enabled,
        currentPin: values.single,
      );
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final l = AppLocalizations.of(context);
      return KeEvScaffold(
        title: l.appLock,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l.appLockDescription),
            const SizedBox(height: 16),
            if (controller.failure != null)
              KeEvErrorCard(
                message: lockFailureMessage(l, controller.failure!),
              ),
            if (controller.state == AppLockState.disabled)
              KeEvPrimaryButton(
                key: const Key('enable-app-lock'),
                label: l.setPin,
                onPressed: controller.busy ? null : () => _setup(context),
              )
            else if (controller.state == AppLockState.unlocked) ...[
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: Text(l.appLockEnabled),
                subtitle: Text(l.relockPolicy),
              ),
              SwitchListTile(
                key: const Key('biometric-toggle'),
                title: Text(l.useBiometrics),
                subtitle: Text(
                  controller.biometricCapability ==
                          BiometricCapability.available
                      ? l.biometricSystemDescription
                      : l.biometricUnavailable,
                ),
                value: controller.biometricsEnabled,
                onChanged:
                    controller.busy ||
                        (controller.biometricCapability !=
                                BiometricCapability.available &&
                            !controller.biometricsEnabled)
                    ? null
                    : (value) => _biometrics(context, value),
              ),
              ListTile(
                key: const Key('change-pin'),
                leading: const Icon(Icons.password_outlined),
                title: Text(l.changePin),
                trailing: const Icon(Icons.chevron_right),
                enabled: !controller.busy,
                onTap: controller.busy ? null : () => _change(context),
              ),
              ListTile(
                key: const Key('lock-now'),
                leading: const Icon(Icons.lock_clock_outlined),
                title: Text(l.lockNow),
                enabled: !controller.busy,
                onTap: controller.busy ? null : controller.lock,
              ),
              ListTile(
                key: const Key('disable-app-lock'),
                leading: const Icon(Icons.lock_open_outlined),
                title: Text(l.disableAppLock),
                enabled: !controller.busy,
                onTap: controller.busy ? null : () => _disable(context),
              ),
            ] else if (controller.state == AppLockState.configurationError)
              KeEvErrorCard(message: l.lockConfigurationError),
          ],
        ),
      );
    },
  );
}

enum _PinDialogMode { setup, change, authenticate }

class _PinDialog extends StatefulWidget {
  const _PinDialog({required this.mode});
  final _PinDialogMode mode;

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  late final List<TextEditingController> fields = List.generate(
    widget.mode == _PinDialogMode.change
        ? 3
        : widget.mode == _PinDialogMode.setup
        ? 2
        : 1,
    (_) => TextEditingController(),
  );

  @override
  void dispose() {
    for (final field in fields) field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final labels = widget.mode == _PinDialogMode.change
        ? [l.currentPin, l.newPin, l.confirmPin]
        : widget.mode == _PinDialogMode.setup
        ? [l.setPin, l.confirmPin]
        : [l.currentPin];
    return AlertDialog(
      title: Text(switch (widget.mode) {
        _PinDialogMode.setup => l.setPin,
        _PinDialogMode.change => l.changePin,
        _PinDialogMode.authenticate => l.authenticationRequired,
      }),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (index, field) in fields.indexed)
            Semantics(
              label: labels[index],
              child: TextField(
                key: Key('pin-field-$index'),
                controller: field,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: labels[index]),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancelVoice),
        ),
        FilledButton(
          key: const Key('confirm-pin-action'),
          onPressed: () => Navigator.pop(
            context,
            fields.map((field) => field.text).toList(growable: false),
          ),
          child: Text(l.continueLabel),
        ),
      ],
    );
  }
}

String lockFailureMessage(AppLocalizations l, FailureCode failure) =>
    switch (failure) {
      FailureCode.invalidPin => l.pinRequirements,
      FailureCode.pinMismatch => l.pinMismatch,
      FailureCode.incorrectPin => l.incorrectPin,
      FailureCode.lockThrottled => l.tryAgainLater,
      FailureCode.biometricUnavailable ||
      FailureCode.biometricNotEnrolled => l.biometricUnavailable,
      FailureCode.biometricCancelled => l.biometricCancelled,
      FailureCode.biometricTemporarilyLocked ||
      FailureCode.biometricPermanentlyLocked => l.biometricLocked,
      FailureCode.biometricFailed => l.biometricFailed,
      FailureCode.secureStorageUnavailable ||
      FailureCode.lockConfigurationInvalid => l.lockConfigurationError,
      FailureCode.authenticationStale => l.authenticationCancelled,
      _ => l.authenticationRequired,
    };
