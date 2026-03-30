import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/payment_method.dart';
import '../models/transaction_entry.dart';
import '../state/app_state.dart';

class DataExport {
  static const int maxExportRows = 500;

  static Future<void> exportTransactionsCsv(
    BuildContext context,
    AppState appState,
  ) async {
    final transactions = [...appState.transactions]
      ..sort((left, right) => right.date.compareTo(left.date));
    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет операций для экспорта')),
      );
      return;
    }

    final monthOptions = _buildMonthOptions(transactions);
    final selectedMonth = await _pickExportMonth(context, monthOptions);
    if (selectedMonth == null || !context.mounted) {
      return;
    }

    if (selectedMonth.count > maxExportRows) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'В месяце ${selectedMonth.label} найдено ${selectedMonth.count} операций. '
            'Лимит экспорта: $maxExportRows строк.',
          ),
        ),
      );
      return;
    }

    final filteredTransactions = transactions
        .where(
          (entry) =>
              entry.date.year == selectedMonth.year &&
              entry.date.month == selectedMonth.month,
        )
        .toList(growable: false);
    if (filteredTransactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет операций за выбранный месяц')),
      );
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln(
      [
        'ID',
        'Дата',
        'Кто',
        'Метод',
        'Категория',
        'Описание',
        'Тип',
        'Сумма',
      ].map(_csvCell).join(';'),
    );

    for (var i = 0; i < filteredTransactions.length; i++) {
      final entry = filteredTransactions[i];
      final author = appState.memberName(entry.createdByUserId) ?? '';
      buffer.writeln(
        [
          '${i + 1}',
          _formatExportDate(entry.date),
          author,
          _methodLabel(entry.paymentMethod),
          entry.categoryName,
          entry.note ?? '',
          _typeLabel(entry.type),
          _formatExportAmount(entry.amount),
        ].map(_csvCell).join(';'),
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/budgetto-export-${selectedMonth.fileSegment}.csv',
    );
    await file.writeAsString(buffer.toString(), flush: true);

    if (!context.mounted) {
      return;
    }

    final isPhysicalDevice = await _isPhysicalDevice();
    if (!context.mounted) {
      return;
    }

    if (Platform.isIOS && !isPhysicalDevice) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Экспорт доступен на устройстве. Файл сохранен: ${file.path}',
          ),
        ),
      );
      return;
    }

    try {
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Экспорт операций Budgetto за ${selectedMonth.label}');
    } catch (error) {
      debugPrint('Export share failed: $error');
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Файл сохранен: ${file.path}')));
    }
  }

  static Future<bool> _isPhysicalDevice() async {
    if (!Platform.isIOS) {
      return true;
    }
    final info = await DeviceInfoPlugin().iosInfo;
    return info.isPhysicalDevice;
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  static String _formatExportDate(DateTime date) {
    return '${_twoDigits(date.day)}.${_twoDigits(date.month)}.${date.year} '
        '${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
  }

  static String _formatExportAmount(double amount) {
    final fixed = amount.toStringAsFixed(2);
    return fixed.replaceAll('.', ',');
  }

  static List<_ExportMonthOption> _buildMonthOptions(
    List<TransactionEntry> transactions,
  ) {
    final counts = <String, int>{};
    for (final entry in transactions) {
      final key = '${entry.date.year}-${_twoDigits(entry.date.month)}';
      counts[key] = (counts[key] ?? 0) + 1;
    }

    final options = counts.entries.map((entry) {
      final parts = entry.key.split('-');
      return _ExportMonthOption(
        year: int.parse(parts[0]),
        month: int.parse(parts[1]),
        count: entry.value,
      );
    }).toList();

    options.sort((left, right) {
      final leftValue = left.year * 100 + left.month;
      final rightValue = right.year * 100 + right.month;
      return rightValue.compareTo(leftValue);
    });
    return List.unmodifiable(options);
  }

  static Future<_ExportMonthOption?> _pickExportMonth(
    BuildContext context,
    List<_ExportMonthOption> options,
  ) {
    return showModalBottomSheet<_ExportMonthOption>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final hasLimitedMonths = options.any(
          (option) => option.count > maxExportRows,
        );
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Выбери месяц для экспорта',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Экспортирует только один месяц. Максимум $maxExportRows строк.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final option = options[index];
                      final isDisabled = option.count > maxExportRows;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        enabled: !isDisabled,
                        title: Text(option.label),
                        subtitle: Text(
                          isDisabled
                              ? '${option.count} операций, превышает лимит'
                              : '${option.count} операций',
                        ),
                        trailing: isDisabled
                            ? const Icon(Icons.lock_outline_rounded)
                            : const Icon(Icons.chevron_right_rounded),
                        onTap: isDisabled
                            ? null
                            : () => Navigator.of(context).pop(option),
                      );
                    },
                  ),
                ),
                if (hasLimitedMonths) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Месяцы с количеством операций больше $maxExportRows недоступны для экспорта.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  static String _csvCell(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  static String _methodLabel(PaymentMethod method) {
    return method.type == PaymentMethodType.cash ? 'Кеш' : 'Карта';
  }

  static String _typeLabel(TransactionType type) {
    return type == TransactionType.income ? 'Доход' : 'Расход';
  }
}

class _ExportMonthOption {
  const _ExportMonthOption({
    required this.year,
    required this.month,
    required this.count,
  });

  final int year;
  final int month;
  final int count;

  String get fileSegment => '$year-${DataExport._twoDigits(month)}';

  String get label => '${_monthName(month)} $year';

  static String _monthName(int month) {
    const monthNames = [
      'январь',
      'февраль',
      'март',
      'апрель',
      'май',
      'июнь',
      'июль',
      'август',
      'сентябрь',
      'октябрь',
      'ноябрь',
      'декабрь',
    ];
    return monthNames[month - 1];
  }
}
