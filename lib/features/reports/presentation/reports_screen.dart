import 'package:flutter/material.dart';

import '../../../core/currency.dart';
import '../../../core/money.dart';
import '../../../core/result.dart';
import '../../../design_system/components.dart';
import '../../../localization/generated/app_localizations.dart';
import '../../bookkeeping/application/bookkeeping_session.dart';
import '../../bookkeeping/domain/bookkeeping.dart';
import '../../bookkeeping/presentation/history_view.dart';
import '../../local_profile/domain/local_profile.dart';
import '../application/csv_export.dart';
import '../domain/reports.dart';
import '../../ads/application/ads_controller.dart';
import '../../ads/domain/ads.dart';
import '../../ads/presentation/consent_aware_banner.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, required this.session, this.adsController});
  final BookkeepingSession session;
  final AdsController? adsController;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  Currency? currency;
  bool loading = true;
  FailureCode? failure;
  IncomeExpenseReport? report;
  AssetsLiabilitiesOverview? overview;

  ReportRange get range {
    final end = DateTime(month.year, month.month + 1, 0);
    String date(DateTime value) =>
        '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
    return ReportRange(
      start: BusinessDate(date(month)),
      end: BusinessDate(date(end)),
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => loading = true);
    final profileResult = await widget.session.planning.localProfile();
    if (profileResult is! Success<LocalProfile?> ||
        profileResult.value == null) {
      if (mounted)
        setState(() {
          loading = false;
          failure = FailureCode.localStoreUnavailable;
        });
      return;
    }
    final profile = profileResult.value!;
    currency ??= profile.baseCurrency;
    final query = ReportQuery(
      profileId: profile.id,
      range: range,
      currency: currency!,
    );
    final reportResult = await widget.session.reporting.incomeExpense(query);
    final overviewResult = await widget.session.reporting.assetsLiabilities(
      profileId: profile.id,
      asOf: range.end,
      currency: currency!,
    );
    if (!mounted) return;
    if (reportResult is! Success<IncomeExpenseReport> ||
        overviewResult is! Success<AssetsLiabilitiesOverview>) {
      setState(() {
        loading = false;
        failure = FailureCode.localStoreUnavailable;
      });
      return;
    }
    setState(() {
      report = reportResult.value;
      overview = overviewResult.value;
      failure = null;
      loading = false;
    });
  }

  Future<void> _moveMonth(int delta) async {
    month = DateTime(month.year, month.month + delta);
    await _load();
  }

  Future<void> _showCsv() async {
    final document = const CsvReportExporter().incomeExpense(report!);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).csvReady),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              '${document.fileName}\n\n${document.contents}',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return KeEvScaffold(
      title: l.reports,
      child: loading
          ? const Center(child: KeEvLoadingState())
          : failure != null || report == null || overview == null
          ? KeEvErrorCard(message: l.saveFailed)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(l.reportDisclaimer),
                const SizedBox(height: 12),
                KeEvCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      KeEvSectionHeader(text: l.reportPeriod),
                      Row(
                        children: [
                          IconButton(
                            tooltip: l.previousPeriod,
                            onPressed: () => _moveMonth(-1),
                            icon: const Icon(Icons.chevron_left),
                          ),
                          Expanded(
                            child: Text(
                              '${range.start.value} — ${range.end.value}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            tooltip: l.continueLabel,
                            onPressed: () => _moveMonth(1),
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                      DropdownButtonFormField<Currency>(
                        initialValue: currency,
                        decoration: InputDecoration(
                          labelText: l.reportingCurrency,
                        ),
                        items: [
                          for (final item in Currency.supported)
                            DropdownMenuItem(
                              value: item,
                              child: Text(item.code),
                            ),
                        ],
                        onChanged: (value) async {
                          if (value == null) return;
                          currency = value;
                          await _load();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SummaryCard(report: report!),
                const SizedBox(height: 16),
                _ComparisonCard(report: report!),
                const SizedBox(height: 16),
                _BreakdownCard(
                  title: l.categoryBreakdown,
                  rows: report!.categories,
                ),
                const SizedBox(height: 16),
                _BreakdownCard(
                  title: l.accountBreakdown,
                  rows: report!.accounts,
                ),
                const SizedBox(height: 16),
                _TrendCard(points: report!.trend),
                const SizedBox(height: 16),
                _AssetsCard(overview: overview!),
                const SizedBox(height: 16),
                KeEvPrimaryButton(label: l.prepareCsv, onPressed: _showCsv),
                if (widget.adsController != null) ...[
                  const SizedBox(height: 20),
                  ConsentAwareBanner(
                    controller: widget.adsController!,
                    placement: AdPlacement.reportsFooter,
                    surface: AdSurface.reports,
                  ),
                ],
              ],
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.report});
  final IncomeExpenseReport report;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final totals = report.totals;
    return KeEvCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KeEvSectionHeader(text: l.incomeExpenseReport),
          _amount(context, l.incomeTotal, totals.income),
          _amount(context, l.expenseTotal, totals.expense),
          _amount(context, l.netTotal, totals.net),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                totals.completeness.isComplete
                    ? Icons.check_circle_outline
                    : Icons.sync_problem_outlined,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  totals.completeness.isComplete
                      ? l.reportComplete
                      : '${l.reportIncomplete} · ${totals.completeness.missingCurrencies.join(', ')}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _amount(BuildContext context, String label, Money money) => Padding(
  padding: const EdgeInsets.only(top: 8),
  child: Semantics(
    label: '$label ${displayMoney(money)}',
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Flexible(child: Text(displayMoney(money), textAlign: TextAlign.end)),
      ],
    ),
  ),
);

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({required this.report});
  final IncomeExpenseReport report;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    String comparison(ComparisonMetric metric) {
      final value = metric.percentageChange;
      return value == null
          ? l.comparisonUnavailable
          : l.changeFromPrevious(value.toStringAsFixed(1));
    }

    return KeEvCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KeEvSectionHeader(text: l.previousPeriod),
          Text(
            '${report.comparison.range.start.value} — ${report.comparison.range.end.value}',
          ),
          const SizedBox(height: 8),
          Text('${l.incomeTotal}: ${comparison(report.comparison.income)}'),
          Text('${l.expenseTotal}: ${comparison(report.comparison.expense)}'),
          Text('${l.netTotal}: ${comparison(report.comparison.net)}'),
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({required this.title, required this.rows});
  final String title;
  final List<ReportBreakdown> rows;

  @override
  Widget build(BuildContext context) => KeEvCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KeEvSectionHeader(text: title),
        if (rows.isEmpty)
          Text(AppLocalizations.of(context).noReportData)
        else
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(row.name, style: Theme.of(context).textTheme.titleSmall),
                  Text(
                    '${AppLocalizations.of(context).incomeTotal}: ${displayMoney(row.totals.income)}',
                  ),
                  Text(
                    '${AppLocalizations.of(context).expenseTotal}: ${displayMoney(row.totals.expense)}',
                  ),
                  if (!row.totals.completeness.isComplete)
                    Text(AppLocalizations.of(context).reportIncomplete),
                ],
              ),
            ),
      ],
    ),
  );
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.points});
  final List<TrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return KeEvCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KeEvSectionHeader(text: l.dailyTrend),
          if (points.isEmpty)
            Text(l.noReportData)
          else
            for (final point in points)
              Text(
                '${point.date.value} · ${l.incomeTotal} ${displayMoney(point.totals.income)} · '
                '${l.expenseTotal} ${displayMoney(point.totals.expense)}',
              ),
        ],
      ),
    );
  }
}

class _AssetsCard extends StatelessWidget {
  const _AssetsCard({required this.overview});
  final AssetsLiabilitiesOverview overview;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return KeEvCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KeEvSectionHeader(text: l.assetsLiabilitiesOverview),
          Text(l.asOf(overview.asOf.value)),
          _amount(context, l.assetsLabel, overview.assets),
          _amount(context, l.liabilitiesLabel, overview.liabilities),
          _amount(context, l.netTotal, overview.net),
          const SizedBox(height: 8),
          for (final row in overview.accounts)
            Text(
              '${row.account.name}: '
              '${row.reportedBalance == null ? l.reportIncomplete : displayMoney(row.reportedBalance!)}',
            ),
          if (!overview.completeness.isComplete)
            Text(
              '${l.reportIncomplete} · ${overview.completeness.missingCurrencies.join(', ')}',
            ),
        ],
      ),
    );
  }
}
