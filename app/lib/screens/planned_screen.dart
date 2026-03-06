import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/category_entry.dart';
import '../models/payment_method.dart';
import '../models/planned_entry.dart';
import '../models/tag_entry.dart';
import '../models/transaction_entry.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../services/local_notifications.dart';
import '../widgets/app_header.dart';
import '../widgets/slide_action_icon.dart';
import '../widgets/soft_card.dart';

typedef _CategoryItem = CategoryEntry;

typedef _PaymentItem = PaymentMethod;

typedef _TagItem = TagEntry;

String _formatPlannedDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString();
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day.$month.$year, $hour:$minute';
}

class PlannedScreen extends StatelessWidget {
  const PlannedScreen({super.key});

  void _openAddPlanned(
    BuildContext context,
    AppState appState, {
    PlannedEntry? entry,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _AddPlannedScreen(
          initialEntry: entry,
          onSave: (planned) {
            if (entry == null) {
              appState.addPlanned(planned);
            } else {
              appState.updatePlanned(planned);
            }
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AppState appState,
    PlannedEntry entry,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удалить запись?'),
          content: const Text('Уверен, что хочешь удалить эту запись?'),
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
      if (!context.mounted) {
        return;
      }
      appState.removePlanned(entry.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Платеж удален')));
    }
  }

  Future<void> _addToTransactions(
    BuildContext context,
    AppState appState,
    PlannedEntry entry,
  ) async {
    final symbol = appState.currencySymbol();
    final raw = entry.amount % 1 == 0
        ? entry.amount.toStringAsFixed(0)
        : entry.amount.toStringAsFixed(2);
    final amountLabel = symbol.isEmpty ? raw : '$raw $symbol';
    final description =
        (entry.note ?? '').trim().isNotEmpty ? entry.note!.trim() : entry.categoryName;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить в операции?'),
          content: Text(
            'Создать операцию из записи «$description» на сумму $amountLabel?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    final now = DateTime.now();
    final transaction = TransactionEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: entry.type,
      amount: entry.amount,
      categoryId: entry.categoryId,
      categoryName: entry.categoryName,
      categoryIcon: entry.categoryIcon,
      categoryColor: entry.categoryColor,
      date: now,
      paymentMethod: entry.paymentMethod,
      tags: entry.tags,
      note: entry.note,
      createdByUserId: appState.currentUser.id,
    );
    appState.addTransaction(transaction);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Добавлено в операции')),
    );
  }

  Future<void> _openActionsSheet(
    BuildContext context,
    AppState appState,
    PlannedEntry entry,
  ) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.add_circle_outline,
                    color: AppColors.accentIncome,
                  ),
                  title: const Text('Добавить в операции'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addToTransactions(context, appState, entry);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.edit,
                    color: AppColors.accentIncome,
                  ),
                  title: const Text('Редактировать'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openAddPlanned(context, appState, entry: entry);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.delete,
                    color: AppColors.accentExpense,
                  ),
                  title: const Text('Удалить'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _confirmDelete(context, appState, entry);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final entries = appState.plannedEntries;

    return Scaffold(
      body: SafeArea(top: false,
        child: Column(
          children: [
            AppHeader(
              title: 'Регулярные',
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              leading: Icon(
                Icons.event_note,
                size: 32,
                color: AppColors.accentTotal,
              ),
              actions: [
                IconButton(
                  onPressed: () => _openAddPlanned(context, appState),
                  icon: Icon(Icons.add),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: entries.isEmpty
                    ? Center(
                        child: Text(
                          'Пока нет регулярных',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : SlidableAutoCloseBehavior(
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: entries.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            return Slidable(
                              key: ValueKey(entry.id),
                              endActionPane: ActionPane(
                                motion: const DrawerMotion(),
                                extentRatio: 0.26,
                                children: [
                                  CustomSlidableAction(
                                    onPressed: (_) => _openAddPlanned(
                                      context,
                                      appState,
                                      entry: entry,
                                    ),
                                    backgroundColor: Colors.transparent,
                                    autoClose: false,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: SlideActionIcon(
                                        icon: Icons.edit,
                                        color: AppColors.accentIncome,
                                      ),
                                    ),
                                  ),
                                  CustomSlidableAction(
                                    onPressed: (_) =>
                                        _confirmDelete(context, appState, entry),
                                    backgroundColor: Colors.transparent,
                                    autoClose: false,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: SlideActionIcon(
                                        icon: Icons.delete,
                                        color: AppColors.accentExpense,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              child: GestureDetector(
                                onTap: () => _openAddPlanned(
                                  context,
                                  appState,
                                  entry: entry,
                                ),
                                onLongPress: () =>
                                    _openActionsSheet(context, appState, entry),
                                child: SoftCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            height: 32,
                                            width: 32,
                                            decoration: BoxDecoration(
                                              color: AppColors.surface2,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              entry.categoryIcon,
                                              color: entry.categoryColor,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  (entry.note ?? '')
                                                          .trim()
                                                          .isNotEmpty
                                                      ? entry.note!
                                                      : entry.categoryName,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  entry.paymentMethod.name,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                ),
                                                if (entry.scheduledAt != null)
                                                  ...[
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      entry.notify
                                                          ? 'Напоминание: ${_formatPlannedDate(entry.scheduledAt!)}'
                                                          : 'Дата: ${_formatPlannedDate(entry.scheduledAt!)}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color: AppColors
                                                                .textSecondary,
                                                          ),
                                                    ),
                                                  ],
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Builder(
                                            builder: (context) {
                                              final symbol =
                                                  appState.currencySymbol();
                                              final raw = entry.amount % 1 == 0
                                                  ? entry.amount
                                                      .toStringAsFixed(0)
                                                  : entry.amount
                                                      .toStringAsFixed(2);
                                              final label = symbol.isEmpty
                                                  ? raw
                                                  : '$raw $symbol';
                                              final isIncome = entry.type ==
                                                  TransactionType.income;
                                              return Text(
                                                '${isIncome ? '+' : '-'} $label',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                      color: isIncome
                                                          ? AppColors
                                                              .accentIncome
                                                          : AppColors
                                                              .accentExpense,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            onPressed: () => _addToTransactions(
                                              context,
                                              appState,
                                              entry,
                                            ),
                                            icon: Icon(
                                              Icons.add_circle_outline,
                                              color: AppColors.accentIncome,
                                            ),
                                            iconSize: 22,
                                            padding: EdgeInsets.zero,
                                            constraints:
                                                const BoxConstraints.tightFor(
                                              width: 34,
                                              height: 34,
                                            ),
                                            tooltip: 'Добавить в операции',
                                          ),
                                        ],
                                      ),
                                      if (entry.tags.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: entry.tags
                                              .map((tag) => _TagChip(tag: tag))
                                              .toList(),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPlannedScreen extends StatefulWidget {
  const _AddPlannedScreen({required this.onSave, this.initialEntry});

  final PlannedEntry? initialEntry;
  final void Function(PlannedEntry entry) onSave;

  @override
  State<_AddPlannedScreen> createState() => _AddPlannedScreenState();
}

class _AddPlannedScreenState extends State<_AddPlannedScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  TransactionType _type = TransactionType.expense;
  _CategoryItem? _selectedCategory;
  _PaymentItem? _selectedMethod;
  Set<String> _selectedTagIds = {};
  DateTime? _scheduledAt;
  bool _notify = false;
  int? _notificationId;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }

    final appState = AppStateScope.of(context);
    final entry = widget.initialEntry;

    if (entry != null) {
      _type = entry.type;
      final category = appState.categories
          .where((item) => item.id == entry.categoryId)
          .cast<_CategoryItem?>()
          .firstWhere((item) => item != null, orElse: () => null);
      _selectedCategory =
          category ??
          (appState.categories.isNotEmpty ? appState.categories.first : null);

      final method = appState.paymentMethods
          .where((item) => item.id == entry.paymentMethod.id)
          .cast<_PaymentItem?>()
          .firstWhere((item) => item != null, orElse: () => null);
      _selectedMethod =
          method ??
          (appState.paymentMethods.isNotEmpty
              ? appState.paymentMethods.first
              : null);

      _amountController.text = entry.amount % 1 == 0
          ? entry.amount.toStringAsFixed(0)
          : entry.amount.toStringAsFixed(2);
      _noteController.text = entry.note ?? '';
      _selectedTagIds = entry.tags.map((tag) => tag.id).toSet();
      _scheduledAt = entry.scheduledAt;
      _notify = entry.notify;
      _notificationId = entry.notificationId;
    } else {
      _type = TransactionType.expense;
      _selectedCategory = appState.categories.isNotEmpty
          ? appState.categories.first
          : null;
      _selectedMethod = appState.paymentMethods.isNotEmpty
          ? appState.paymentMethods.first
          : null;
      _selectedTagIds = {};
      _scheduledAt = null;
      _notify = false;
      _notificationId = null;
    }

    _initialized = true;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickScheduledAt() async {
    final now = DateTime.now();
    final initialDate = _scheduledAt ?? now;
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null) {
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt ?? now),
    );
    if (time == null) {
      return;
    }
    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  String _formatScheduledAt(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day.$month.$year, $hour:$minute';
  }

  Future<bool> _ensureNotificationsAllowed() async {
    final granted = await LocalNotifications.instance.requestPermissions();
    if (!granted) {
      _showError('Разрешите уведомления в настройках устройства');
    }
    return granted;
  }

  int _generateNotificationId() {
    return DateTime.now().microsecondsSinceEpoch.remainder(1 << 31);
  }

  Future<void> _save() async {
    final appState = AppStateScope.of(context);
    final raw = _amountController.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(raw);
    if (amount == null || amount <= 0) {
      _showError('Введите сумму больше 0');
      return;
    }

    if (_selectedCategory == null) {
      _showError('Выберите категорию');
      return;
    }

    if (_selectedMethod == null) {
      _showError('Выберите способ оплаты');
      return;
    }

    if (_notify) {
      if (_scheduledAt == null) {
        _showError('Выберите дату и время');
        return;
      }
      if (_scheduledAt!.isBefore(DateTime.now())) {
        _showError('Выберите время в будущем');
        return;
      }
      final allowed = await _ensureNotificationsAllowed();
      if (!allowed) {
        return;
      }
      _notificationId ??= _generateNotificationId();
    }

    final entry = PlannedEntry(
      id:
          widget.initialEntry?.id ??
          'plan_${DateTime.now().millisecondsSinceEpoch}',
      type: _type,
      amount: amount,
      categoryId: _selectedCategory!.id,
      categoryName: _selectedCategory!.name,
      categoryIcon: _selectedCategory!.icon,
      categoryColor: _selectedCategory!.color,
      paymentMethod: _selectedMethod!,
      createdAt: widget.initialEntry?.createdAt ?? DateTime.now(),
      tags: appState.tags
          .where((tag) => _selectedTagIds.contains(tag.id))
          .toList(),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      scheduledAt: _scheduledAt,
      notify: _notify,
      notificationId: _notify ? _notificationId : null,
    );

    widget.onSave(entry);
    Navigator.of(context).pop();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final categories = appState.categories;
    final methods = appState.paymentMethods;
    final tags = appState.tags;
    final accent = _type == TransactionType.expense
        ? AppColors.accentExpense
        : AppColors.accentIncome;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialEntry == null
              ? 'Новая регулярная запись'
              : 'Редактировать запись',
        ),
        backgroundColor: AppColors.surface1,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.stroke),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close_rounded,
              color: AppColors.accentExpense,
            ),
            iconSize: 36,
            tooltip: 'Отмена',
          ),
          IconButton(
            onPressed: _save,
            icon: Icon(Icons.check_rounded, color: Color(0xFF9AD27A)),
            iconSize: 36,
            tooltip: 'Сохранить',
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SegmentedButton<TransactionType>(
                showSelectedIcon: false,
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return accent.withOpacity(0.22);
                    }
                    return AppColors.surface1;
                  }),
                  textStyle: WidgetStatePropertyAll(
                    Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Расход'),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Доход'),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (selection) {
                  setState(() {
                    _type = selection.first;
                  });
                },
              ),
              const SizedBox(height: 12),
              SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      'Сумма',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface2.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: accent, width: 1.4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9.,]'),
                          ),
                        ],
                        textAlign: TextAlign.left,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          hintText: '0',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      'Описание',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface2.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: accent, width: 1.4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: _noteController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Например, коммуналка',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      'Когда',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _pickScheduledAt,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface2.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: accent,
                            width: 1.2,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Text(
                          _scheduledAt == null
                              ? 'Выбрать дату и время'
                              : _formatScheduledAt(_scheduledAt!),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Напомнить',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Switch(
                    value: _notify,
                    onChanged: (value) async {
                      if (value) {
                        if (_scheduledAt == null) {
                          await _pickScheduledAt();
                          if (_scheduledAt == null) {
                            return;
                          }
                        }
                        final allowed = await _ensureNotificationsAllowed();
                        if (!allowed) {
                          return;
                        }
                        _notificationId ??= _generateNotificationId();
                      }
                      setState(() {
                        _notify = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Оплата',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: methods.map((method) {
                final isSelected = _selectedMethod?.id == method.id;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMethod = method;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.surface2 : AppColors.surface1,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? accent : AppColors.stroke,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(method.icon, color: method.color, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          method.name,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'Категория',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: categories.map((category) {
                final isSelected = _selectedCategory?.id == category.id;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.surface2 : AppColors.surface1,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? accent : AppColors.stroke,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(category.icon, color: category.color, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          category.name,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'Теги',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (tags.isEmpty)
              Text(
                'Теги пока не добавлены',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: tags.map((tag) {
                  final isSelected = _selectedTagIds.contains(tag.id);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedTagIds.remove(tag.id);
                        } else {
                          _selectedTagIds.add(tag.id);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.surface2 : AppColors.surface1,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? accent : AppColors.stroke,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.tag, color: tag.color, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            tag.name,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.tag});

  final _TagItem tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.stroke, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.tag, color: tag.color, size: 14),
          const SizedBox(width: 4),
          Text(
            tag.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
