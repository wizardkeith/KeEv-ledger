import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../design_system/components.dart';
import '../../../localization/generated/app_localizations.dart';
import '../../settings/application/settings_controller.dart';
import '../../settings/presentation/settings_screens.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.controller,
    required this.onStart,
  });
  final SettingsController controller;
  final VoidCallback onStart;
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool privacy = false, accepted = false;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return KeEvScaffold(
      title: l.appTitle,
      child: ListView(
        key: ValueKey(privacy),
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/brand/keev-logo-original.png',
                width: 112,
                height: 112,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
            ),
          ),
          const SizedBox(height: 24),
          KeEvSectionHeader(text: privacy ? l.privacyIntro : l.welcome),
          const SizedBox(height: 12),
          if (!const bool.fromEnvironment('dart.vm.product')) Text(l.preview),
          const SizedBox(height: 16),
          if (!privacy) ...[
            Text(l.languageIntro),
            LanguageChoices(controller: widget.controller),
            KeEvPrimaryButton(
              key: const Key('onboarding-continue'),
              label: l.continueLabel,
              onPressed: () => setState(() => privacy = true),
            ),
          ] else ...[
            KeEvCard(child: Text(const bool.fromEnvironment('dart.vm.product')
                ? l.localOnlyDataNotice : l.developmentLegal)),
            const SizedBox(height: 16),
            if (configuredLegalUrl('PRIVACY_POLICY_URL') != null || !const bool.fromEnvironment('dart.vm.product')) KeEvSecondaryButton(
              key: const Key('privacy-link'),
              label: l.privacyPolicy,
              onPressed: () => showLegal(context, l.privacyPolicy, url: configuredLegalUrl('PRIVACY_POLICY_URL')),
            ),
            const SizedBox(height: 12),
            if (configuredLegalUrl('TERMS_URL') != null || !const bool.fromEnvironment('dart.vm.product')) KeEvSecondaryButton(
              key: const Key('terms-link'),
              label: l.terms,
              onPressed: () => showLegal(context, l.terms, url: configuredLegalUrl('TERMS_URL')),
            ),
            if (!const bool.fromEnvironment('dart.vm.product')) CheckboxListTile(
              key: const Key('accept-preview'),
              value: accepted,
              onChanged: (value) => setState(() => accepted = value ?? false),
              title: Text(l.acceptPreview),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            Text(l.sessionNotice),
            const SizedBox(height: 16),
            KeEvPrimaryButton(
              key: const Key('start-local'),
              label: l.startLocal,
              onPressed: const bool.fromEnvironment('dart.vm.product') || accepted
                  ? widget.onStart : null,
            ),
            const SizedBox(height: 12),
            KeEvSecondaryButton(
              label: l.back,
              onPressed: () => setState(() => privacy = false),
            ),
          ],
          if (widget.controller.failure != null)
            KeEvErrorCard(message: l.preferencesError),
        ],
      ),
    );
  }
}

Uri? configuredLegalUrl(String name) {
  final raw = switch(name) {
    'PRIVACY_POLICY_URL' => const String.fromEnvironment('PRIVACY_POLICY_URL'),
    'TERMS_URL' => const String.fromEnvironment('TERMS_URL'),
    'ACCOUNT_DELETION_URL' => const String.fromEnvironment('ACCOUNT_DELETION_URL'),
    _ => '',
  };
  final uri = Uri.tryParse(raw);
  return uri?.scheme == 'https' && uri!.host.isNotEmpty ? uri : null;
}

Future<void> showLegal(BuildContext context, String title, {Uri? url}) {
  if (url != null) return launchUrl(url, mode: LaunchMode.externalApplication).then((_) {});
  if (const bool.fromEnvironment('dart.vm.product')) return Future.value();
  return showDialog<void>(
  context: context,
  animationStyle: AnimationStyle.noAnimation,
  builder: (context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(title),
      scrollable: true,
      content: Text(l.developmentLegal),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.close),
        ),
      ],
    );
  },
  );
}
