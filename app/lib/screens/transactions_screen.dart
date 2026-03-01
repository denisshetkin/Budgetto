import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/transaction_entry.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/slide_action_icon.dart';
import '../widgets/soft_card.dart';
import '../widgets/transaction_row.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  Future<void> _confirmDelete(BuildContext context, AppState appState, TransactionEntry entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удалить операцию?'),
          content: const Text('Уверен, что хочешь удалить эту операцию?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      if (!context.mounted) {
        return;
      }
      appState.removeTransaction(entry.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Операция удалена')),
      );
    }
  }

  void _openActionsSheet(BuildContext context, AppState appState, TransactionEntry entry) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SheetAction(
                  icon: Icons.edit,
                  label: 'Редактировать',
                  color: AppColors.accentIncome,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddTransactionScreen(
                          initialType: entry.type,
                          initialEntry: entry,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _SheetAction(
                  icon: Icons.delete,
                  label: 'Удалить',
                  color: AppColors.accentExpense,
                  onTap: () {
                    Navigator.of(context).pop();
                    _confirmDelete(context, appState, entry);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatAmount(double amount, String symbol) {
    final rounded = amount % 1 == 0 ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2);
    return symbol.isEmpty ? rounded : '$rounded $symbol';
  }

  String _monthLabel(DateTime date) {
    const months = [
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  List<TransactionEntry> _sorted(List<TransactionEntry> source) {
    final sorted = [...source];
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  double _sumForMonth(List<TransactionEntry> entries, DateTime month, TransactionType type) {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    return entries
        .where((entry) =>
            entry.type == type && !entry.date.isBefore(start) && entry.date.isBefore(end))
        .fold(0.0, (sum, entry) => sum + entry.amount);
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final symbol = appState.currencySymbol();
    final transactions = _sorted(appState.transactions);
    final now = DateTime.now();
    final displayMonth = transactions.isNotEmpty ? transactions.first.date : now;
    final income = _sumForMonth(transactions, displayMonth, TransactionType.income);
    final expense = _sumForMonth(transactions, displayMonth, TransactionType.expense);
    final balance = income - expense;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Операции',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Row(
                    children: [
                      _ActionCircle(
                        icon: Icons.remove,
                        color: AppColors.accentExpense,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AddTransactionScreen(
                                initialType: TransactionType.expense,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      _ActionCircle(
                        icon: Icons.add,
                        color: AppColors.accentIncome,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AddTransactionScreen(
                                initialType: TransactionType.income,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SoftCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _monthLabel(displayMonth),
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Divider(color: AppColors.stroke, height: 1),
                    const SizedBox(height: 10),
                    _SummaryItem(
                      title: 'Доходы',
                      amount: '+ ${_formatAmount(income, symbol)}',
                      color: AppColors.accentIncome,
                    ),
                    const SizedBox(height: 10),
                    _SummaryItem(
                      title: 'Расходы',
                      amount: '- ${_formatAmount(expense, symbol)}',
                      color: AppColors.accentExpense,
                    ),
                    const SizedBox(height: 10),
                    _SummaryItem(
                      title: 'Итого',
                      amount: _formatAmount(balance, symbol),
                      color: AppColors.accentTotal,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: transactions.isEmpty
                    ? Center(
                        child: Text(
                          'Пока нет операций',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      )
                    : SlidableAutoCloseBehavior(
                        child: ListView.separated(
                          itemCount: transactions.length,
                          separatorBuilder: (_, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final entry = transactions[index];
                            return Slidable(
                              key: ValueKey(entry.id),
                              endActionPane: ActionPane(
                                motion: const DrawerMotion(),
                                extentRatio: 0.26,
                                children: [
                                  CustomSlidableAction(
                                    onPressed: (_) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => AddTransactionScreen(
                                            initialType: entry.type,
                                            initialEntry: entry,
                                          ),
                                        ),
                                      );
                                    },
                                    backgroundColor: Colors.transparent,
                                    autoClose: false,
                                    child: const Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 0),
                                        child: SlideActionIcon(
                                          icon: Icons.edit,
                                          color: AppColors.accentIncome,
                                        ),
                                      ),
                                    ),
                                  ),
                                  CustomSlidableAction(
                                    onPressed: (_) => _confirmDelete(context, appState, entry),
                                    backgroundColor: Colors.transparent,
                                    autoClose: false,
                                    child: const Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: EdgeInsets.only(right: 0),
                                        child: SlideActionIcon(
                                          icon: Icons.delete,
                                          color: AppColors.accentExpense,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              child: GestureDetector(
                                onLongPress: () => _openActionsSheet(context, appState, entry),
                                child: SoftCard(
                                  child: TransactionRow(
                                    entry: entry,
                                    symbol: symbol,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
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
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
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

class _ActionCircle extends StatelessWidget {
  const _ActionCircle({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.stroke, width: 1),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.stroke, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
