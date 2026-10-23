enum AppEnvironment { development, staging, production }

final class SupabaseConfiguration {
  const SupabaseConfiguration({
    required this.url,
    required this.publishableKey,
    this.googleWebClientId,
    this.googleIosClientId,
    this.appleServiceId,
    this.appleRedirectUri,
  });

  final Uri url;
  final String publishableKey;
  final String? googleWebClientId;
  final String? googleIosClientId;
  final String? appleServiceId;
  final Uri? appleRedirectUri;

  static SupabaseConfiguration? fromValues({
    required String url,
    required String publishableKey,
    String googleWebClientId = '',
    String googleIosClientId = '',
    String appleServiceId = '',
    String appleRedirectUri = '',
  }) {
    final parsed = Uri.tryParse(url.trim());
    if (parsed == null ||
        parsed.scheme != 'https' ||
        parsed.host.isEmpty ||
        publishableKey.trim().isEmpty) {
      return null;
    }
    final redirect = Uri.tryParse(appleRedirectUri.trim());
    return SupabaseConfiguration(
      url: parsed,
      publishableKey: publishableKey.trim(),
      googleWebClientId: _optional(googleWebClientId),
      googleIosClientId: _optional(googleIosClientId),
      appleServiceId: _optional(appleServiceId),
      appleRedirectUri:
          redirect != null &&
              redirect.scheme == 'https' &&
              redirect.host.isNotEmpty
          ? redirect
          : null,
    );
  }

  static SupabaseConfiguration? fromEnvironment() => fromValues(
    url: const String.fromEnvironment('SUPABASE_URL'),
    publishableKey: const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
    googleWebClientId: const String.fromEnvironment('GOOGLE_WEB_CLIENT_ID'),
    googleIosClientId: const String.fromEnvironment('GOOGLE_IOS_CLIENT_ID'),
    appleServiceId: const String.fromEnvironment('APPLE_SERVICE_ID'),
    appleRedirectUri: const String.fromEnvironment('APPLE_REDIRECT_URI'),
  );

  static String? _optional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class AppConfiguration {
  const AppConfiguration(this.environment, {this.supabase, this.ads});
  final AppEnvironment environment;
  final SupabaseConfiguration? supabase;
  final AdsConfiguration? ads;
}

final class AdsConfiguration {
  const AdsConfiguration({
    required this.environment,
    required this.featureEnabled,
    required this.trackingEnabled,
    required this.androidBannerId,
    required this.iosBannerId,
  });

  static const androidTestBannerId = 'ca-app-pub-3940256099942544/9214589741';
  static const iosTestBannerId = 'ca-app-pub-3940256099942544/2435281174';

  final AppEnvironment environment;
  final bool featureEnabled;
  final bool trackingEnabled;
  final String androidBannerId;
  final String iosBannerId;

  bool get usesTestAds => environment != AppEnvironment.production;

  bool get hasProductionIds =>
      environment != AppEnvironment.production ||
      (androidBannerId.trim().isNotEmpty && iosBannerId.trim().isNotEmpty);

  bool get enabled => featureEnabled && hasProductionIds;

  factory AdsConfiguration.fromEnvironment(AppEnvironment environment) {
    const enabled = bool.fromEnvironment('ADS_ENABLED', defaultValue: false);
    const tracking = bool.fromEnvironment(
      'ADS_TRACKING_ENABLED',
      defaultValue: false,
    );
    if (environment != AppEnvironment.production) {
      return AdsConfiguration(
        environment: environment,
        featureEnabled: enabled,
        trackingEnabled: tracking,
        androidBannerId: androidTestBannerId,
        iosBannerId: iosTestBannerId,
      );
    }
    return AdsConfiguration(
      environment: environment,
      featureEnabled: enabled,
      trackingEnabled: tracking,
      androidBannerId: const String.fromEnvironment('ADMOB_ANDROID_BANNER_ID'),
      iosBannerId: const String.fromEnvironment('ADMOB_IOS_BANNER_ID'),
    );
  }
}
