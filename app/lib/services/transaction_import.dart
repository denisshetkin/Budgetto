import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/transaction_entry.dart';
import '../state/app_state.dart';

class TransactionImportService {
  static const int maxRows = 500;
  static const String csvTypeExpense = 'expense';
  static const String csvTypeIncome = 'income';

  static const List<String> requiredHeaders = [
    'date',
    'transaction_type',
    'operation',
    'amount',
    'category',
    'payment_method',
    'tags',
  ];

  static TransactionImportPreview analyzeCsv({
    required AppLocalizations l10n,
    required String csvContent,
    required Iterable<String> existingCategoryNames,
    required Iterable<String> existingPaymentMethodNames,
    required Iterable<String> existingTagNames,
    String? sourceName,
  }) {
    final sanitized = csvContent.replaceFirst(_utf8Bom, '');
    if (sanitized.trim().isEmpty) {
      return TransactionImportPreview(
        sourceName: sourceName,
        errors: [
          TransactionImportIssue(message: l10n.transactionImportErrorEmptyFile),
        ],
        rows: const [],
        newCategoryNames: const [],
        newPaymentMethodNames: const [],
        newTagNames: const [],
      );
    }

    final delimiter = _detectDelimiter(sanitized);
    final parseResult = _parseCsv(sanitized, delimiter);
    if (parseResult.unclosedQuote) {
      return TransactionImportPreview(
        sourceName: sourceName,
        errors: [
          TransactionImportIssue(
            message: l10n.transactionImportErrorUnclosedQuote,
          ),
        ],
        rows: const [],
        newCategoryNames: const [],
        newPaymentMethodNames: const [],
        newTagNames: const [],
      );
    }

    if (parseResult.rows.isEmpty) {
      return TransactionImportPreview(
        sourceName: sourceName,
        errors: [
          TransactionImportIssue(message: l10n.transactionImportErrorReadRows),
        ],
        rows: const [],
        newCategoryNames: const [],
        newPaymentMethodNames: const [],
        newTagNames: const [],
      );
    }

    final headerRow = parseResult.rows.first
        .map((cell) => cell.trim())
        .toList(growable: false);
    final headerMap = _buildHeaderMap(headerRow);
    final errors = <TransactionImportIssue>[];

    for (final header in requiredHeaders) {
      if (!headerMap.containsKey(header)) {
        errors.add(
          TransactionImportIssue(
            message: l10n.transactionImportMissingRequiredColumn(
              _headerLabel(header),
            ),
          ),
        );
      }
    }

    final dataRows = parseResult.rows.skip(1).toList(growable: false);
    if (dataRows.isEmpty) {
      errors.add(
        TransactionImportIssue(message: l10n.transactionImportErrorNoDataRows),
      );
    }

    if (dataRows.length > maxRows) {
      errors.add(
        TransactionImportIssue(
          message: l10n.transactionImportErrorRowLimit(
            dataRows.length,
            maxRows,
          ),
        ),
      );
    }

    final existingCategories = existingCategoryNames
        .map(_normalizeLookupKey)
        .toSet();
    final existingMethods = existingPaymentMethodNames
        .map(_normalizeLookupKey)
        .toSet();
    final existingTags = existingTagNames.map(_normalizeLookupKey).toSet();
    final preparedRows = <PreparedImportTransactionRow>[];
    final newCategoryNames = <String>[];
    final newPaymentMethodNames = <String>[];
    final newTagNames = <String>[];
    final seenNewCategoryKeys = <String>{};
    final seenNewMethodKeys = <String>{};
    final seenNewTagKeys = <String>{};

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
      final rawType = valueFor('transaction_type');
      final rawOperation = valueFor('operation');
      final rawAmount = valueFor('amount');
      final rawCategory = valueFor('category');
      final rawMethod = valueFor('payment_method');
      final rawTags = valueFor('tags');

      final date = _tryParseDate(rawDate);
      if (date == null) {
        errors.add(
          TransactionImportIssue(
            lineNumber: lineNumber,
            message: l10n.transactionImportErrorInvalidDate(rawDate),
          ),
        );
      }

      final type = _tryParseType(rawType);
      if (type == null) {
        errors.add(
          TransactionImportIssue(
            lineNumber: lineNumber,
            message: l10n.transactionImportErrorInvalidType(
              csvTypeExpense,
              csvTypeIncome,
            ),
          ),
        );
      }

      if (rawOperation.isEmpty) {
        errors.add(
          TransactionImportIssue(
            lineNumber: lineNumber,
            message: l10n.transactionImportErrorOperationRequired,
          ),
        );
      }

      final amount = _tryParseAmount(rawAmount);
      if (amount == null || amount <= 0) {
        errors.add(
          TransactionImportIssue(
            lineNumber: lineNumber,
            message: l10n.transactionImportErrorInvalidAmount(rawAmount),
          ),
        );
      }

      if (rawCategory.isEmpty) {
        errors.add(
          TransactionImportIssue(
            lineNumber: lineNumber,
            message: l10n.transactionImportErrorCategoryRequired,
          ),
        );
      }

      if (rawMethod.isEmpty) {
        errors.add(
          TransactionImportIssue(
            lineNumber: lineNumber,
            message: l10n.transactionImportErrorPaymentMethodRequired,
          ),
        );
      } else {
        final normalizedMethod = _normalizeLookupKey(rawMethod);
        if (!existingMethods.contains(normalizedMethod) &&
            seenNewMethodKeys.add(normalizedMethod)) {
          newPaymentMethodNames.add(rawMethod);
        }
      }

      final tagNames = _parseTagNames(rawTags);
      for (final tagName in tagNames) {
        final normalizedTag = _normalizeLookupKey(tagName);
        if (!existingTags.contains(normalizedTag) &&
            seenNewTagKeys.add(normalizedTag)) {
          newTagNames.add(tagName);
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
          rawOperation.isEmpty ||
          amount == null ||
          rawCategory.isEmpty ||
          rawMethod.isEmpty) {
        continue;
      }

      preparedRows.add(
        PreparedImportTransactionRow(
          lineNumber: lineNumber,
          date: date,
          type: type,
          amount: amount,
          categoryName: rawCategory,
          operationText: rawOperation,
          paymentMethodName: rawMethod,
          tagNames: tagNames,
        ),
      );
    }

    return TransactionImportPreview(
      sourceName: sourceName,
      errors: errors,
      rows: List.unmodifiable(preparedRows),
      newCategoryNames: List.unmodifiable(newCategoryNames),
      newPaymentMethodNames: List.unmodifiable(newPaymentMethodNames),
      newTagNames: List.unmodifiable(newTagNames),
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
    final createdPaymentMethodNames = <String>[];
    final createdTagNames = <String>[];

    for (final categoryName in preview.newCategoryNames) {
      final existing = appState.findCategoryByName(categoryName);
      if (existing == null) {
        appState.ensureCategoryByName(categoryName);
        createdCategoryNames.add(categoryName);
      }
    }

    for (final paymentMethodName in preview.newPaymentMethodNames) {
      final existing = appState.findPaymentMethodByName(paymentMethodName);
      if (existing == null) {
        appState.ensurePaymentMethodByName(paymentMethodName);
        createdPaymentMethodNames.add(paymentMethodName);
      }
    }

    for (final tagName in preview.newTagNames) {
      final existing = appState.findTagByName(tagName);
      if (existing == null) {
        appState.ensureTagByName(
          tagName,
          icon: Icons.sell_rounded,
          color: const Color(0xFFF4A261),
        );
        createdTagNames.add(tagName);
      }
    }

    var addedTransactions = 0;

    for (final row in preview.rows) {
      final category = appState.ensureCategoryByName(row.categoryName);
      final paymentMethod = appState.ensurePaymentMethodByName(
        row.paymentMethodName,
      );
      final transactionTags = row.tagNames
          .map(
            (tagName) => appState.ensureTagByName(
              tagName,
              icon: Icons.sell_rounded,
              color: const Color(0xFFF4A261),
            ),
          )
          .toList();
      if (transactionTags.every((tag) => tag.id != importTag.id)) {
        transactionTags.add(importTag);
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
        tags: transactionTags,
        note: row.operationText,
        createdByUserId: appState.currentUser.id,
      );

      appState.addTransaction(entry);
      addedTransactions += 1;
    }

    return TransactionImportCommitResult(
      addedTransactions: addedTransactions,
      createdCategoryNames: List.unmodifiable(createdCategoryNames),
      createdPaymentMethodNames: List.unmodifiable(createdPaymentMethodNames),
      createdTagNames: List.unmodifiable(createdTagNames),
      importTagName: importTag.name,
    );
  }

  static List<TransactionImportInstructionSection> buildInstructionSections(
    AppLocalizations l10n,
  ) {
    final headers = _documentHeaders().join(';');
    return [
      TransactionImportInstructionSection(
        title: l10n.transactionImportInstructionPrepareTitle,
        items: [
          l10n.transactionImportInstructionFormat,
          l10n.transactionImportInstructionEncoding,
          l10n.transactionImportInstructionHeaderRow(headers),
          l10n.transactionImportInstructionDelimiter,
          l10n.transactionImportInstructionMaxRows(maxRows),
        ],
      ),
      TransactionImportInstructionSection(
        title: l10n.transactionImportInstructionColumnsTitle,
        items: [
          l10n.transactionImportInstructionDateColumn(_headerLabel('date')),
          l10n.transactionImportInstructionTypeColumn(
            _headerLabel('transaction_type'),
            csvTypeExpense,
            csvTypeIncome,
          ),
          l10n.transactionImportInstructionOperationColumn(
            _headerLabel('operation'),
            l10n.transactionImportSampleOperationOne,
          ),
          l10n.transactionImportInstructionAmountColumn(_headerLabel('amount')),
          l10n.transactionImportInstructionCategoryColumn(
            _headerLabel('category'),
          ),
          l10n.transactionImportInstructionPaymentMethodColumn(
            _headerLabel('payment_method'),
          ),
          l10n.transactionImportInstructionTagsColumn(_headerLabel('tags')),
        ],
      ),
      TransactionImportInstructionSection(
        title: l10n.transactionImportInstructionReviewTitle,
        items: [
          l10n.transactionImportInstructionReviewItemOne,
          l10n.transactionImportInstructionReviewItemTwo,
          l10n.transactionImportInstructionReviewItemThree,
        ],
      ),
    ];
  }

  static String sampleCsv(AppLocalizations l10n) {
    return [
      _documentHeaders().join(';'),
      '2026-03-28 14:25;$csvTypeExpense;${l10n.transactionImportSampleOperationOne};12.50;${l10n.transactionImportSampleCategoryOne};${l10n.transactionImportSamplePaymentMethodOne};${l10n.transactionImportSampleTagsOne}',
      '2026-02-05 00:53;$csvTypeExpense;${l10n.transactionImportSampleOperationTwo};48.90;${l10n.transactionImportSampleCategoryTwo};${l10n.transactionImportSamplePaymentMethodTwo};',
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
      r'^(\d{2})\.(\d{2})\.(\d{4})(?:\s+(\d{1,2}):(\d{2})(?::(\d{2}))?)?$',
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
      r'^(\d{4})/(\d{2})/(\d{2})(?:\s+(\d{1,2}):(\d{2})(?::(\d{2}))?)?$',
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
      case 'gasto':
      case 'gastos':
        return TransactionType.expense;
      case 'income':
      case 'доход':
      case 'ingreso':
      case 'ingresos':
        return TransactionType.income;
      default:
        return null;
    }
  }

  static double? _tryParseAmount(String raw) {
    final normalized = raw.replaceAll(' ', '').replaceAll(',', '.').trim();
    return double.tryParse(normalized);
  }

  static List<String> _parseTagNames(String raw) {
    if (raw.trim().isEmpty) {
      return const [];
    }

    final seenKeys = <String>{};
    final tagNames = <String>[];
    for (final part in raw.split(',')) {
      final tagName = part.trim();
      if (tagName.isEmpty) {
        continue;
      }
      final normalized = _normalizeLookupKey(tagName);
      if (seenKeys.add(normalized)) {
        tagNames.add(tagName);
      }
    }
    return List.unmodifiable(tagNames);
  }

  static String _normalizeLookupKey(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  static List<String> _documentHeaders() => [
    _headerLabel('date'),
    _headerLabel('transaction_type'),
    _headerLabel('operation'),
    _headerLabel('amount'),
    _headerLabel('category'),
    _headerLabel('payment_method'),
    _headerLabel('tags'),
  ];

  static String _headerLabel(String header) {
    switch (header) {
      case 'date':
        return 'date';
      case 'transaction_type':
        return 'transaction_type';
      case 'operation':
        return 'operation';
      case 'amount':
        return 'amount';
      case 'category':
        return 'category';
      case 'payment_method':
        return 'payment_method';
      case 'tags':
        return 'tags';
      default:
        return header;
    }
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  static const String _utf8Bom = '\ufeff';

  static const Map<String, String> _headerAliases = {
    'date': 'date',
    'дата': 'date',
    'fecha': 'date',
    'transaction_type': 'transaction_type',
    'transaction type': 'transaction_type',
    'type': 'transaction_type',
    'тип': 'transaction_type',
    'тип операции': 'transaction_type',
    'tipo de transaccion': 'transaction_type',
    'tipo de transacción': 'transaction_type',
    'operation': 'operation',
    'операция': 'operation',
    'description': 'operation',
    'описание': 'operation',
    'комментарий': 'operation',
    'operacion': 'operation',
    'operación': 'operation',
    'amount': 'amount',
    'сумма': 'amount',
    'importe': 'amount',
    'category': 'category',
    'категория': 'category',
    'categoria': 'category',
    'categoría': 'category',
    'payment_method': 'payment_method',
    'payment method': 'payment_method',
    'payment': 'payment_method',
    'метод': 'payment_method',
    'оплата': 'payment_method',
    'тип платежа': 'payment_method',
    'способ оплаты': 'payment_method',
    'metodo de pago': 'payment_method',
    'método de pago': 'payment_method',
    'tags': 'tags',
    'tag': 'tags',
    'тег': 'tags',
    'теги': 'tags',
    'etiquetas': 'tags',
    'etiqueta': 'tags',
  };
}

class TransactionImportPreview {
  const TransactionImportPreview({
    required this.errors,
    required this.rows,
    required this.newCategoryNames,
    required this.newPaymentMethodNames,
    required this.newTagNames,
    this.sourceName,
  });

  final String? sourceName;
  final List<TransactionImportIssue> errors;
  final List<PreparedImportTransactionRow> rows;
  final List<String> newCategoryNames;
  final List<String> newPaymentMethodNames;
  final List<String> newTagNames;

  bool get hasErrors => errors.isNotEmpty;
}

class PreparedImportTransactionRow {
  const PreparedImportTransactionRow({
    required this.lineNumber,
    required this.date,
    required this.type,
    required this.amount,
    required this.categoryName,
    required this.operationText,
    required this.paymentMethodName,
    required this.tagNames,
  });

  final int lineNumber;
  final DateTime date;
  final TransactionType type;
  final double amount;
  final String categoryName;
  final String operationText;
  final String paymentMethodName;
  final List<String> tagNames;
}

class TransactionImportIssue {
  const TransactionImportIssue({required this.message, this.lineNumber});

  final int? lineNumber;
  final String message;

  String displayMessage(AppLocalizations l10n) {
    if (lineNumber == null) {
      return message;
    }
    return l10n.transactionImportLineMessage(lineNumber!, message);
  }
}

class TransactionImportCommitResult {
  const TransactionImportCommitResult({
    required this.addedTransactions,
    required this.createdCategoryNames,
    required this.createdPaymentMethodNames,
    required this.createdTagNames,
    required this.importTagName,
  });

  final int addedTransactions;
  final List<String> createdCategoryNames;
  final List<String> createdPaymentMethodNames;
  final List<String> createdTagNames;
  final String importTagName;
}

class TransactionImportInstructionSection {
  const TransactionImportInstructionSection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<String> items;
}

class _CsvParseResult {
  const _CsvParseResult({required this.rows, required this.unclosedQuote});

  final List<List<String>> rows;
  final bool unclosedQuote;
}
