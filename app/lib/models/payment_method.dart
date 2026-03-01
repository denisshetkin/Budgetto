import 'package:flutter/material.dart';

enum PaymentMethodType { cash, card }

class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final PaymentMethodType type;
  final IconData icon;
  final Color color;
}
