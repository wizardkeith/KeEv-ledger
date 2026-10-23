import 'package:flutter/material.dart';

import '../localization/generated/app_localizations.dart';
import 'theme.dart';

class KeEvScaffold extends StatelessWidget {
  const KeEvScaffold({
    super.key,
    required this.title,
    required this.child,
    this.bottomNavigationBar,
  });
  final String title;
  final Widget child;
  final Widget? bottomNavigationBar;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title, maxLines: 2),
      toolbarHeight: 56 + MediaQuery.textScalerOf(context).scale(24),
    ),
    body: SafeArea(child: child),
    bottomNavigationBar: bottomNavigationBar,
  );
}

class KeEvCard extends StatelessWidget {
  const KeEvCard({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(24),
    ),
    child: child,
  );
}

class KeEvPrimaryButton extends StatelessWidget {
  const KeEvPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onPressed,
    child: Text(label, textAlign: TextAlign.center),
  );
}

class KeEvSecondaryButton extends StatelessWidget {
  const KeEvSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onPressed,
    child: Text(label, textAlign: TextAlign.center),
  );
}

class KeEvSectionHeader extends StatelessWidget {
  const KeEvSectionHeader({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(text, style: Theme.of(context).textTheme.headlineSmall),
  );
}

class KeEvEmptyState extends StatelessWidget {
  const KeEvEmptyState({super.key, this.icon = Icons.wallet_outlined});
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return KeEvCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 36),
          const SizedBox(height: 16),
          KeEvSectionHeader(text: l.emptyTitle),
          const SizedBox(height: 12),
          Text(l.emptyBody),
        ],
      ),
    );
  }
}

class KeEvLoadingState extends StatelessWidget {
  const KeEvLoadingState({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Text(AppLocalizations.of(context).loading),
  );
}

class KeEvErrorCard extends StatelessWidget {
  const KeEvErrorCard({super.key, required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: KeEvCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline),
          Text(
            AppLocalizations.of(context).errorTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(message),
        ],
      ),
    ),
  );
}

class KeEvAmountText extends StatelessWidget {
  const KeEvAmountText({
    super.key,
    required this.formattedAmount,
    required this.semanticLabel,
  });
  final String formattedAmount, semanticLabel;
  @override
  Widget build(BuildContext context) => Text(
    formattedAmount,
    semanticsLabel: semanticLabel,
    style: KeEvTypography.financialAmount(
      Theme.of(context).textTheme,
      large: true,
    ),
  );
}

class KeEvNavigationBar extends StatelessWidget {
  const KeEvNavigationBar({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.onAdd,
  });
  final int selected;
  final ValueChanged<int> onSelected;
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final labels = [l.home, l.history, l.add, l.budget, l.more];
    const icons = [
      Icons.home_outlined,
      Icons.receipt_long_outlined,
      Icons.add,
      Icons.pie_chart_outline,
      Icons.more_horiz,
    ];
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(5, (i) {
              final body = Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icons[i]),
                  const SizedBox(height: 4),
                  Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: i == 2
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              );
              return Expanded(
                child: Semantics(
                  selected: i == 2 ? null : i == selected,
                  child: i == 2
                      ? FilledButton(
                          key: const Key('nav-add'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 12,
                            ),
                          ),
                          onPressed: onAdd,
                          child: body,
                        )
                      : TextButton(
                          key: Key('nav-$i'),
                          style: TextButton.styleFrom(
                            minimumSize: const Size(48, 56),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 12,
                            ),
                            backgroundColor: i == selected
                                ? Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer
                                : null,
                          ),
                          onPressed: () => onSelected(i),
                          child: body,
                        ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
