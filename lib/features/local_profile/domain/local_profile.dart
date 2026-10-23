import '../../../core/currency.dart';
import '../../../core/local_id.dart';
import '../../../core/result.dart';

/// A local identity survives backup/restore without any cloud account.
final class LocalProfile {
  LocalProfile({
    required this.id,
    required this.baseCurrency,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  }) {
    if (!createdAtUtc.isUtc ||
        !updatedAtUtc.isUtc ||
        updatedAtUtc.isBefore(createdAtUtc)) {
      throw ArgumentError('Profile timestamps must be ordered UTC instants');
    }
  }

  final LocalId id;
  final Currency baseCurrency;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
}

abstract interface class LocalProfileRepository {
  Future<Result<LocalProfile?>> read();

  /// Creates exactly one local profile; never overwrites a prior identity.
  Future<Result<LocalProfile>> create({required Currency baseCurrency});
}
