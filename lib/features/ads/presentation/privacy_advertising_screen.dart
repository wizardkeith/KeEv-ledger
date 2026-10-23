import 'package:flutter/material.dart';

import '../../../design_system/components.dart';
import '../../../localization/generated/app_localizations.dart';
import '../application/ads_controller.dart';

class PrivacyAdvertisingScreen extends StatelessWidget {
  const PrivacyAdvertisingScreen({super.key, required this.controller});
  final AdsController controller;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final l = AppLocalizations.of(context);
      return KeEvScaffold(
        title: l.privacyAdvertising,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            KeEvCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  KeEvSectionHeader(text: l.advertisingPreferences),
                  const SizedBox(height: 12),
                  Text(l.advertisingPrivacyExplanation),
                  if (controller.privacyOptionsRequired) ...[
                    const SizedBox(height: 20),
                    KeEvPrimaryButton(
                      key: const Key('open-ad-privacy-options'),
                      label: l.managePrivacyChoices,
                      onPressed: controller.showPrivacyOptions,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
