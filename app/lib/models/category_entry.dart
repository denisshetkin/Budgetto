import 'package:flutter/material.dart';

class CategoryEntry {
  const CategoryEntry({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;
}
