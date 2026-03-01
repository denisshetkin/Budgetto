import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/transaction_entry.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/slide_action_icon.dart';
import '../widgets/soft_card.dart';
import '../widgets/transaction_row.dart';
import 'add_transaction_screen.dart';

enum FilterType { all, income, expense }

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  FilterType _filterType = FilterType.all;
  final Set<String> _selectedCategoryIds = {};
  final Set<String> _selectedMethodIds = {};
  DateTime? _fromDate;
  TimeOfDay? _fromTime;
  DateTime? _toDate;
  TimeOfDay? _toTime;
  final TextEditingController _queryController = TextEditingController();
  bool _filtersInitialized = false;

  Future<void> _confirmDelete(
    BuildContext context,
    AppState appState,
    TransactionEntry entry,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удалить операцию?'),
          content: const Text('Уверен, что хочешь удалить эту операцию?'),
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
      appState.removeTransaction(entry.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Операция удалена')));
    }
  }

  void _openActionsSheet(
    BuildContext context,
    AppState appState,
    TransactionEntry entry,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SheetAction(
                  icon: Icons.edit,
                  label: 'Редактировать',
                  color: AppColors.accentIncome,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddTransactionScreen(
                          initialType: entry.type,
                          initialEntry: entry,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _SheetAction(
                  icon: Icons.delete,
                  label: 'Удалить',
                  color: AppColors.accentExpense,
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

  String _formatAmount(double amount, String symbol) {
    final rounded = amount % 1 == 0
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    return symbol.isEmpty ? rounded : '$rounded $symbol';
  }

  String _monthLabel(DateTime date) {
    const months = [
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day.$month.$year';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDateTime(DateTime date, TimeOfDay? time) {
    final t = time ?? const TimeOfDay(hour: 0, minute: 0);
    return '${_formatDate(date)} ${_formatTime(t)}';
  }

  List<TransactionEntry> _sorted(List<TransactionEntry> source) {
    final sorted = [...source];
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  double _sumForMonth(
    List<TransactionEntry> entries,
    DateTime month,
    TransactionType type,
  ) {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    return entries
        .where(
          (entry) =>
              entry.type == type &&
              !entry.date.isBefore(start) &&
              entry.date.isBefore(end),
        )
        .fold(0.0, (sum, entry) => sum + entry.amount);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_filtersInitialized) {
      return;
    }
    final appState = AppStateScope.of(context);
    _selectedCategoryIds.addAll(
      appState.categories.map((category) => category.id),
    );
    _selectedMethodIds.addAll(
      appState.paymentMethods.map((method) => method.id),
    );
    _filtersInitialized = true;
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  DateTime? _combine(DateTime? date, TimeOfDay? time) {
    if (date == null) {
      return null;
    }
    final t = time ?? const TimeOfDay(hour: 0, minute: 0);
    return DateTime(date.year, date.month, date.day, t.hour, t.minute);
  }

  List<TransactionEntry> _applyFilters(List<TransactionEntry> source) {
    final query = _queryController.text.trim().toLowerCase();
    final from = _combine(_fromDate, _fromTime);
    final to = _combine(_toDate, _toTime);

    final filtered = source.where((entry) {
      if (_filterType == FilterType.income &&
          entry.type != TransactionType.income) {
        return false;
      }
      if (_filterType == FilterType.expense &&
          entry.type != TransactionType.expense) {
        return false;
      }
      if (_selectedCategoryIds.isNotEmpty &&
          !_selectedCategoryIds.contains(entry.categoryId)) {
        return false;
      }
      if (_selectedMethodIds.isNotEmpty &&
          !_selectedMethodIds.contains(entry.paymentMethod.id)) {
        return false;
      }
      if (from != null && entry.date.isBefore(from)) {
        return false;
      }
      if (to != null && entry.date.isAfter(to)) {
        return false;
      }
      if (query.isNotEmpty) {
        final note = (entry.note ?? '').toLowerCase();
        final category = entry.categoryName.toLowerCase();
        if (!note.contains(query) && !category.contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();

    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  bool _isFilterActive(AppState appState) {
    final query = _queryController.text.trim().isNotEmpty;
    final categoriesAll =
        _selectedCategoryIds.length == appState.categories.length;
    final methodsAll =
        _selectedMethodIds.length == appState.paymentMethods.length;
    return query ||
        _filterType != FilterType.all ||
        _fromDate != null ||
        _toDate != null ||
        !categoriesAll ||
        !methodsAll;
  }

  void _openFilterSheet(AppState appState) {
    final tempQuery = TextEditingController(text: _queryController.text);
    var tempType = _filterType;
    var tempFromDate = _fromDate;
    var tempFromTime = _fromTime;
    var tempToDate = _toDate;
    var tempToTime = _toTime;
    final tempCategoryIds = <String>{..._selectedCategoryIds};
    final tempMethodIds = <String>{..._selectedMethodIds};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void refresh() => setModalState(() {});
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Фильтр',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SoftCard(
                        child: TextField(
                          controller: tempQuery,
                          decoration: const InputDecoration(
                            hintText: 'Поиск по описанию или категории',
                          ),
                          onChanged: (_) => refresh(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<FilterType>(
                        segments: const [
                          ButtonSegment(
                            value: FilterType.all,
                            label: Text('Все'),
                          ),
                          ButtonSegment(
                            value: FilterType.expense,
                            label: Text('Расходы'),
                          ),
                          ButtonSegment(
                            value: FilterType.income,
                            label: Text('Доходы'),
                          ),
                        ],
                        selected: {tempType},
                        onSelectionChanged: (selection) {
                          tempType = selection.first;
                          refresh();
                        },
                      ),
                      const SizedBox(height: 12),
                      SoftCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () async {
                                  final now = DateTime.now();
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: tempFromDate ?? now,
                                    firstDate: DateTime(now.year - 2),
                                    lastDate: DateTime(now.year + 1),
                                  );
                                  if (pickedDate == null) {
                                    return;
                                  }
                                  final pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime:
                                        tempFromTime ??
                                        TimeOfDay.fromDateTime(now),
                                  );
                                  tempFromDate = pickedDate;
                                  tempFromTime =
                                      pickedTime ??
                                      tempFromTime ??
                                      const TimeOfDay(hour: 0, minute: 0);
                                  refresh();
                                },
                                icon: const Icon(Icons.schedule, size: 18),
                                label: Text(
                                  tempFromDate == null
                                      ? 'От: дата и время'
                                      : 'От: ${_formatDateTime(tempFromDate!, tempFromTime)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: TextButton.styleFrom(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () async {
                                  final now = DateTime.now();
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: tempToDate ?? now,
                                    firstDate: DateTime(now.year - 2),
                                    lastDate: DateTime(now.year + 1),
                                  );
                                  if (pickedDate == null) {
                                    return;
                                  }
                                  final pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime:
                                        tempToTime ??
                                        TimeOfDay.fromDateTime(now),
                                  );
                                  tempToDate = pickedDate;
                                  tempToTime =
                                      pickedTime ??
                                      tempToTime ??
                                      const TimeOfDay(hour: 23, minute: 59);
                                  refresh();
                                },
                                icon: const Icon(Icons.schedule, size: 18),
                                label: Text(
                                  tempToDate == null
                                      ? 'До: дата и время'
                                      : 'До: ${_formatDateTime(tempToDate!, tempToTime)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                style: TextButton.styleFrom(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SoftCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Theme(
                          data: Theme.of(
                            context,
                          ).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            title: const Text('Категории'),
                            collapsedIconColor: AppColors.textSecondary,
                            iconColor: AppColors.textSecondary,
                            shape: const RoundedRectangleBorder(
                              side: BorderSide(color: Colors.transparent),
                            ),
                            collapsedShape: const RoundedRectangleBorder(
                              side: BorderSide(color: Colors.transparent),
                            ),
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            childrenPadding: const EdgeInsets.only(
                              bottom: 8,
                              left: 4,
                              right: 4,
                            ),
                            children: [
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: appState.categories.map((category) {
                                  final isSelected = tempCategoryIds.contains(
                                    category.id,
                                  );
                                  return FilterChip(
                                    label: Text(category.name),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) {
                                        tempCategoryIds.add(category.id);
                                      } else {
                                        tempCategoryIds.remove(category.id);
                                      }
                                      refresh();
                                    },
                                    selectedColor: AppColors.surface2,
                                    checkmarkColor: AppColors.accentIncome,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    labelStyle: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SoftCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Theme(
                          data: Theme.of(
                            context,
                          ).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            title: const Text('Способы оплаты'),
                            collapsedIconColor: AppColors.textSecondary,
                            iconColor: AppColors.textSecondary,
                            shape: const RoundedRectangleBorder(
                              side: BorderSide(color: Colors.transparent),
                            ),
                            collapsedShape: const RoundedRectangleBorder(
                              side: BorderSide(color: Colors.transparent),
                            ),
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            childrenPadding: const EdgeInsets.only(
                              bottom: 8,
                              left: 4,
                              right: 4,
                            ),
                            children: [
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: appState.paymentMethods.map((method) {
                                  final isSelected = tempMethodIds.contains(
                                    method.id,
                                  );
                                  return FilterChip(
                                    label: Text(method.name),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) {
                                        tempMethodIds.add(method.id);
                                      } else {
                                        tempMethodIds.remove(method.id);
                                      }
                                      refresh();
                                    },
                                    selectedColor: AppColors.surface2,
                                    checkmarkColor: AppColors.accentIncome,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    labelStyle: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                tempQuery.clear();
                                tempType = FilterType.all;
                                tempFromDate = null;
                                tempFromTime = null;
                                tempToDate = null;
                                tempToTime = null;
                                tempCategoryIds
                                  ..clear()
                                  ..addAll(
                                    appState.categories.map((c) => c.id),
                                  );
                                tempMethodIds
                                  ..clear()
                                  ..addAll(
                                    appState.paymentMethods.map((m) => m.id),
                                  );
                                refresh();
                              },
                              child: const Text('Сбросить'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                setState(() {
                                  _queryController.text = tempQuery.text;
                                  _filterType = tempType;
                                  _fromDate = tempFromDate;
                                  _fromTime = tempFromTime;
                                  _toDate = tempToDate;
                                  _toTime = tempToTime;
                                  _selectedCategoryIds
                                    ..clear()
                                    ..addAll(tempCategoryIds);
                                  _selectedMethodIds
                                    ..clear()
                                    ..addAll(tempMethodIds);
                                });
                                Navigator.of(context).pop();
                              },
                              child: const Text('Применить'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final symbol = appState.currencySymbol();
    final transactions = _sorted(appState.transactions);
    final filteredTransactions = _applyFilters(transactions);
    final now = DateTime.now();
    final displayMonth = DateTime(now.year, now.month);
    final income = _sumForMonth(
      filteredTransactions,
      displayMonth,
      TransactionType.income,
    );
    final expense = _sumForMonth(
      filteredTransactions,
      displayMonth,
      TransactionType.expense,
    );
    final balance = income - expense;
    final hasFilter = _isFilterActive(appState);
    final emptyLabel = hasFilter ? 'Ничего не найдено' : 'Пока нет операций';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Операции',
              actions: [
                _ActionCircle(
                  icon: hasFilter
                      ? Icons.filter_alt
                      : Icons.filter_alt_outlined,
                  color: hasFilter
                      ? AppColors.accentIncome
                      : AppColors.textSecondary,
                  onTap: () => _openFilterSheet(appState),
                ),
                const SizedBox(width: 10),
                _ActionCircle(
                  icon: Icons.remove,
                  color: AppColors.accentExpense,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AddTransactionScreen(
                          initialType: TransactionType.expense,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                _ActionCircle(
                  icon: Icons.add,
                  color: AppColors.accentIncome,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AddTransactionScreen(
                          initialType: TransactionType.income,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SoftCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              _monthLabel(displayMonth),
                              textAlign: TextAlign.right,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Divider(color: AppColors.stroke, height: 1),
                          const SizedBox(height: 10),
                          _SummaryItem(
                            title: 'Доходы',
                            amount: '+ ${_formatAmount(income, symbol)}',
                            color: AppColors.accentIncome,
                          ),
                          const SizedBox(height: 10),
                          _SummaryItem(
                            title: 'Расходы',
                            amount: '- ${_formatAmount(expense, symbol)}',
                            color: AppColors.accentExpense,
                          ),
                          const SizedBox(height: 10),
                          _SummaryItem(
                            title: 'Итого',
                            amount: _formatAmount(balance, symbol),
                            color: AppColors.accentTotal,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: filteredTransactions.isEmpty
                          ? Center(
                              child: Text(
                                emptyLabel,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            )
                          : SlidableAutoCloseBehavior(
                              child: ListView.separated(
                                itemCount: filteredTransactions.length,
                                separatorBuilder: (_, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final entry = filteredTransactions[index];
                                  return Slidable(
                                    key: ValueKey(entry.id),
                                    endActionPane: ActionPane(
                                      motion: const DrawerMotion(),
                                      extentRatio: 0.26,
                                      children: [
                                        CustomSlidableAction(
                                          onPressed: (_) {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    AddTransactionScreen(
                                                      initialType: entry.type,
                                                      initialEntry: entry,
                                                    ),
                                              ),
                                            );
                                          },
                                          backgroundColor: Colors.transparent,
                                          autoClose: false,
                                          child: const Align(
                                            alignment: Alignment.centerRight,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                right: 0,
                                              ),
                                              child: SlideActionIcon(
                                                icon: Icons.edit,
                                                color: AppColors.accentIncome,
                                              ),
                                            ),
                                          ),
                                        ),
                                        CustomSlidableAction(
                                          onPressed: (_) => _confirmDelete(
                                            context,
                                            appState,
                                            entry,
                                          ),
                                          backgroundColor: Colors.transparent,
                                          autoClose: false,
                                          child: const Align(
                                            alignment: Alignment.centerRight,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                right: 0,
                                              ),
                                              child: SlideActionIcon(
                                                icon: Icons.delete,
                                                color: AppColors.accentExpense,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    child: GestureDetector(
                                      onLongPress: () => _openActionsSheet(
                                        context,
                                        appState,
                                        entry,
                                      ),
                                      child: SoftCard(
                                        child: TransactionRow(
                                          entry: entry,
                                          symbol: symbol,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
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

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.title,
    required this.amount,
    required this.color,
  });

  final String title;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          amount,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ActionCircle extends StatelessWidget {
  const _ActionCircle({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.stroke, width: 1),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.stroke, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
