import 'package:flutter_test/flutter_test.dart';

import 'package:app/services/transaction_import.dart';

void main() {
  group('TransactionImportService.analyzeCsv', () {
    test('parses valid file and detects new categories', () {
      final preview = TransactionImportService.analyzeCsv(
        csvContent: [
          'date;type;amount;category;payment_method;note',
          '2026-03-28 14:25;expense;12.50;Еда;Revolut;Обед',
          '29.03.2026 09:10;expense;48,90;Дом;;Товары',
          '2026-03-30;income;1000;Фриланс;Revolut;Оплата',
        ].join('\n'),
        existingCategoryNames: const ['Еда', 'Дом'],
        existingPaymentMethodNames: const ['Наличные', 'Revolut'],
      );

      expect(preview.hasErrors, isFalse);
      expect(preview.rows, hasLength(3));
      expect(preview.newCategoryNames, ['Фриланс']);
      expect(preview.rows[1].paymentMethodName, isNull);
    });

    test('returns validation errors for unknown methods and broken rows', () {
      final preview = TransactionImportService.analyzeCsv(
        csvContent: [
          'date;type;amount;category;payment_method',
          'bad date;expense;0;Еда;Unknown card',
        ].join('\n'),
        existingCategoryNames: const ['Еда'],
        existingPaymentMethodNames: const ['Наличные', 'Revolut'],
      );

      expect(preview.hasErrors, isTrue);
      expect(preview.errors, hasLength(3));
      expect(
        preview.errors.map((issue) => issue.displayMessage).join('\n'),
        contains('Не удалось распознать дату'),
      );
      expect(
        preview.errors.map((issue) => issue.displayMessage).join('\n'),
        contains('Unknown card'),
      );
    });

    test('accepts russian headers from export style files', () {
      final preview = TransactionImportService.analyzeCsv(
        csvContent: [
          'Дата;Метод;Категория;Описание;Тип;Сумма',
          '28.03.2026 14:25;Revolut;Еда;Обед;Расход;12,50',
        ].join('\n'),
        existingCategoryNames: const ['Еда'],
        existingPaymentMethodNames: const ['Revolut'],
      );

      expect(preview.hasErrors, isFalse);
      expect(preview.rows, hasLength(1));
      expect(preview.rows.first.amount, 12.5);
    });
  });
}
