import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../application/ads_controller.dart';
import '../domain/ads.dart';
import '../../../localization/generated/app_localizations.dart';

class ConsentAwareBanner extends StatefulWidget {
  const ConsentAwareBanner({
    super.key,
    required this.controller,
    required this.placement,
    required this.surface,
  });
  final AdsController controller;
  final AdPlacement placement;
  final AdSurface surface;
  @override
  State<ConsentAwareBanner> createState() => _ConsentAwareBannerState();
}

class _ConsentAwareBannerState extends State<ConsentAwareBanner> {
  BannerAd? _ad;
  bool _loading = false;
  int? _requestedWidth;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_eligibilityChanged);
  }

  @override
  void didUpdateWidget(covariant ConsentAwareBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_eligibilityChanged);
      widget.controller.addListener(_eligibilityChanged);
      _discard();
    }
  }

  void _eligibilityChanged() {
    if (!mounted) return;
    // Consent/privacy/lock changes invalidate the prior request even when the
    // resulting state permits a new ad under updated choices.
    _discard();
    setState(() {});
  }

  Future<void> _load(int width) async {
    if (_loading || _ad != null || _requestedWidth == width) return;
    _loading = true;
    _requestedWidth = width;
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
    if (!mounted || size == null) {
      _loading = false;
      return;
    }
    final unitId = Platform.isAndroid
        ? widget.controller.configuration.androidBannerId
        : widget.controller.configuration.iosBannerId;
    final ad = BannerAd(
      adUnitId: unitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (loaded) {
          if (!mounted ||
              !widget.controller.canShow(widget.placement, widget.surface)) {
            loaded.dispose();
            return;
          }
          setState(() {
            _ad = loaded as BannerAd;
            _loading = false;
          });
        },
        onAdFailedToLoad: (failed, _) {
          failed.dispose();
          if (mounted) setState(() => _loading = false);
        },
      ),
    );
    await ad.load();
  }

  void _discard() {
    _ad?.dispose();
    _ad = null;
    _loading = false;
    _requestedWidth = null;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_eligibilityChanged);
    _discard();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.canShow(widget.placement, widget.surface) ||
        (!Platform.isAndroid && !Platform.isIOS))
      return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.floor();
        if (width > 0 && _ad == null && !_loading) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _load(width));
        }
        final ad = _ad;
        if (ad == null) return const SizedBox.shrink();
        return SafeArea(
          top: false,
          child: Semantics(
            container: true,
            label: AppLocalizations.of(context).advertisement,
            child: SizedBox(
              width: ad.size.width.toDouble(),
              height: ad.size.height.toDouble(),
              child: AdWidget(ad: ad),
            ),
          ),
        );
      },
    );
  }
}
