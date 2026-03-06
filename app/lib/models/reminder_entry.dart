enum ReminderFrequency {
  once,
  daily,
  weekly,
  biweekly,
  fourWeeks,
  monthly,
  everyTwoMonths,
  quarterly,
  halfYear,
  yearly,
}

const Map<ReminderFrequency, String> _reminderFrequencyLabels = {
  ReminderFrequency.once: 'Один раз',
  ReminderFrequency.daily: 'Каждый день',
  ReminderFrequency.weekly: 'Каждую неделю',
  ReminderFrequency.biweekly: 'Каждые 2 недели',
  ReminderFrequency.fourWeeks: 'Каждые 4 недели',
  ReminderFrequency.monthly: 'Каждый месяц',
  ReminderFrequency.everyTwoMonths: 'Каждые 2 месяца',
  ReminderFrequency.quarterly: 'Каждый квартал',
  ReminderFrequency.halfYear: 'Каждые полгода',
  ReminderFrequency.yearly: 'Каждый год',
};

String reminderFrequencyLabel(ReminderFrequency frequency) {
  return _reminderFrequencyLabels[frequency] ?? 'Один раз';
}

class ReminderEntry {
  const ReminderEntry({
    required this.id,
    required this.title,
    required this.frequency,
    required this.startsAt,
    required this.createdAt,
    this.comment,
    this.enabled = true,
    this.notificationId,
  });

  final String id;
  final String title;
  final ReminderFrequency frequency;
  final DateTime startsAt;
  final DateTime createdAt;
  final String? comment;
  final bool enabled;
  final int? notificationId;

  ReminderEntry copyWith({
    String? id,
    String? title,
    ReminderFrequency? frequency,
    DateTime? startsAt,
    DateTime? createdAt,
    String? comment,
    bool? enabled,
    int? notificationId,
  }) {
    return ReminderEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      frequency: frequency ?? this.frequency,
      startsAt: startsAt ?? this.startsAt,
      createdAt: createdAt ?? this.createdAt,
      comment: comment ?? this.comment,
      enabled: enabled ?? this.enabled,
      notificationId: notificationId ?? this.notificationId,
    );
  }
}
