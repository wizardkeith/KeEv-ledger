import 'sync_trigger_coordinator.dart';

abstract interface class SyncConnectivityObserver {
  Future<void> start(void Function(bool potentiallyOnline) onChanged);
  Future<void> dispose();
}

/// Owns the production observer subscription and its coordinator connection.
final class SyncConnectivityBinding {
  SyncConnectivityBinding({required this.observer, required this.coordinator});
  final SyncConnectivityObserver observer;
  final SyncTriggerCoordinator coordinator;
  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    await observer.start(coordinator.connectivityChanged);
  }

  Future<void> dispose() async {
    if (!_started) return;
    _started = false;
    await observer.dispose();
  }
}
