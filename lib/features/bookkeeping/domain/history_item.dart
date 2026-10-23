import '../../../core/local_id.dart';
import 'bookkeeping.dart';
import 'transfer.dart';

/// One presentation-neutral item per business event.
final class LedgerHistoryItem {
  const LedgerHistoryItem._(this.entry, this.transfer);
  factory LedgerHistoryItem.entry(BookkeepingEntry value) =>
      LedgerHistoryItem._(value, null);
  factory LedgerHistoryItem.transfer(LedgerTransfer value) =>
      LedgerHistoryItem._(null, value);

  final BookkeepingEntry? entry;
  final LedgerTransfer? transfer;
  LocalId get id => entry?.id ?? transfer!.id;
  BusinessDate get businessDate =>
      entry?.businessDate ?? transfer!.businessDate;
}
