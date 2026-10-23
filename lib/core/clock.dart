abstract interface class Clock {
  /// Technical timestamps are UTC instants, distinct from business dates.
  DateTime nowUtc();
}

final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}
