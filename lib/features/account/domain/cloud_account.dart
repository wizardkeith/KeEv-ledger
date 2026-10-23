enum AuthenticationProvider { apple, google, emailOtp }

enum AccountSessionState {
  localOnly,
  signedOut,
  authenticating,
  authenticated,
  requiresReauthentication,
  temporarilyUnavailable,
}

final class ProviderIdentity {
  const ProviderIdentity({required this.provider, required this.subject});

  final AuthenticationProvider provider;
  final String subject;

  @override
  bool operator ==(Object other) =>
      other is ProviderIdentity &&
      other.provider == provider &&
      other.subject == subject;

  @override
  int get hashCode => Object.hash(provider, subject);
}

final class CloudAccount {
  CloudAccount({
    required this.id,
    required this.identities,
    required this.createdAtUtc,
    this.email,
    this.displayName,
  }) {
    if (id.trim().isEmpty ||
        identities.isEmpty ||
        !createdAtUtc.isUtc ||
        identities.any((identity) => identity.subject.trim().isEmpty)) {
      throw ArgumentError('Invalid cloud account');
    }
  }

  final String id;
  final List<ProviderIdentity> identities;
  final String? email;
  final String? displayName;
  final DateTime createdAtUtc;
}

final class AuthenticatedSession {
  AuthenticatedSession({
    required this.account,
    required this.expiresAtUtc,
    required this.canRefresh,
  }) {
    if (!expiresAtUtc.isUtc) throw ArgumentError('Expiry must be UTC');
  }

  final CloudAccount account;
  final DateTime expiresAtUtc;
  final bool canRefresh;
}
