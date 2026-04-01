import '../l10n/generated/app_localizations.dart';

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

String reminderFrequencyLabel(
  ReminderFrequency frequency,
  AppLocalizations l10n,
) {
  switch (frequency) {
    case ReminderFrequency.once:
      return l10n.reminderFrequencyOnce;
    case ReminderFrequency.daily:
      return l10n.reminderFrequencyDaily;
    case ReminderFrequency.weekly:
      return l10n.reminderFrequencyWeekly;
    case ReminderFrequency.biweekly:
      return l10n.reminderFrequencyBiweekly;
    case ReminderFrequency.fourWeeks:
      return l10n.reminderFrequencyFourWeeks;
    case ReminderFrequency.monthly:
      return l10n.reminderFrequencyMonthly;
    case ReminderFrequency.everyTwoMonths:
      return l10n.reminderFrequencyEveryTwoMonths;
    case ReminderFrequency.quarterly:
      return l10n.reminderFrequencyQuarterly;
    case ReminderFrequency.halfYear:
      return l10n.reminderFrequencyHalfYear;
    case ReminderFrequency.yearly:
      return l10n.reminderFrequencyYearly;
  }
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
