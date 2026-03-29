import 'package:flutter/material.dart';

import '../models/transaction_entry.dart';
import '../state/app_state.dart';

class TransactionImportService {
  static const int maxRows = 200;

  static const List<String> canonicalHeaders = [
    'date',
    'type',
    'amount',
    'category',
    'payment_method',
    'note',
  ];

  static TransactionImportPreview analyzeCsv({
    required String csvContent,
    required Iterable<String> existingCategoryNames,
    required Iterable<String> existingPaymentMethodNames,
    String? sourceName,
  }) {
    final sanitized = csvContent.replaceFirst(_utf8Bom, '');
    if (sanitized.trim().isEmpty) {
      return TransactionImportPreview(
        sourceName: sourceName,
        errors: const [
          TransactionImportIssue(
            message: 'Файл пустой. Добавь заголовки и строки данных.',
          ),
        ],
        rows: const [],
        newCategoryNames: const [],
      );
    }

    final delimiter = _detectDelimiter(sanitized);
    final parseResult = _parseCsv(sanitized, delimiter);
    if (parseResult.unclosedQuote) {
      return TransactionImportPreview(
        sourceName: sourceName,
        errors: const [
          TransactionImportIssue(
            message:
                'CSV содержит незакрытую кавычку. Проверь файл и попробуй снова.',
          ),
        ],
        rows: const [],
        newCategoryNames: const [],
      );
    }

    if (parseResult.rows.isEmpty) {
      return TransactionImportPreview(
        sourceName: sourceName,
        errors: const [
          TransactionImportIssue(message: 'Не удалось прочитать строки CSV.'),
        ],
        rows: const [],
        newCategoryNames: const [],
      );
    }

    final headerRow = parseResult.rows.first
        .map((cell) => cell.trim())
        .toList(growable: false);
    final headerMap = _buildHeaderMap(headerRow);
    final errors = <TransactionImportIssue>[];

    for (final header in ['date', 'type', 'amount', 'category']) {
      if (!headerMap.containsKey(header)) {
        errors.add(
          TransactionImportIssue(
            message:
                'Не найдена обязательная колонка "$header". Используй шаблон из инструкции.',
          ),
        );
      }
    }

    final dataRows = parseResult.rows.skip(1).toList(growable: false);
    if (dataRows.isEmpty) {
      errors.add(
        const TransactionImportIssue(
          message:
              'В файле нет строк с операциями. Добавь хотя бы одну запись.',
        ),
      );
    }

    if (dataRows.length > maxRows) {
      errors.add(
        TransactionImportIssue(
          message:
              'В файле ${dataRows.length} строк, а лимит импорта сейчас $maxRows.',
        ),
      );
    }

    final existingCategories = existingCategoryNames
        .map(_normalizeLookupKey)
        .toSet();
    final existingMethods = existingPaymentMethodNames
        .map(_normalizeLookupKey)
        .toSet();
    final preparedRows = <PreparedImportTransactionRow>[];
    final newCategoryNames = <String>[];
    final seenNewCategoryKeys = <String>{};

    for (var index = 0; index < dataRows.length; index++) {
      final csvRow = dataRows[index];
      final lineNumber = index + 2;
      if (_rowIsEmpty(csvRow)) {
        continue;
      }

      String valueFor(String canonicalHeader) {
        final headerIndex = headerMap[canonicalHeader];
        if (headerIndex == null || headerIndex >= csvRow.length) {
          return '';
        }
        return csvRow[headerIndex].trim();
      }

      final rawDate = valueFor('date');
      final rawType = valueFor('type');
      final rawAmount = valueFor('amount');
      final rawCategory = valueFor('category');
      final rawMethod = valueFor('payment_method');
      final rawNote = valueFor('note');

      final date = _tryParseDate(rawDate);
      if (date == null) {
        errors.add(
          TransactionImportIssue(
            lineNumber: lineNumber,
            message:
                'Не удалось распознать дату "$rawDate". Поддерживаются ISO и формат dd.MM.yyyy HH:mm.',
          ),
        );
      }

      final type = _tryParseType(rawType);
      if (type == null) {
        errors.add(
          TransactionImportIssue(
            lineNumber: lineNumber,
            message:
                'Поле type должно быть expense/income или Расход/Доход. Сейчас: "$rawType".',
          ),
        );
      }

      final amount = _tryParseAmount(rawAmount);
      if (amount == null || amount <= 0) {
        errors.add(
          TransactionImportIssue(
            lineNumber: lineNumber,
            message:
                'Поле amount должно быть числом больше 0. Сейчас: "$rawAmount".',
          ),
        );
      }

      if (rawCategory.isEmpty) {
        errors.add(
          TransactionImportIssue(
            lineNumber: lineNumber,
            message: 'Поле category не должно быть пустым.',
          ),
        );
      }

      String? paymentMethodName;
      if (rawMethod.isEmpty) {
        paymentMethodName = null;
      } else {
        final normalizedMethod = _normalizeLookupKey(rawMethod);
        if (!existingMethods.contains(normalizedMethod)) {
          errors.add(
            TransactionImportIssue(
              lineNumber: lineNumber,
              message:
                  'Не найден способ оплаты "$rawMethod". Сначала создай его в настройках или оставь поле пустым.',
            ),
          );
        } else {
          paymentMethodName = rawMethod;
        }
      }

      final normalizedCategory = _normalizeLookupKey(rawCategory);
      if (rawCategory.isNotEmpty &&
          !existingCategories.contains(normalizedCategory) &&
          seenNewCategoryKeys.add(normalizedCategory)) {
        newCategoryNames.add(rawCategory);
      }

      if (date == null ||
          type == null ||
          amount == null ||
          rawCategory.isEmpty) {
        continue;
      }

      preparedRows.add(
        PreparedImportTransactionRow(
          lineNumber: lineNumber,
          date: date,
          type: type,
          amount: amount,
          categoryName: rawCategory,
          paymentMethodName: paymentMethodName,
          note: rawNote.isEmpty ? null : rawNote,
        ),
      );
    }

    return TransactionImportPreview(
      sourceName: sourceName,
      errors: errors,
      rows: List.unmodifiable(preparedRows),
      newCategoryNames: List.unmodifiable(newCategoryNames),
    );
  }

  static TransactionImportCommitResult commitImport({
    required AppState appState,
    required TransactionImportPreview preview,
  }) {
    final importTagName = _buildImportTagName(DateTime.now());
    final importTag = appState.ensureTagByName(
      importTagName,
      icon: Icons.file_download_done_rounded,
      color: const Color(0xFF6CBAD9),
    );
    final createdCategoryNames = <String>[];

    for (final categoryName in preview.newCategoryNames) {
      final existing = appState.findCategoryByName(categoryName);
      if (existing == null) {
        appState.ensureCategoryByName(categoryName);
        createdCategoryNames.add(categoryName);
      }
    }

    var addedTransactions = 0;

    for (final row in preview.rows) {
      final category = appState.ensureCategoryByName(row.categoryName);
      final paymentMethod = row.paymentMethodName == null
          ? appState.defaultPaymentMethod
          : appState.findPaymentMethodByName(row.paymentMethodName!);

      if (paymentMethod == null) {
        continue;
      }

      final entry = TransactionEntry(
        id: 'import_${DateTime.now().microsecondsSinceEpoch}_$addedTransactions',
        type: row.type,
        amount: row.amount,
        categoryId: category.id,
        categoryName: category.name,
        categoryIcon: category.icon,
        categoryColor: category.color,
        date: row.date,
        paymentMethod: paymentMethod,
        tags: [importTag],
        note: row.note,
        createdByUserId: appState.currentUser.id,
      );

      appState.addTransaction(entry);
      addedTransactions += 1;
    }

    return TransactionImportCommitResult(
      addedTransactions: addedTransactions,
      createdCategoryNames: List.unmodifiable(createdCategoryNames),
      importTagName: importTag.name,
    );
  }

  static String buildInstructions() {
    return [
      'CSV в UTF-8 с заголовками в первой строке.',
      'Обязательные колонки: date, type, amount, category.',
      'Необязательные колонки: payment_method, note.',
      'Разделитель: ";" или ",".',
      'Дата: 2026-03-28, 2026-03-28 14:30, 28.03.2026 или 28.03.2026 14:30.',
      'Сумма: 12.50 или 12,50.',
      'Пустой payment_method = будет использован способ оплаты по умолчанию.',
      'Новые категории будут созданы автоматически.',
      'Каждая импортированная запись получит тег формата import_YYYYMMDD_HHMMSS.',
      'Лимит: не больше 200 строк данных за один импорт.',
    ].join('\n');
  }

  static String sampleCsv() {
    return [
      canonicalHeaders.join(';'),
      '2026-03-28 14:25;expense;12.50;Еда;Revolut;Обед',
      '2026-03-29;expense;48,90;Дом;;Хозяйственные товары',
    ].join('\n');
  }

  static String _buildImportTagName(DateTime timestamp) {
    return 'import_${timestamp.year}'
        '${_twoDigits(timestamp.month)}'
        '${_twoDigits(timestamp.day)}'
        '_${_twoDigits(timestamp.hour)}'
        '${_twoDigits(timestamp.minute)}'
        '${_twoDigits(timestamp.second)}';
  }

  static int _countDelimiter(String row, String delimiter) {
    var count = 0;
    var inQuotes = false;
    for (var index = 0; index < row.length; index++) {
      final char = row[index];
      if (char == '"') {
        final nextIsQuote = index + 1 < row.length && row[index + 1] == '"';
        if (inQuotes && nextIsQuote) {
          index += 1;
          continue;
        }
        inQuotes = !inQuotes;
        continue;
      }
      if (!inQuotes && char == delimiter) {
        count += 1;
      }
    }
    return count;
  }

  static String _detectDelimiter(String content) {
    final firstLine = content
        .split(RegExp(r'\r?\n'))
        .firstWhere((line) => line.trim().isNotEmpty, orElse: () => content);
    return _countDelimiter(firstLine, ';') >= _countDelimiter(firstLine, ',')
        ? ';'
        : ',';
  }

  static _CsvParseResult _parseCsv(String content, String delimiter) {
    final rows = <List<String>>[];
    var currentRow = <String>[];
    var currentField = StringBuffer();
    var inQuotes = false;

    void pushField() {
      currentRow.add(currentField.toString());
      currentField = StringBuffer();
    }

    void pushRow() {
      pushField();
      rows.add(currentRow);
      currentRow = <String>[];
    }

    for (var index = 0; index < content.length; index++) {
      final char = content[index];

      if (inQuotes) {
        if (char == '"') {
          final nextIsQuote =
              index + 1 < content.length && content[index + 1] == '"';
          if (nextIsQuote) {
            currentField.write('"');
            index += 1;
          } else {
            inQuotes = false;
          }
        } else {
          currentField.write(char);
        }
        continue;
      }

      if (char == '"') {
        inQuotes = true;
        continue;
      }

      if (char == delimiter) {
        pushField();
        continue;
      }

      if (char == '\n') {
        pushRow();
        continue;
      }

      if (char == '\r') {
        final nextIsLineFeed =
            index + 1 < content.length && content[index + 1] == '\n';
        if (nextIsLineFeed) {
          index += 1;
        }
        pushRow();
        continue;
      }

      currentField.write(char);
    }

    final hasPendingField =
        currentField.isNotEmpty ||
        currentRow.isNotEmpty ||
        content.endsWith(delimiter);
    if (hasPendingField) {
      pushRow();
    }

    final normalizedRows = rows
        .where(
          (row) =>
              row.length > 1 || (row.isNotEmpty && row.first.trim().isNotEmpty),
        )
        .toList(growable: false);

    return _CsvParseResult(rows: normalizedRows, unclosedQuote: inQuotes);
  }

  static Map<String, int> _buildHeaderMap(List<String> row) {
    final headerMap = <String, int>{};
    for (var index = 0; index < row.length; index++) {
      final normalized = _normalizeLookupKey(row[index]);
      final canonical = _headerAliases[normalized];
      if (canonical != null && !headerMap.containsKey(canonical)) {
        headerMap[canonical] = index;
      }
    }
    return headerMap;
  }

  static bool _rowIsEmpty(List<String> row) {
    return row.every((cell) => cell.trim().isEmpty);
  }

  static DateTime? _tryParseDate(String raw) {
    final value = raw.trim();
    if (value.isEmpty) {
      return null;
    }

    final isoCandidate = value.replaceFirst(' ', 'T');
    final isoParsed = DateTime.tryParse(isoCandidate);
    if (isoParsed != null) {
      return isoParsed;
    }

    final dotPattern = RegExp(
      r'^(\d{2})\.(\d{2})\.(\d{4})(?:\s+(\d{2}):(\d{2}))?$',
    );
    final dotMatch = dotPattern.firstMatch(value);
    if (dotMatch != null) {
      final day = int.parse(dotMatch.group(1)!);
      final month = int.parse(dotMatch.group(2)!);
      final year = int.parse(dotMatch.group(3)!);
      final hour = int.tryParse(dotMatch.group(4) ?? '0') ?? 0;
      final minute = int.tryParse(dotMatch.group(5) ?? '0') ?? 0;
      return DateTime(year, month, day, hour, minute);
    }

    final slashPattern = RegExp(
      r'^(\d{4})/(\d{2})/(\d{2})(?:\s+(\d{2}):(\d{2}))?$',
    );
    final slashMatch = slashPattern.firstMatch(value);
    if (slashMatch != null) {
      final year = int.parse(slashMatch.group(1)!);
      final month = int.parse(slashMatch.group(2)!);
      final day = int.parse(slashMatch.group(3)!);
      final hour = int.tryParse(slashMatch.group(4) ?? '0') ?? 0;
      final minute = int.tryParse(slashMatch.group(5) ?? '0') ?? 0;
      return DateTime(year, month, day, hour, minute);
    }

    return null;
  }

  static TransactionType? _tryParseType(String raw) {
    switch (_normalizeLookupKey(raw)) {
      case 'expense':
      case 'расход':
        return TransactionType.expense;
      case 'income':
      case 'доход':
        return TransactionType.income;
      default:
        return null;
    }
  }

  static double? _tryParseAmount(String raw) {
    final normalized = raw.replaceAll(' ', '').replaceAll(',', '.').trim();
    return double.tryParse(normalized);
  }

  static String _normalizeLookupKey(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  static const String _utf8Bom = '\ufeff';

  static const Map<String, String> _headerAliases = {
    'date': 'date',
    'дата': 'date',
    'type': 'type',
    'тип': 'type',
    'amount': 'amount',
    'сумма': 'amount',
    'category': 'category',
    'категория': 'category',
    'payment_method': 'payment_method',
    'payment method': 'payment_method',
    'метод': 'payment_method',
    'способ оплаты': 'payment_method',
    'note': 'note',
    'description': 'note',
    'описание': 'note',
    'комментарий': 'note',
  };
}

class TransactionImportPreview {
  const TransactionImportPreview({
    required this.errors,
    required this.rows,
    required this.newCategoryNames,
    this.sourceName,
  });

  final String? sourceName;
  final List<TransactionImportIssue> errors;
  final List<PreparedImportTransactionRow> rows;
  final List<String> newCategoryNames;

  bool get hasErrors => errors.isNotEmpty;
}

class PreparedImportTransactionRow {
  const PreparedImportTransactionRow({
    required this.lineNumber,
    required this.date,
    required this.type,
    required this.amount,
    required this.categoryName,
    this.paymentMethodName,
    this.note,
  });

  final int lineNumber;
  final DateTime date;
  final TransactionType type;
  final double amount;
  final String categoryName;
  final String? paymentMethodName;
  final String? note;
}

class TransactionImportIssue {
  const TransactionImportIssue({required this.message, this.lineNumber});

  final int? lineNumber;
  final String message;

  String get displayMessage {
    if (lineNumber == null) {
      return message;
    }
    return 'Строка $lineNumber: $message';
  }
}

class TransactionImportCommitResult {
  const TransactionImportCommitResult({
    required this.addedTransactions,
    required this.createdCategoryNames,
    required this.importTagName,
  });

  final int addedTransactions;
  final List<String> createdCategoryNames;
  final String importTagName;
}

class _CsvParseResult {
  const _CsvParseResult({required this.rows, required this.unclosedQuote});

  final List<List<String>> rows;
  final bool unclosedQuote;
}
