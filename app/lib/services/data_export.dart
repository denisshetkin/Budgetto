import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/payment_method.dart';
import '../models/transaction_entry.dart';
import '../state/app_state.dart';

class DataExport {
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

    for (var i = 0; i < transactions.length; i++) {
      final entry = transactions[i];
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
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/budgetto-export-$timestamp.csv');
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
      ], text: 'Экспорт операций Budgetto');
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
