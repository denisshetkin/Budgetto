import 'package:flutter/material.dart';

import 'payment_method.dart';
import 'tag_entry.dart';

class PlannedEntry {
  const PlannedEntry({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.paymentMethod,
    required this.createdAt,
    this.tags = const [],
    this.note,
  });

  final String id;
  final double amount;
  final String categoryId;
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;
  final PaymentMethod paymentMethod;
  final DateTime createdAt;
  final List<TagEntry> tags;
  final String? note;
}
