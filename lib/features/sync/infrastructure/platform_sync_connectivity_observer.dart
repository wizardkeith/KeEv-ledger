import 'dart:async';

import 'package:flutter/services.dart';

import '../application/sync_connectivity.dart';

/// Native network-interface hint. RPC outcomes remain authoritative.
final class PlatformSyncConnectivityObserver
    implements SyncConnectivityObserver {
  PlatformSyncConnectivityObserver({EventChannel? channel})
    : _channel =
          channel ?? const EventChannel('com.keev.ledger/sync_connectivity');

  final EventChannel _channel;
  StreamSubscription<Object?>? _subscription;

  @override
  Future<void> start(void Function(bool potentiallyOnline) onChanged) async {
    await dispose();
    _subscription = _channel.receiveBroadcastStream().listen((value) {
      if (value is bool) onChanged(value);
    }, onError: (_) => onChanged(false));
  }

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
