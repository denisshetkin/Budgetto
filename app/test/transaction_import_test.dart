import 'package:flutter_test/flutter_test.dart';

import 'package:app/services/transaction_import.dart';

void main() {
  group('TransactionImportService.analyzeCsv', () {
    test('parses valid file and detects new categories', () {
      final preview = TransactionImportService.analyzeCsv(
        csvContent: [
          'дата;тип операции;операция;сумма;категория;способ оплаты;теги',
          '2026-03-28;Расход;Обед;12.50;Еда;Revolut;Обед,Дом',
          '2026-03-29;Расход;Такси;48.90;Дом;Наличные;',
          '2026-03-30;Доход;Фриланс проект;1000;Фриланс;Новый счет;Работа',
        ].join('\n'),
        existingCategoryNames: const ['Еда', 'Дом'],
        existingPaymentMethodNames: const ['Наличные', 'Revolut'],
        existingTagNames: const ['Дом'],
      );

      expect(preview.hasErrors, isFalse);
      expect(preview.rows, hasLength(3));
      expect(preview.newCategoryNames, ['Фриланс']);
      expect(preview.newPaymentMethodNames, ['Новый счет']);
      expect(preview.newTagNames, ['Обед', 'Работа']);
      expect(preview.rows[0].operationText, 'Обед');
      expect(preview.rows[0].tagNames, ['Обед', 'Дом']);
    });

    test(
      'returns validation errors for empty payment method and broken rows',
      () {
        final preview = TransactionImportService.analyzeCsv(
          csvContent: [
            'дата;тип операции;операция;сумма;категория;способ оплаты;теги',
            'bad date;Расход;;0;Еда;;Дом',
          ].join('\n'),
          existingCategoryNames: const ['Еда'],
          existingPaymentMethodNames: const ['Наличные', 'Revolut'],
          existingTagNames: const ['Дом'],
        );

        expect(preview.hasErrors, isTrue);
        expect(preview.errors, hasLength(4));
        expect(
          preview.errors.map((issue) => issue.displayMessage).join('\n'),
          contains('Не удалось распознать дату'),
        );
        expect(
          preview.errors.map((issue) => issue.displayMessage).join('\n'),
          contains('способ оплаты'),
        );
        expect(
          preview.errors.map((issue) => issue.displayMessage).join('\n'),
          contains('Поле "операция" не должно быть пустым.'),
        );
      },
    );

    test('accepts russian headers with one-digit hour and seconds', () {
      final preview = TransactionImportService.analyzeCsv(
        csvContent: [
          'Дата;Тип операции;Операция;Сумма;Категория;Способ оплаты;Теги',
          '09.02.2026 8:27:18;Расход;Билеты в театр;12,50;Еда;Revolut;Обед',
        ].join('\n'),
        existingCategoryNames: const ['Еда'],
        existingPaymentMethodNames: const ['Revolut'],
        existingTagNames: const [],
      );

      expect(preview.hasErrors, isFalse);
      expect(preview.rows, hasLength(1));
      expect(preview.rows.first.amount, 12.5);
      expect(preview.rows.first.date, DateTime(2026, 2, 9, 8, 27));
      expect(preview.rows.first.operationText, 'Билеты в театр');
      expect(preview.newTagNames, ['Обед']);
    });
  });
}
