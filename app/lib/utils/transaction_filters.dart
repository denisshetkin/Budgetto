import '../models/category_entry.dart';
import '../models/payment_method.dart';
import '../models/tag_entry.dart';
import '../models/transaction_entry.dart';

enum FilterMode { all, income, expense }

class TransactionFilter {
  const TransactionFilter({
    required this.mode,
    required this.selectedCategoryIds,
    required this.selectedMethodIds,
    required this.selectedTagIds,
    required this.query,
    required this.from,
    required this.to,
  });

  final FilterMode mode;
  final Set<String> selectedCategoryIds;
  final Set<String> selectedMethodIds;
  final Set<String> selectedTagIds;
  final String query;
  final DateTime? from;
  final DateTime? to;
}

bool shouldIncludeTransaction({
  required TransactionEntry entry,
  required TransactionFilter filter,
  required List<CategoryEntry> categories,
  required List<PaymentMethod> methods,
  required List<TagEntry> tags,
}) {
  if (filter.mode == FilterMode.income &&
      entry.type != TransactionType.income) {
    return false;
  }
  if (filter.mode == FilterMode.expense &&
      entry.type != TransactionType.expense) {
    return false;
  }

  final categoryFilterActive =
      categories.isNotEmpty &&
      filter.selectedCategoryIds.length != categories.length;
  final methodFilterActive =
      methods.isNotEmpty && filter.selectedMethodIds.length != methods.length;
  final tagFilterActive =
      tags.isNotEmpty && filter.selectedTagIds.length != tags.length;

  if (categoryFilterActive &&
      !filter.selectedCategoryIds.contains(entry.categoryId)) {
    return false;
  }
  if (methodFilterActive &&
      !filter.selectedMethodIds.contains(entry.paymentMethod.id)) {
    return false;
  }
  if (tagFilterActive) {
    final hasTag = entry.tags.any(
      (tag) => filter.selectedTagIds.contains(tag.id),
    );
    if (!hasTag) {
      return false;
    }
  }
  if (filter.from != null && entry.date.isBefore(filter.from!)) {
    return false;
  }
  if (filter.to != null && entry.date.isAfter(filter.to!)) {
    return false;
  }
  if (filter.query.isNotEmpty) {
    final note = (entry.note ?? '').toLowerCase();
    final category = entry.categoryName.toLowerCase();
    final hasTag = entry.tags.any(
      (tag) => tag.name.toLowerCase().contains(filter.query),
    );
    if (!note.contains(filter.query) &&
        !category.contains(filter.query) &&
        !hasTag) {
      return false;
    }
  }
  return true;
}
