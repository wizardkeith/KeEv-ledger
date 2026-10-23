import 'result.dart';

/// Future application commands can compose multiple repository writes atomically.
abstract interface class LocalUnitOfWork {
  /// Any typed failure rolls the transaction back, even if no exception leaks.
  Future<Result<T>> run<T>(Future<Result<T>> Function() action);
}
