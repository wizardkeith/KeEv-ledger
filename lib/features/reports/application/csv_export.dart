import '../../../core/local_id.dart';
import '../../../core/money.dart';
import '../../../core/result.dart';
import '../../bookkeeping/domain/bookkeeping.dart';
import '../../bookkeeping/domain/history_item.dart';
import '../../planning/domain/project.dart';
import '../domain/reports.dart';

final class CsvExportDocument {
  const CsvExportDocument({required this.fileName, required this.contents});
  final String fileName, contents;
}

/// Platform implementations may persist/share this document. Phase 3B keeps
/// the financial calculation and CSV generation independently testable.
abstract interface class LocalCsvExportGateway {
  Future<Result<void>> export(CsvExportDocument document);
}

final class CsvReportExporter {
  const CsvReportExporter();

  CsvExportDocument incomeExpense(IncomeExpenseReport report) {
    final rows = <List<_Cell>>[
      [_text('KeEv Ledger Income & Expense Report')],
      [_text('Start'), _text(report.query.range.start.value)],
      [_text('End'), _text(report.query.range.end.value)],
      [_text('Reporting currency'), _text(report.query.currency.code)],
      [
        _text('Completeness'),
        _text(
          report.totals.completeness.isComplete ? 'complete' : 'incomplete',
        ),
      ],
      [],
      [_text('Summary'), _text('Currency'), _text('Amount')],
      [
        _text('Income'),
        _text(report.totals.income.currency.code),
        _number(report.totals.income),
      ],
      [
        _text('Expense'),
        _text(report.totals.expense.currency.code),
        _number(report.totals.expense),
      ],
      [
        _text('Net'),
        _text(report.totals.net.currency.code),
        _number(report.totals.net),
      ],
      [],
      [
        _text('Category'),
        _text('Income'),
        _text('Expense'),
        _text('Net'),
        _text('Status'),
      ],
      for (final row in report.categories)
        [
          _text(row.name),
          _number(row.totals.income),
          _number(row.totals.expense),
          _number(row.totals.net),
          _text(row.totals.completeness.isComplete ? 'complete' : 'incomplete'),
        ],
      [],
      [
        _text('Account'),
        _text('Income'),
        _text('Expense'),
        _text('Net'),
        _text('Status'),
      ],
      for (final row in report.accounts)
        [
          _text(row.name),
          _number(row.totals.income),
          _number(row.totals.expense),
          _number(row.totals.net),
          _text(row.totals.completeness.isComplete ? 'complete' : 'incomplete'),
        ],
      [],
      [
        _text('Trend date'),
        _text('Income'),
        _text('Expense'),
        _text('Net'),
        _text('Status'),
      ],
      for (final point in report.trend)
        [
          _text(point.date.value),
          _number(point.totals.income),
          _number(point.totals.expense),
          _number(point.totals.net),
          _text(
            point.totals.completeness.isComplete ? 'complete' : 'incomplete',
          ),
        ],
      [],
      [
        _text('FX issue'),
        _text('Source'),
        _text('Target'),
        _text('Business date'),
      ],
      for (final issue in report.totals.completeness.issues)
        [
          _text(issue.resolution.name),
          _text(issue.source.code),
          _text(issue.target.code),
          _text(issue.businessDate.value),
        ],
      [
        _text('Calculation basis'),
        _text(
          'Business date; exact recorded transfer-implied FX; HALF-EVEN rounding',
        ),
      ],
    ];
    return CsvExportDocument(
      fileName:
          'keev-income-expense-${report.query.range.start.value}-${report.query.range.end.value}.csv',
      contents: _encode(rows),
    );
  }

  CsvExportDocument transactionHistory({
    required List<LedgerHistoryItem> items,
    required Map<LocalId, Account> accounts,
    required Map<LocalId, Category> categories,
    required Map<LocalId, Project> projects,
  }) {
    final rows = <List<_Cell>>[
      [
        _text('Type'),
        _text('Business date'),
        _text('Account / source'),
        _text('Destination'),
        _text('Category'),
        _text('Project'),
        _text('Currency'),
        _text('Amount'),
        _text('Received currency'),
        _text('Received amount'),
        _text('Note'),
      ],
      for (final item in items)
        if (item.entry case final entry?)
          [
            _text(entry.kind.name),
            _text(entry.businessDate.value),
            _text(accounts[entry.accountId]?.name ?? ''),
            _text(''),
            _text(categories[entry.categoryId]?.name ?? ''),
            _text(
              entry.projectId == null
                  ? ''
                  : projects[entry.projectId]?.name ?? '',
            ),
            _text(entry.amount.currency.code),
            _number(entry.amount),
            _text(''),
            _text(''),
            _text(entry.note ?? ''),
          ]
        else if (item.transfer case final transfer?)
          [
            _text('transfer'),
            _text(transfer.businessDate.value),
            _text(accounts[transfer.sourceAccountId]?.name ?? ''),
            _text(accounts[transfer.destinationAccountId]?.name ?? ''),
            _text(''),
            _text(''),
            _text(transfer.sent.currency.code),
            _number(transfer.sent),
            _text(transfer.received.currency.code),
            _number(transfer.received),
            _text(transfer.note ?? ''),
          ],
    ];
    return CsvExportDocument(
      fileName: 'keev-transaction-history.csv',
      contents: _encode(rows),
    );
  }

  String _encode(List<List<_Cell>> rows) =>
      '${rows.map((row) => row.map(_escape).join(',')).join('\r\n')}\r\n';

  String _escape(_Cell cell) {
    var value = cell.value;
    if (cell.protectFormula && value.isNotEmpty) {
      final trimmed = value.trimLeft();
      final first = trimmed.isEmpty ? '' : trimmed[0];
      if (first == '=' || first == '+' || first == '-' || first == '@') {
        value = "'$value";
      }
    }
    return '"${value.replaceAll('"', '""')}"';
  }

  _Cell _text(String value) => _Cell(value, protectFormula: true);
  _Cell _number(Money money) => _Cell(_decimal(money), protectFormula: false);

  String _decimal(Money money) {
    final negative = money.minorUnits < 0;
    final digits = money.minorUnits.abs().toString().padLeft(
      money.currency.minorDigits + 1,
      '0',
    );
    if (money.currency.minorDigits == 0) {
      return '${negative ? '-' : ''}$digits';
    }
    final split = digits.length - money.currency.minorDigits;
    return '${negative ? '-' : ''}${digits.substring(0, split)}.${digits.substring(split)}';
  }
}

final class _Cell {
  const _Cell(this.value, {required this.protectFormula});
  final String value;
  final bool protectFormula;
}
