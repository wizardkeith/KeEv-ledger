# Phase 10 actual findings

| ID | Priority | Area | Finding | Status / fix | Verification |
|---|---|---|---|---|---|
| QA-10-01 | P2 | Backup accessibility | The passphrase dialog used a fixed Column; on a small phone with large text and keyboard, content could overflow and controls become hard to reach. | Fixed in source: scrollable dialog content. | Added 320×568, 200% Thai widget regression in `backup_delete_confirmation_test.dart`; **NOT EXECUTABLE IN CURRENT ENVIRONMENT**. Owner/CI must run and confirm on real device. |
| QA-10-02 | P2 | Large ledger history | `HistoryView` eagerly constructed every card and receipt-strip query under an outer `ListView`, even for offscreen transactions. | Fixed in source: the history tab owns a lazy `ListView.builder`; receipt strips build for viewport items. | Added 80-record synthetic widget regression; **NOT EXECUTABLE IN CURRENT ENVIRONMENT**. Flutter CI and on-device scroll/search profiling required. |
| QA-10-03 | P1 | History / Receipt data association | A stateful receipt strip could retain the preceding transaction's attachment Future when filter/search/reorder changed the transaction at a lazy-list index. | Fixed in source: stable transaction/transfer row keys, profile-and-transaction receipt-strip key, and `didUpdateWidget` source-change reload. | Added widget regressions for receipt→empty, empty→receipt and opening the correct file after reordered filters in `history_receipt_identity_test.dart`; **NOT EXECUTABLE IN CURRENT ENVIRONMENT**. Flutter CI must confirm. |

The owner-side review identified QA-10-03 after Phase 10. Its source fix is present; Flutter execution and native flows remain unverified, so this does not establish a runtime P1 clearance.
