import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/l10n.dart';
import '../models/transaction_entry.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/soft_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PeriodFilter _filter = PeriodFilter.month;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final l10n = context.l10n;
    final symbol = appState.currencySymbol();
    final balance = appState.balanceForPeriod(_filter);
    final income = appState.totalForPeriod(_filter, TransactionType.income);
    final expense = appState.totalForPeriod(_filter, TransactionType.expense);
    final categories = appState.categories.take(6).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderRow(onFilterTap: () {}, onSettingsTap: () {}),
              const SizedBox(height: 16),
              SegmentedButton<PeriodFilter>(
                segments: [
                  ButtonSegment(
                    value: PeriodFilter.week,
                    label: Text(l10n.overviewRangeWeek),
                  ),
                  ButtonSegment(
                    value: PeriodFilter.month,
                    label: Text(l10n.overviewRangeMonth),
                  ),
                ],
                selected: {_filter},
                onSelectionChanged: (selection) {
                  setState(() {
                    _filter = selection.first;
                  });
                },
              ),
              const SizedBox(height: 20),
              SoftCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _BalanceHeader(amount: _formatAmount(balance, symbol)),
                    const SizedBox(height: 16),
                    _SummaryItem(
                      title: l10n.overviewIncome,
                      amount: '+ ${_formatAmount(income, symbol)}',
                      color: AppColors.accentIncome,
                    ),
                    const SizedBox(height: 12),
                    _SummaryItem(
                      title: l10n.overviewExpenses,
                      amount: '- ${_formatAmount(expense, symbol)}',
                      color: AppColors.accentExpense,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.homeCategoriesTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: categories
                    .map(
                      (category) => _CategoryChip(
                        label: category.name,
                        icon: category.icon,
                        color: category.color,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAmount(double amount, String symbol) {
    final rounded = amount % 1 == 0
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    return symbol.isEmpty ? rounded : '$rounded $symbol';
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.onFilterTap, required this.onSettingsTap});

  final VoidCallback onFilterTap;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.appTitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat.yMMMM(localeTag).format(DateTime.now()),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(onPressed: onFilterTap, icon: const Icon(Icons.tune)),
            IconButton(
              onPressed: onSettingsTap,
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
      ],
    );
  }
}

class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader({required this.amount});

  final String amount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Text(
          l10n.homeBalanceTitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        Text(
          amount,
          style: Theme.of(
            context,
          ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.stroke, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.title,
    required this.amount,
    required this.color,
  });

  final String title;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyLarge),
        Text(
          amount,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
