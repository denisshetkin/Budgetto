class ChecklistItem {
  const ChecklistItem({
    required this.id,
    required this.title,
    required this.checked,
  });

  final String id;
  final String title;
  final bool checked;

  ChecklistItem copyWith({
    String? id,
    String? title,
    bool? checked,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      checked: checked ?? this.checked,
    );
  }
}

class ChecklistEntry {
  const ChecklistEntry({
    required this.id,
    required this.title,
    required this.items,
    required this.createdAt,
  });

  final String id;
  final String title;
  final List<ChecklistItem> items;
  final DateTime createdAt;

  ChecklistEntry copyWith({
    String? id,
    String? title,
    List<ChecklistItem>? items,
    DateTime? createdAt,
  }) {
    return ChecklistEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
