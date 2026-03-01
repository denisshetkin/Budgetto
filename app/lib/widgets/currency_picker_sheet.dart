import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CurrencyPickerSheet extends StatelessWidget {
  const CurrencyPickerSheet({
    super.key,
    required this.onSelected,
    this.selectedCode,
  });

  final String? selectedCode;
  final ValueChanged<String> onSelected;

  static const List<Map<String, String>> _currencies = [
    {'code': 'USD', 'name': 'Доллар США'},
    {'code': 'EUR', 'name': 'Евро'},
    {'code': 'GBP', 'name': 'Фунт стерлингов'},
    {'code': 'UAH', 'name': 'Гривна'},
    {'code': 'JPY', 'name': 'Йена'},
    {'code': 'RUB', 'name': 'Рубль'},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _currencies.map((currency) {
            final code = currency['code']!;
            final name = currency['name']!;
            final isSelected = code == selectedCode;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onSelected(code),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.accentIncome : AppColors.stroke,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
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
}
