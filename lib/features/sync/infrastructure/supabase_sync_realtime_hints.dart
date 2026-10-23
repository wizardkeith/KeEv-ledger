import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/result.dart';
import '../application/sync_trigger_coordinator.dart';

/// Private Broadcast invalidation only. No financial payload is consumed.
final class SupabaseSyncRealtimeHints implements SyncRealtimeHints {
  SupabaseSyncRealtimeHints(this.client);
  final SupabaseClient client;
  RealtimeChannel? _channel;

  @override
  Future<Result<void>> subscribe({
    required String accountId,
    required String generation,
    required void Function(String generation) onInvalidated,
  }) async {
    await unsubscribe();
    try {
      final topic = 'keev-ledger:$accountId:$generation';
      final channel = client.channel(
        topic,
        opts: const RealtimeChannelConfig(private: true),
      );
      var hasSubscribed = false;
      channel
          .onBroadcast(
            event: 'sync_invalidated',
            callback: (payload) {
              final value = payload['generation'];
              if (value is String) onInvalidated(value);
            },
          )
          .subscribe((status, _) {
            if (status != RealtimeSubscribeStatus.subscribed) return;
            if (hasSubscribed) {
              // A reconnect means hints may have been missed. Trigger the
              // authoritative durable pull rather than trusting replay.
              onInvalidated(generation);
            }
            hasSubscribed = true;
          });
      _channel = channel;
      return const Success(null);
    } on Object {
      // Realtime is only an optimization. Durable resume/manual pull remains
      // authoritative and usable when WebSocket setup fails.
      return const Failure(FailureCode.syncBackendUnavailable);
    }
  }

  @override
  Future<void> unsubscribe() async {
    final channel = _channel;
    _channel = null;
    if (channel == null) return;
    try {
      await client.removeChannel(channel);
    } on Object {
      // A stale socket cannot affect durable push/pull correctness.
    }
  }
}
