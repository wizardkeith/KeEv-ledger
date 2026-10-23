import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/currency.dart';
import '../../../core/local_id.dart';
import '../../../core/money.dart';
import '../../../core/result.dart';
import '../../../design_system/components.dart';
import '../../../localization/generated/app_localizations.dart';
import '../../bookkeeping/application/bookkeeping_session.dart';
import '../../bookkeeping/application/money_input.dart';
import '../../bookkeeping/domain/bookkeeping.dart';
import '../../local_profile/domain/local_profile.dart';
import '../domain/budget.dart';
import '../domain/project.dart';

String _money(Money money) {
  final negative = money.minorUnits < 0;
  final digits = money.minorUnits.abs().toString().padLeft(
    money.currency.minorDigits + 1,
    '0',
  );
  final value = money.currency.minorDigits == 0
      ? digits
      : '${digits.substring(0, digits.length - money.currency.minorDigits)}.'
            '${digits.substring(digits.length - money.currency.minorDigits)}';
  return '${money.currency.code} ${negative ? '-' : ''}$value';
}

class BudgetView extends StatefulWidget {
  const BudgetView({super.key, required this.session});
  final BookkeepingSession session;

  @override
  State<BudgetView> createState() => _BudgetViewState();
}

class _BudgetViewState extends State<BudgetView> {
  bool loading = true;
  LocalProfile? profile;
  List<Budget> budgets = [];
  List<Category> categories = [];
  Map<LocalId, BudgetProgress> progress = {};
  FailureCode? failure;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
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
    final localProfile = profileResult.value!;
    final budgetResult = await widget.session.planning.listBudgets(
      localProfile.id,
    );
    final categoryResult = await widget.session.service.listCategories(
      localProfile.id,
      kind: EntryKind.expense,
    );
    if (budgetResult is! Success<List<Budget>> ||
        categoryResult is! Success<List<Category>>) {
      if (mounted)
        setState(() {
          loading = false;
          failure = FailureCode.localStoreUnavailable;
        });
      return;
    }
    final calculated = <LocalId, BudgetProgress>{};
    for (final budget in budgetResult.value) {
      final result = await widget.session.planning.calculateBudget(budget);
      if (result is Success<BudgetProgress>)
        calculated[budget.id] = result.value;
    }
    if (!mounted) return;
    setState(() {
      profile = localProfile;
      budgets = budgetResult.value;
      categories = categoryResult.value;
      progress = calculated;
      failure = null;
      loading = false;
    });
  }

  Future<void> _create() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => _BudgetDialog(
        session: widget.session,
        profile: profile!,
        categories: categories,
      ),
    );
    if (created == true && mounted) await _load();
  }

  Future<void> _archive(Budget budget) async {
    final result = await widget.session.planning.archiveBudget(
      budget.profileId,
      budget.id,
    );
    if (result is Success<Budget> && mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (loading) return const KeEvLoadingState();
    if (failure != null || profile == null)
      return KeEvErrorCard(message: l.saveFailed);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KeEvPrimaryButton(label: l.addBudget, onPressed: _create),
        const SizedBox(height: 16),
        if (budgets.isEmpty)
          KeEvCard(child: Text(l.noBudgets))
        else
          for (final budget in budgets) ...[
            _BudgetCard(
              budget: budget,
              progress: progress[budget.id],
              onArchive: () => _archive(budget),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.budget,
    required this.progress,
    required this.onArchive,
  });
  final Budget budget;
  final BudgetProgress? progress;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final current = progress;
    final fraction = current?.fraction;
    return KeEvCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  budget.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: l.archive,
                onPressed: onArchive,
                icon: const Icon(Icons.archive_outlined),
              ),
            ],
          ),
          Text('${budget.month.value} · ${_money(budget.amount)}'),
          const SizedBox(height: 12),
          if (current == null)
            const KeEvLoadingState()
          else ...[
            Semantics(
              label: '${l.spent}: ${_money(current.spent)}',
              child: LinearProgressIndicator(
                value: fraction == null ? 0 : fraction.clamp(0, 1),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                Text('${l.spent}: ${_money(current.spent)}'),
                Text('${l.remaining}: ${_money(current.remaining)}'),
              ],
            ),
            if (current.isOverBudget)
              Row(
                children: [
                  const Icon(Icons.warning_amber_outlined),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l.overBudget)),
                ],
              ),
            if (!current.isComplete)
              Row(
                children: [
                  const Icon(Icons.sync_problem_outlined),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l.missingFx(current.missingCurrencies.join(', ')),
                    ),
                  ),
                ],
              ),
          ],
          Text(l.warningAt(budget.warningThresholdPercent)),
        ],
      ),
    );
  }
}

class _BudgetDialog extends StatefulWidget {
  const _BudgetDialog({
    required this.session,
    required this.profile,
    required this.categories,
  });
  final BookkeepingSession session;
  final LocalProfile profile;
  final List<Category> categories;

  @override
  State<_BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<_BudgetDialog> {
  final name = TextEditingController();
  final amount = TextEditingController();
  late final TextEditingController month;
  late Currency currency = widget.profile.baseCurrency;
  LocalId? categoryId;
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    month = TextEditingController(
      text: BudgetMonth.fromDate(DateTime.now()).value,
    );
  }

  @override
  void dispose() {
    name.dispose();
    amount.dispose();
    month.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final title = name.text.trim();
    final parsed = MoneyInput.parseNonNegative(amount.text, currency);
    BudgetMonth period;
    try {
      period = BudgetMonth(month.text.trim());
    } on FormatException {
      setState(() => error = l.invalidMonth);
      return;
    }
    if (title.isEmpty || title.length > 120) {
      setState(() => error = l.budgetName);
      return;
    }
    if (parsed is Failure<Money>) {
      setState(() => error = l.invalidMoney);
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    final result = await widget.session.planning.createBudget(
      profileId: widget.profile.id,
      name: title,
      amount: (parsed as Success<Money>).value,
      month: period,
      categoryId: categoryId,
    );
    if (!mounted) return;
    if (result is Success<Budget>) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        saving = false;
        error = l.saveFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.addBudget),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('budget-name'),
            controller: name,
            decoration: InputDecoration(labelText: l.budgetName),
          ),
          TextField(
            key: const Key('budget-amount'),
            controller: amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: InputDecoration(
              labelText: l.budgetAmount,
              suffixText: currency.code,
            ),
          ),
          DropdownButtonFormField<Currency>(
            initialValue: currency,
            decoration: InputDecoration(labelText: l.currency),
            items: [
              for (final c in Currency.supported)
                DropdownMenuItem(value: c, child: Text(c.code)),
            ],
            onChanged: saving
                ? null
                : (value) => setState(() {
                    if (value != null) currency = value;
                  }),
          ),
          TextField(
            key: const Key('budget-month'),
            controller: month,
            decoration: InputDecoration(
              labelText: l.budgetMonth,
              hintText: 'YYYY-MM',
            ),
          ),
          DropdownButtonFormField<LocalId?>(
            initialValue: categoryId,
            isExpanded: true,
            decoration: InputDecoration(labelText: l.budgetCategory),
            items: [
              DropdownMenuItem<LocalId?>(
                value: null,
                child: Text(l.allExpenses),
              ),
              for (final category in widget.categories)
                DropdownMenuItem<LocalId?>(
                  value: category.id,
                  child: Text(category.name, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: saving
                ? null
                : (value) => setState(() => categoryId = value),
          ),
          if (error != null)
            Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context, false),
          child: Text(l.close),
        ),
        FilledButton(
          key: const Key('create-budget'),
          onPressed: saving ? null : _save,
          child: Text(l.create),
        ),
      ],
    );
  }
}

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key, required this.session});
  final BookkeepingSession session;

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  bool loading = true;
  LocalProfile? profile;
  List<Project> projects = [];
  Map<LocalId, ProjectSummary> summaries = {};
  FailureCode? failure;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
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
    final localProfile = profileResult.value!;
    final result = await widget.session.planning.listProjects(
      localProfile.id,
      includeArchived: true,
    );
    if (result is! Success<List<Project>>) {
      if (mounted)
        setState(() {
          loading = false;
          failure = FailureCode.localStoreUnavailable;
        });
      return;
    }
    final calculated = <LocalId, ProjectSummary>{};
    for (final project in result.value) {
      final summary = await widget.session.planning.calculateProjectSummary(
        project: project,
        currency: localProfile.baseCurrency,
      );
      if (summary is Success<ProjectSummary>)
        calculated[project.id] = summary.value;
    }
    if (!mounted) return;
    setState(() {
      profile = localProfile;
      projects = result.value;
      summaries = calculated;
      loading = false;
      failure = null;
    });
  }

  Future<void> _edit([Project? project]) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => _ProjectDialog(
        session: widget.session,
        profileId: profile!.id,
        project: project,
      ),
    );
    if (changed == true && mounted) await _load();
  }

  Future<void> _archive(Project project) async {
    final result = await widget.session.planning.archiveProject(
      project.profileId,
      project.id,
    );
    if (result is Success<Project> && mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return KeEvScaffold(
      title: l.projects,
      child: loading
          ? const Center(child: KeEvLoadingState())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (failure != null || profile == null)
                  KeEvErrorCard(message: l.saveFailed)
                else ...[
                  KeEvPrimaryButton(label: l.addProject, onPressed: _edit),
                  const SizedBox(height: 16),
                  if (projects.isEmpty)
                    KeEvCard(child: Text(l.noProjects))
                  else
                    for (final project in projects) ...[
                      _ProjectCard(
                        project: project,
                        summary: summaries[project.id],
                        onEdit: project.isArchived
                            ? null
                            : () => _edit(project),
                        onArchive: project.isArchived
                            ? null
                            : () => _archive(project),
                      ),
                      const SizedBox(height: 12),
                    ],
                ],
              ],
            ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.project,
    required this.summary,
    required this.onEdit,
    required this.onArchive,
  });
  final Project project;
  final ProjectSummary? summary;
  final VoidCallback? onEdit, onArchive;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return KeEvCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  project.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: l.edit,
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: l.archive,
                onPressed: onArchive,
                icon: const Icon(Icons.archive_outlined),
              ),
            ],
          ),
          if (project.description?.isNotEmpty == true)
            Text(project.description!),
          if (project.isArchived) Text(l.projectArchived),
          if (summary != null) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: [
                Text('${l.incomeTotal}: ${_money(summary!.income)}'),
                Text('${l.expenseTotal}: ${_money(summary!.expense)}'),
                Text('${l.netTotal}: ${_money(summary!.net)}'),
              ],
            ),
            if (!summary!.isComplete)
              Text(l.missingFx(summary!.missingCurrencies.join(', '))),
          ],
        ],
      ),
    );
  }
}

class _ProjectDialog extends StatefulWidget {
  const _ProjectDialog({
    required this.session,
    required this.profileId,
    this.project,
  });
  final BookkeepingSession session;
  final LocalId profileId;
  final Project? project;

  @override
  State<_ProjectDialog> createState() => _ProjectDialogState();
}

class _ProjectDialogState extends State<_ProjectDialog> {
  late final TextEditingController name = TextEditingController(
    text: widget.project?.name,
  );
  late final TextEditingController description = TextEditingController(
    text: widget.project?.description,
  );
  bool saving = false;
  String? error;

  @override
  void dispose() {
    name.dispose();
    description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final title = name.text.trim();
    final detail = description.text.trim();
    if (title.isEmpty || title.length > 120 || detail.length > 500) {
      setState(() => error = l.projectName);
      return;
    }
    setState(() {
      saving = true;
      error = null;
    });
    final result = widget.project == null
        ? await widget.session.planning.createProject(
            profileId: widget.profileId,
            name: title,
            description: detail.isEmpty ? null : detail,
          )
        : await widget.session.planning.updateProject(
            project: widget.project!,
            name: title,
            description: detail.isEmpty ? null : detail,
          );
    if (!mounted) return;
    if (result is Success<Project>) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        saving = false;
        error = l.saveFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.project == null ? l.addProject : l.edit),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('project-name'),
            controller: name,
            decoration: InputDecoration(labelText: l.projectName),
          ),
          TextField(
            key: const Key('project-description'),
            controller: description,
            maxLines: 3,
            decoration: InputDecoration(labelText: l.projectDescription),
          ),
          if (error != null)
            Text(
              error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context, false),
          child: Text(l.close),
        ),
        FilledButton(
          key: const Key('save-project'),
          onPressed: saving ? null : _save,
          child: Text(l.save),
        ),
      ],
    );
  }
}
