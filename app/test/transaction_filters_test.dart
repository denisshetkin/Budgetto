import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/models/category_entry.dart';
import 'package:app/models/payment_method.dart';
import 'package:app/models/tag_entry.dart';
import 'package:app/models/transaction_entry.dart';
import 'package:app/utils/transaction_filters.dart';

TransactionEntry _entry({
  required String id,
  required String categoryId,
  required PaymentMethod method,
  List<TagEntry> tags = const [],
}) {
  return TransactionEntry(
    id: id,
    type: TransactionType.expense,
    amount: 10,
    categoryId: categoryId,
    categoryName: 'Food',
    categoryIcon: Icons.fastfood,
    categoryColor: Colors.orange,
    date: DateTime(2026, 3, 8, 10),
    paymentMethod: method,
    tags: tags,
  );
}

void main() {
  test('Does not filter out untagged entries when all tags selected', () {
    final method = PaymentMethod(
      id: 'cash',
      name: 'Cash',
      type: PaymentMethodType.cash,
      icon: Icons.money,
      color: Colors.green,
    );
    final tagA = TagEntry(
      id: 't1',
      name: 'Home',
      icon: Icons.tag,
      color: Colors.blue,
    );
    final tagB = TagEntry(
      id: 't2',
      name: 'Work',
      icon: Icons.tag,
      color: Colors.red,
    );
    final entry = _entry(id: 'e1', categoryId: 'c1', method: method);
    final filter = TransactionFilter(
      mode: FilterMode.all,
      selectedCategoryIds: {'c1'},
      selectedMethodIds: {method.id},
      selectedTagIds: {tagA.id, tagB.id},
      query: '',
      from: null,
      to: null,
    );

    final included = shouldIncludeTransaction(
      entry: entry,
      filter: filter,
      categories: [
        CategoryEntry(
          id: 'c1',
          name: 'Food',
          icon: Icons.fastfood,
          color: Colors.orange,
        ),
      ],
      methods: [method],
      tags: [tagA, tagB],
    );

    expect(included, isTrue);
  });

  test('Filters by selected tags when subset is chosen', () {
    final method = PaymentMethod(
      id: 'card',
      name: 'Card',
      type: PaymentMethodType.card,
      icon: Icons.credit_card,
      color: Colors.blueGrey,
    );
    final tagA = TagEntry(
      id: 't1',
      name: 'Home',
      icon: Icons.tag,
      color: Colors.blue,
    );
    final tagB = TagEntry(
      id: 't2',
      name: 'Work',
      icon: Icons.tag,
      color: Colors.red,
    );
    final entryWithA = _entry(
      id: 'e1',
      categoryId: 'c1',
      method: method,
      tags: [tagA],
    );
    final entryWithB = _entry(
      id: 'e2',
      categoryId: 'c1',
      method: method,
      tags: [tagB],
    );
    final entryNoTags = _entry(id: 'e3', categoryId: 'c1', method: method);

    final filter = TransactionFilter(
      mode: FilterMode.all,
      selectedCategoryIds: {'c1'},
      selectedMethodIds: {method.id},
      selectedTagIds: {tagA.id},
      query: '',
      from: null,
      to: null,
    );

    expect(
      shouldIncludeTransaction(
        entry: entryWithA,
        filter: filter,
        categories: [
          CategoryEntry(
            id: 'c1',
            name: 'Food',
            icon: Icons.fastfood,
            color: Colors.orange,
          ),
        ],
        methods: [method],
        tags: [tagA, tagB],
      ),
      isTrue,
    );
    expect(
      shouldIncludeTransaction(
        entry: entryWithB,
        filter: filter,
        categories: [
          CategoryEntry(
            id: 'c1',
            name: 'Food',
            icon: Icons.fastfood,
            color: Colors.orange,
          ),
        ],
        methods: [method],
        tags: [tagA, tagB],
      ),
      isFalse,
    );
    expect(
      shouldIncludeTransaction(
        entry: entryNoTags,
        filter: filter,
        categories: [
          CategoryEntry(
            id: 'c1',
            name: 'Food',
            icon: Icons.fastfood,
            color: Colors.orange,
          ),
        ],
        methods: [method],
        tags: [tagA, tagB],
      ),
      isFalse,
    );
  });

  test(
    'Does not exclude entries with unknown category when filter is not active',
    () {
      final method = PaymentMethod(
        id: 'cash',
        name: 'Cash',
        type: PaymentMethodType.cash,
        icon: Icons.money,
        color: Colors.green,
      );
      final entry = _entry(id: 'e1', categoryId: 'legacy_cat', method: method);
      final filter = TransactionFilter(
        mode: FilterMode.all,
        selectedCategoryIds: {'c1'},
        selectedMethodIds: {method.id},
        selectedTagIds: {},
        query: '',
        from: null,
        to: null,
      );

      final included = shouldIncludeTransaction(
        entry: entry,
        filter: filter,
        categories: [
          CategoryEntry(
            id: 'c1',
            name: 'Food',
            icon: Icons.fastfood,
            color: Colors.orange,
          ),
        ],
        methods: [method],
        tags: const [],
      );

      expect(included, isTrue);
    },
  );
}
