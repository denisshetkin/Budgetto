import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/l10n.dart';
import '../models/transaction_entry.dart';
import '../state/app_state.dart';

class DataExport {
  static const int maxExportRows = 500;
  static const String _csvHeaderId = 'id';
  static const String _csvHeaderDate = 'date';
  static const String _csvHeaderType = 'transaction_type';
  static const String _csvHeaderOperation = 'operation';
  static const String _csvHeaderAmount = 'amount';
  static const String _csvHeaderCategory = 'category';
  static const String _csvHeaderPaymentMethod = 'payment_method';
  static const String _csvHeaderTags = 'tags';
  static const String _csvHeaderAuthor = 'author';
  static const String _csvTypeExpense = 'expense';
  static const String _csvTypeIncome = 'income';

  static Future<void> exportTransactionsCsv(
    BuildContext context,
    AppState appState,
  ) async {
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final l10n = context.l10n;
    final transactions = [...appState.transactions]
      ..sort((left, right) => right.date.compareTo(left.date));
    if (transactions.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.dataExportNoTransactions)));
      return;
    }

    final monthOptions = _buildMonthOptions(transactions, localeTag);
    final selectedMonth = await _pickExportMonth(context, monthOptions);
    if (selectedMonth == null || !context.mounted) {
      return;
    }

    if (selectedMonth.count > maxExportRows) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.dataExportMonthLimitMessage(
              selectedMonth.label,
              selectedMonth.count,
              maxExportRows,
            ),
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
        SnackBar(content: Text(l10n.dataExportNoTransactionsForMonth)),
      );
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln(
      [
        _csvHeaderId,
        _csvHeaderDate,
        _csvHeaderType,
        _csvHeaderOperation,
        _csvHeaderAmount,
        _csvHeaderCategory,
        _csvHeaderPaymentMethod,
        _csvHeaderTags,
        _csvHeaderAuthor,
      ].map(_csvCell).join(';'),
    );

    for (final entry in filteredTransactions) {
      final author = appState.memberName(entry.createdByUserId) ?? '';
      final operation = (entry.note ?? '').trim().isNotEmpty
          ? entry.note!.trim()
          : entry.categoryName;
      final tags = entry.tags.map((tag) => tag.name).join(',');
      buffer.writeln(
        [
          entry.id,
          _formatExportDate(entry.date),
          _typeLabel(entry.type),
          operation,
          _formatExportAmount(entry.amount),
          entry.categoryName,
          entry.paymentMethod.name,
          tags,
          author,
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
        SnackBar(content: Text(l10n.dataExportSavedOnDevice(file.path))),
      );
      return;
    }

    try {
      await Share.shareXFiles([
        XFile(file.path),
      ], text: l10n.dataExportShareText(selectedMonth.label));
    } catch (error) {
      debugPrint('Export share failed: $error');
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.dataExportFileSaved(file.path))),
      );
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
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  static String _formatExportAmount(double amount) {
    return amount.toStringAsFixed(2);
  }

  static List<_ExportMonthOption> _buildMonthOptions(
    List<TransactionEntry> transactions,
    String localeTag,
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
        localeTag: localeTag,
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
        final exportableOptions = options
            .where((option) => option.count <= maxExportRows)
            .toList(growable: false);
        _ExportMonthOption? selectedOption = exportableOptions.isNotEmpty
            ? exportableOptions.first
            : null;
        return SafeArea(
          child: StatefulBuilder(
            builder: (context, setState) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.dataExportPickMonthTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.dataExportPickMonthDescription(maxExportRows),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<_ExportMonthOption>(
                    initialValue: selectedOption,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: context.l10n.dataExportSelectMonthLabel,
                    ),
                    items: exportableOptions
                        .map(
                          (option) => DropdownMenuItem<_ExportMonthOption>(
                            value: option,
                            child: Text(option.label),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: exportableOptions.isEmpty
                        ? null
                        : (value) => setState(() => selectedOption = value),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    selectedOption == null
                        ? context.l10n.dataExportNoAvailableMonths
                        : context.l10n.dataExportMonthCount(
                            selectedOption!.count,
                          ),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                  if (hasLimitedMonths) ...[
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.dataExportMonthsLimited(maxExportRows),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: selectedOption == null
                          ? null
                          : () => Navigator.of(context).pop(selectedOption),
                      icon: const Icon(Icons.file_download_outlined),
                      label: Text(context.l10n.dataExportExportAction),
                    ),
                  ),
                ],
              ),
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

  static String _typeLabel(TransactionType type) {
    return type == TransactionType.income ? _csvTypeIncome : _csvTypeExpense;
  }
}

class _ExportMonthOption {
  const _ExportMonthOption({
    required this.year,
    required this.month,
    required this.count,
    required this.localeTag,
  });

  final int year;
  final int month;
  final int count;
  final String localeTag;

  String get fileSegment => '$year-${DataExport._twoDigits(month)}';

  String get label =>
      DateFormat('LLLL y', localeTag).format(DateTime(year, month));
}
