import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../l10n/l10n.dart';
import '../theme/app_colors.dart';

class CurrencyPickerSheet extends StatelessWidget {
  const CurrencyPickerSheet({
    super.key,
    required this.onSelected,
    this.selectedCode,
  });

  final String? selectedCode;
  final ValueChanged<String> onSelected;

  static const List<String> _currencies = [
    'USD',
    'EUR',
    'GBP',
    'UAH',
    'JPY',
    'RUB',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _currencies.map((code) {
            final name = _currencyName(code, l10n);
            final isSelected = code == selectedCode;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onSelected(code),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accentIncome
                          : AppColors.stroke,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name, style: Theme.of(context).textTheme.bodyMedium),
                      Text(
                        code,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  static String _currencyName(String code, AppLocalizations l10n) {
    switch (code) {
      case 'USD':
        return l10n.currencyNameUsd;
      case 'EUR':
        return l10n.currencyNameEur;
      case 'GBP':
        return l10n.currencyNameGbp;
      case 'UAH':
        return l10n.currencyNameUah;
      case 'JPY':
        return l10n.currencyNameJpy;
      case 'RUB':
        return l10n.currencyNameRub;
      default:
        return code;
    }
  }
}
