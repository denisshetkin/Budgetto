import 'package:flutter/material.dart';

import '../models/reminder_entry.dart';
import '../services/local_notifications.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/soft_card.dart';

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString();
  return '$day.$month.$year';
}

String _formatTime(TimeOfDay value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _formatDateTime(DateTime value) {
  return '${_formatDate(value)}, ${_formatTime(TimeOfDay.fromDateTime(value))}';
}

int _generateNotificationId() {
  return DateTime.now().microsecondsSinceEpoch.remainder(1 << 31);
}

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  void _openForm(BuildContext context, {ReminderEntry? entry}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ReminderFormScreen(initialEntry: entry),
      ),
    );
  }

  Future<void> _toggleReminder(
    BuildContext context,
    AppState appState,
    ReminderEntry entry,
    bool value,
  ) async {
    if (value) {
      final allowed = await LocalNotifications.instance.requestPermissions();
      if (!allowed) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Разрешите уведомления в настройках устройства'),
            ),
          );
        }
        return;
      }
    }

    final updated = entry.copyWith(
      enabled: value,
      notificationId: value ? (entry.notificationId ?? _generateNotificationId()) : null,
    );
    appState.updateReminder(updated);
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final reminders = appState.reminders;
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Напоминания',
              leading: canPop
                  ? IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                    )
                  : null,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => _openForm(context),
                      borderRadius: BorderRadius.circular(18),
                      child: SoftCard(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.add,
                              color: AppColors.accentIncome,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Создать',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: reminders.isEmpty
                          ? Center(
                              child: Text(
                                'Пока нет напоминаний',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.separated(
                              itemCount: reminders.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final entry = reminders[index];
                                final textColor = entry.enabled
                                    ? null
                                    : AppColors.textSecondary;
                                final subtitleColor = entry.enabled
                                    ? AppColors.textSecondary
                                    : AppColors.stroke;
                                final comment = (entry.comment ?? '').trim();
                                return InkWell(
                                  onTap: () => _openForm(
                                    context,
                                    entry: entry,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  child: SoftCard(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                entry.title,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                      color: textColor,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${reminderFrequencyLabel(entry.frequency)} • ${_formatDateTime(entry.startsAt)}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: subtitleColor,
                                                    ),
                                              ),
                                              if (comment.isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  comment,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: subtitleColor,
                                                      ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        Switch(
                                          value: entry.enabled,
                                          onChanged: (value) => _toggleReminder(
                                            context,
                                            appState,
                                            entry,
                                            value,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderFormScreen extends StatefulWidget {
  const _ReminderFormScreen({this.initialEntry});

  final ReminderEntry? initialEntry;

  @override
  State<_ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends State<_ReminderFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  ReminderFrequency _frequency = ReminderFrequency.once;
  DateTime _startDate = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  bool _enabled = true;
  int? _notificationId;
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    final entry = widget.initialEntry;
    if (entry != null) {
      _nameController.text = entry.title;
      _commentController.text = entry.comment ?? '';
      _frequency = entry.frequency;
      _startDate = entry.startsAt;
      _time = TimeOfDay.fromDateTime(entry.startsAt);
      _enabled = entry.enabled;
      _notificationId = entry.notificationId;
    } else {
      final now = DateTime.now();
      _startDate = now;
      _time = TimeOfDay.fromDateTime(now.add(const Duration(hours: 1)));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  DateTime _composeStartDateTime() {
    return DateTime(
      _startDate.year,
      _startDate.month,
      _startDate.day,
      _time.hour,
      _time.minute,
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _startDate = picked;
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _time = picked;
    });
  }

  Future<void> _pickFrequency() async {
    final selected = await showModalBottomSheet<ReminderFrequency>(
      context: context,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: ReminderFrequency.values.map((frequency) {
              final isSelected = _frequency == frequency;
              return ListTile(
                onTap: () => Navigator.of(context).pop(frequency),
                title: Text(reminderFrequencyLabel(frequency)),
                trailing: isSelected
                    ? const Icon(
                        Icons.check,
                        color: AppColors.accentIncome,
                      )
                    : null,
              );
            }).toList(),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _frequency = selected;
      });
    }
  }

  Future<void> _save() async {
    setState(() {
      _showErrors = true;
    });

    final title = _nameController.text.trim();
    if (title.isEmpty) {
      return;
    }

    final startsAt = _composeStartDateTime();
    if (_frequency == ReminderFrequency.once &&
        startsAt.isBefore(DateTime.now())) {
      _showError('Выберите время в будущем');
      return;
    }

    if (_enabled) {
      final allowed = await LocalNotifications.instance.requestPermissions();
      if (!allowed) {
        _showError('Разрешите уведомления в настройках устройства');
        return;
      }
      _notificationId ??= _generateNotificationId();
    }

    final appState = AppStateScope.of(context);
    final entry = ReminderEntry(
      id:
          widget.initialEntry?.id ??
          'rem_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      frequency: _frequency,
      startsAt: startsAt,
      createdAt: widget.initialEntry?.createdAt ?? DateTime.now(),
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
      enabled: _enabled,
      notificationId: _enabled ? _notificationId : null,
    );

    if (widget.initialEntry == null) {
      appState.addReminder(entry);
    } else {
      appState.updateReminder(entry);
    }

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _delete() async {
    final entry = widget.initialEntry;
    if (entry == null) {
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удалить напоминание?'),
          content: const Text('Уверен, что хочешь удалить это напоминание?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
    if (confirm == true) {
      final appState = AppStateScope.of(context);
      appState.removeReminder(entry.id);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nameError = _showErrors && _nameController.text.trim().isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialEntry == null
              ? 'Создать напоминание'
              : 'Редактировать напоминание',
        ),
        backgroundColor: AppColors.surface1,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.stroke),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SoftCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(
                        'Имя напоминания',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Например, оплата аренды',
                          hintStyle: TextStyle(
                            color: nameError
                                ? AppColors.accentExpense
                                : AppColors.textSecondary,
                          ),
                          isDense: true,
                          border: InputBorder.none,
                        ),
                        onChanged: (_) {
                          if (_showErrors) {
                            setState(() {});
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (nameError) ...[
                const SizedBox(height: 6),
                Text(
                  'Обязательное поле для заполнения',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.accentExpense),
                ),
              ],
              const SizedBox(height: 12),
              SoftCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(
                        'Периодичность',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _pickFrequency,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  reminderFrequencyLabel(_frequency),
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              const Icon(
                                Icons.expand_more,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SoftCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(
                        'Дата начала',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            _formatDate(_startDate),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SoftCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(
                        'Время',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _pickTime,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            _formatTime(_time),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SoftCard(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(
                        'Комментарий',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Комментарий',
                          isDense: true,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: Text(
                    widget.initialEntry == null ? 'Создать' : 'Сохранить',
                  ),
                ),
              ),
              if (widget.initialEntry != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _delete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accentExpense,
                    ),
                    child: const Text('Удалить'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
