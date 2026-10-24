import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../bookkeeping/application/bookkeeping_session.dart';
import '../../bookkeeping/presentation/quick_add_screen.dart';
import '../../bookkeeping/presentation/history_view.dart';
import '../../../design_system/components.dart';
import '../../../localization/generated/app_localizations.dart';
import '../../settings/application/settings_controller.dart';
import '../../planning/presentation/planning_screens.dart';
import '../../app_lock/application/app_lock_controller.dart';
import '../../account/application/account_controller.dart';
import '../../ads/application/ads_controller.dart';
import '../../purchases/application/purchase_controller.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.controller,
    required this.runtime,
    required this.appLockController,
    required this.accountController,
    this.adsController,
    this.purchaseController,
  });
  final SettingsController controller;
  final BookkeepingSession runtime;
  final AppLockController appLockController;
  final AccountController accountController;
  final AdsController? adsController;
  final PurchaseController? purchaseController;
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int selected = 0;
  int historyRevision = 0;
  Future<void> _add() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        settings: const RouteSettings(name: 'quick-add'),
        builder: (_) => QuickAddScreen(session: widget.runtime),
      ),
    );
    if (saved == true && mounted) setState(() => historyRevision++);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final titles = [l.home, l.history, l.add, l.budget, l.more];
    return KeEvScaffold(
      title: titles[selected],
      bottomNavigationBar: KeEvNavigationBar(
        selected: selected,
        onSelected: (value) => setState(() => selected = value),
        onAdd: _add,
      ),
      child: selected == 1
          ? HistoryView(key: ValueKey(historyRevision), session: widget.runtime)
          : selected == 3
          ? ListView(
              key: PageStorageKey(selected),
              padding: const EdgeInsets.all(16),
              children: [BudgetView(session: widget.runtime)],
            )
          : ListView(
              key: PageStorageKey(selected),
              padding: const EdgeInsets.all(16),
              children: [
                Text(l.preview),
                const SizedBox(height: 24),
                if (selected == 0) ...[
                  KeEvCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        KeEvSectionHeader(text: l.welcome),
                        const SizedBox(height: 12),
                        Text(l.intro),
                        const SizedBox(height: 20),
                        KeEvPrimaryButton(label: l.add, onPressed: _add),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  for (final page in [AppPage.accounts, AppPage.reports])
                    routeTile(context, page),
                ] else ...[
                  for (final page in [
                    AppPage.accounts,
                    AppPage.projects,
                    AppPage.reports,
                    AppPage.settings,
                    AppPage.backup,
                    AppPage.authentication,
                    AppPage.premium,
                  ])
                    routeTile(context, page),
                  const SizedBox(height: 16),
                  Text(l.sessionNotice),
                ],
              ],
            ),
    );
  }

  Widget routeTile(BuildContext context, AppPage page) => ListTile(
    key: Key('route-${page.name}'),
    title: Text(pageTitle(AppLocalizations.of(context), page)),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => openPage(
      context,
      page,
      widget.controller,
      session: widget.runtime,
      appLockController: widget.appLockController,
      accountController: widget.accountController,
      adsController: widget.adsController,
      purchaseController: widget.purchaseController,
    ),
  );
}
