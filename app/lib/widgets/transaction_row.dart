import 'package:flutter/material.dart';

import '../models/tag_entry.dart';
import '../models/transaction_entry.dart';
import '../theme/app_colors.dart';

class TransactionRow extends StatelessWidget {
  const TransactionRow({
    super.key,
    required this.entry,
    required this.symbol,
    this.showCategoryIcon = true,
    this.showPaymentIcon = true,
    this.showTags = true,
    this.authorName,
  });

  final TransactionEntry entry;
  final String symbol;
  final bool showCategoryIcon;
  final bool showPaymentIcon;
  final bool showTags;
  final String? authorName;

  @override
  Widget build(BuildContext context) {
    final isIncome = entry.type == TransactionType.income;
    final amount = entry.amount % 1 == 0
        ? entry.amount.toStringAsFixed(0)
        : entry.amount.toStringAsFixed(2);
    final note = (entry.note ?? '').trim();
    final description = note.isNotEmpty ? note : entry.categoryName;
    final author = (authorName ?? '').trim();
    final tags = entry.tags;
    final icons = <Widget>[];

    if (showCategoryIcon) {
      icons.add(
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(entry.categoryIcon, color: entry.categoryColor, size: 20),
        ),
      );
    }
    if (showPaymentIcon) {
      if (icons.isNotEmpty) {
        icons.add(const SizedBox(width: 8));
      }
      icons.add(
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
      );
    }

    return Row(
      children: [
        if (icons.isNotEmpty) ...[
          Row(children: icons),
          const SizedBox(width: 12),
        ],
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
              if (showTags && tags.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: tags.map((tag) => _TagChip(tag: tag)).toList(),
                ),
              ],
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _formatDateTime(entry.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (author.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Text(
                      '• $author',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
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

class _TagChip extends StatelessWidget {
  const _TagChip({required this.tag});

  final TagEntry tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.stroke, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.tag, color: tag.color, size: 14),
          const SizedBox(width: 4),
          Text(
            tag.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
