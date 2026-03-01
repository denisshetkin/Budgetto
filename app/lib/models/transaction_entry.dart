import 'package:flutter/material.dart';

import 'payment_method.dart';

enum TransactionType { expense, income }

class TransactionEntry {
  const TransactionEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.date,
    required this.paymentMethod,
    this.note,
    this.createdByUserId,
  });

  final String id;
  final TransactionType type;
  final double amount;
  final String categoryId;
  final String categoryName;
  final IconData categoryIcon;
  final Color categoryColor;
  final DateTime date;
  final PaymentMethod paymentMethod;
  final String? note;
  final String? createdByUserId;
}
