import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../design_system/components.dart';
import '../application/purchase_controller.dart';
import '../domain/purchase.dart';
import 'premium_strings.dart';

final class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key, required this.controller});
  final PurchaseController controller;
  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

final class _PremiumScreenState extends State<PremiumScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(widget.controller.loadProducts());
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final p = widget.controller;
      final l = PremiumStrings.of(context);
      return KeEvScaffold(
        title: l.title,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            KeEvCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KeEvSectionHeader(text: l.title),
                  const SizedBox(height: 12),
                  Text(l.description),
                  const SizedBox(height: 12),
                  Text(
                    p.adFree
                        ? l.active
                        : p.status == EntitlementStatus.pendingVerification ||
                              p.status ==
                                  EntitlementStatus.verificationUnavailable
                        ? l.verification
                        : p.failure == PurchaseFailure.pending
                        ? l.pending
                        : l.signIn,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (p.failure == PurchaseFailure.catalogueIncomplete ||
                !p.purchaseEnabled ||
                !p.catalogue.configured ||
                !p.storeAvailable)
              Text(l.unavailable),
            for (final product in p.products) ...[
              ListTile(
                title: Text(product.title),
                subtitle: Text(
                  [
                    product.description,
                    if (product.period != null)
                      l.billingPeriod(
                        product.period!,
                        Localizations.localeOf(context).languageCode,
                      ),
                  ].where((part) => part.isNotEmpty).toSet().join(' · '),
                ),
                trailing: Text(product.localizedPrice),
                onTap: p.busy || !p.purchaseEnabled
                    ? null
                    : () => p.buy(product),
              ),
            ],
            if (p.products.isNotEmpty) Text(l.recurring),
            const SizedBox(height: 12),
            KeEvSecondaryButton(
              label: l.restore,
              onPressed: p.busy ? null : p.restore,
            ),
            TextButton(
              onPressed: () => launchUrl(
                Uri.parse(
                  Platform.isIOS
                      ? 'https://apps.apple.com/account/subscriptions'
                      : 'https://play.google.com/store/account/subscriptions',
                ),
                mode: LaunchMode.externalApplication,
              ),
              child: Text(l.manage),
            ),
            if (p.failure != null)
              Text(switch (p.failure!) {
                PurchaseFailure.cancelled => l.cancelled,
                PurchaseFailure.pending => l.pending,
                PurchaseFailure.accountMismatch => l.signIn,
                PurchaseFailure.verificationUnavailable => l.verification,
                _ => l.error,
              }),
            // Legal URLs are owner supplied; omit dead or invented links.
          ],
        ),
      );
    },
  );
}
