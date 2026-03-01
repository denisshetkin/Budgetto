import 'package:flutter/material.dart';

import '../models/transaction_entry.dart';
import '../theme/app_colors.dart';

class TransactionRow extends StatelessWidget {
  const TransactionRow({
    super.key,
    required this.entry,
    required this.symbol,
  });

  final TransactionEntry entry;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final isIncome = entry.type == TransactionType.income;
    final amount = entry.amount % 1 == 0
        ? entry.amount.toStringAsFixed(0)
        : entry.amount.toStringAsFixed(2);
    final note = (entry.note ?? '').trim();
    final description = note.isNotEmpty ? note : entry.categoryName;

    return Row(
      children: [
        Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(entry.categoryIcon, color: entry.categoryColor, size: 20),
            ),
            const SizedBox(width: 8),
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                entry.paymentMethod.icon,
                size: 20,
                color: entry.paymentMethod.color,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _formatDateTime(entry.date),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${isIncome ? '+' : '-'} $amount ${symbol.isEmpty ? '' : symbol}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: isIncome ? AppColors.accentIncome : AppColors.accentExpense,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day.$month $hour:$minute';
  }
}
