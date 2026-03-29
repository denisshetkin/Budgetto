import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction_entry.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../utils/transaction_filters.dart';
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
  static const _prefShowTotal = 'transactions_show_total';
  static const _prefShowCategoryIcon = 'transactions_show_category_icon';
  static const _prefShowPaymentIcon = 'transactions_show_payment_icon';
  static const _prefShowTags = 'transactions_show_tags';
  static const _prefShowAuthors = 'transactions_show_authors';
  static const _prefGroupByDate = 'transactions_group_by_date';
  FilterType _filterType = FilterType.all;
  final Set<String> _selectedCategoryIds = {};
  final Set<String> _selectedMethodIds = {};
  final Set<String> _selectedTagIds = {};
  int _lastCategoryCount = 0;
  int _lastMethodCount = 0;
  int _lastTagCount = 0;
  DateTime? _fromDate;
  TimeOfDay? _fromTime;
  DateTime? _toDate;
  TimeOfDay? _toTime;
  bool _showAuthors = false;
  bool _showCategoryIcon = false;
  bool _showPaymentIcon = false;
  bool _showTags = true;
  bool _showTotal = false;
  bool _groupByDate = false;
  DateTime? _selectedMonth;
  bool _useCustomRange = false;
  final TextEditingController _queryController = TextEditingController();
  bool _filtersInitialized = false;
  bool _showFilterBar = false;
  bool _showDisplayBar = false;

  @override
  void initState() {
    super.initState();
    _loadDisplayPrefs();
  }

  Future<void> _openBudgetPicker(AppState appState) async {
    final families = appState.availableFamilies;
    await showModalBottomSheet(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Выбери бюджет',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SoftCard(
                  child: ListTile(
                    title: const Text('Личный бюджет'),
                    subtitle: const Text('Только для тебя'),
                    trailing: !appState.isFamilyMode
                        ? Icon(
                            Icons.check_circle,
                            color: AppColors.accentIncome,
                          )
                        : Icon(
                            Icons.circle_outlined,
                            color: AppColors.textSecondary,
                          ),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await appState.switchToPersonalBudget();
                    },
                  ),
                ),
                const SizedBox(height: 8),
                ...families.map((family) {
                  final isActive = appState.family?.id == family.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SoftCard(
                      child: ListTile(
                        title: Text(family.name),
                        subtitle: Text(family.inviteCode),
                        trailing: isActive
                            ? Icon(
                                Icons.check_circle,
                                color: AppColors.accentIncome,
                              )
                            : Icon(
                                Icons.circle_outlined,
                                color: AppColors.textSecondary,
                              ),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await appState.switchToFamilyBudget(family.id);
                        },
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

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

  static const List<String> _monthShortEn = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatGroupDate(DateTime date) {
    final month = _monthShortEn[date.month - 1];
    return '${date.day} $month ${date.year}';
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

  DateTime _monthStart(DateTime month) {
    return DateTime(month.year, month.month);
  }

  DateTime _monthEnd(DateTime month) {
    return DateTime(
      month.year,
      month.month + 1,
    ).subtract(const Duration(minutes: 1));
  }

  void _setMonthFilter(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    _useCustomRange = false;
    final start = _monthStart(month);
    final end = _monthEnd(month);
    _fromDate = DateTime(start.year, start.month, start.day);
    _fromTime = const TimeOfDay(hour: 0, minute: 0);
    _toDate = DateTime(end.year, end.month, end.day);
    _toTime = const TimeOfDay(hour: 23, minute: 59);
  }

  bool _isFullMonthRange(
    DateTime? fromDate,
    TimeOfDay? fromTime,
    DateTime? toDate,
    TimeOfDay? toTime,
  ) {
    if (fromDate == null || toDate == null) {
      return false;
    }
    final from = _combine(fromDate, fromTime);
    final to = _combine(toDate, toTime);
    if (from == null || to == null) {
      return false;
    }
    final start = _monthStart(fromDate);
    final end = _monthEnd(fromDate);
    return from.isAtSameMomentAs(start) && to.isAtSameMomentAs(end);
  }

  List<TransactionEntry> _sorted(List<TransactionEntry> source) {
    final sorted = [...source];
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  double _sumForType(List<TransactionEntry> entries, TransactionType type) {
    return entries
        .where((entry) => entry.type == type)
        .fold(0.0, (sum, entry) => sum + entry.amount);
  }

  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  List<DateTime> _monthOptions() {
    final now = DateTime.now();
    return List.generate(12, (index) => DateTime(now.year, now.month - index));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appState = AppStateScope.of(context);
    final categoryIds = appState.categories.map((category) => category.id);
    final methodIds = appState.paymentMethods.map((method) => method.id);
    final tagIds = appState.tags.map((tag) => tag.id);
    _syncSelection(_selectedCategoryIds, categoryIds, _lastCategoryCount);
    _syncSelection(_selectedMethodIds, methodIds, _lastMethodCount);
    _syncSelection(_selectedTagIds, tagIds, _lastTagCount);
    _lastCategoryCount = appState.categories.length;
    _lastMethodCount = appState.paymentMethods.length;
    _lastTagCount = appState.tags.length;
    if (_filtersInitialized) {
      return;
    }
    _setMonthFilter(DateTime.now());
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

  void _syncSelection(
    Set<String> selected,
    Iterable<String> availableIds,
    int previousCount,
  ) {
    final available = availableIds.toSet();
    final shouldSyncAll = selected.isEmpty || selected.length == previousCount;
    if (shouldSyncAll) {
      selected
        ..clear()
        ..addAll(available);
      return;
    }
    selected.removeWhere((id) => !available.contains(id));
  }

  FilterMode _filterMode() {
    switch (_filterType) {
      case FilterType.income:
        return FilterMode.income;
      case FilterType.expense:
        return FilterMode.expense;
      case FilterType.all:
        return FilterMode.all;
    }
  }

  List<TransactionEntry> _applyFilters(
    List<TransactionEntry> source,
    AppState appState,
  ) {
    final query = _queryController.text.trim().toLowerCase();
    final from = _combine(_fromDate, _fromTime);
    final to = _combine(_toDate, _toTime);
    final filter = TransactionFilter(
      mode: _filterMode(),
      selectedCategoryIds: _selectedCategoryIds,
      selectedMethodIds: _selectedMethodIds,
      selectedTagIds: _selectedTagIds,
      query: query,
      from: from,
      to: to,
    );

    final filtered = source
        .where(
          (entry) => shouldIncludeTransaction(
            entry: entry,
            filter: filter,
            categories: appState.categories,
            methods: appState.paymentMethods,
            tags: appState.tags,
          ),
        )
        .toList();

    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  bool _isFilterActive(AppState appState) {
    final query = _queryController.text.trim().isNotEmpty;
    final categoriesAll =
        _selectedCategoryIds.length == appState.categories.length;
    final methodsAll =
        _selectedMethodIds.length == appState.paymentMethods.length;
    final tagsAll = _selectedTagIds.length == appState.tags.length;
    final monthActive =
        _selectedMonth != null &&
        !_isSameMonth(_selectedMonth!, DateTime.now());
    final monthOnly = !_useCustomRange;
    return query ||
        _filterType != FilterType.all ||
        (monthOnly ? false : (_fromDate != null || _toDate != null)) ||
        monthActive ||
        !categoriesAll ||
        !methodsAll ||
        !tagsAll;
  }

  void _resetFilters(AppState appState) {
    setState(() {
      _queryController.clear();
      _filterType = FilterType.all;
      _setMonthFilter(DateTime.now());
      _selectedCategoryIds
        ..clear()
        ..addAll(appState.categories.map((category) => category.id));
      _selectedMethodIds
        ..clear()
        ..addAll(appState.paymentMethods.map((method) => method.id));
      _selectedTagIds
        ..clear()
        ..addAll(appState.tags.map((tag) => tag.id));
    });
  }

  Future<void> _loadDisplayPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }
    setState(() {
      _showTotal = prefs.getBool(_prefShowTotal) ?? false;
      _showCategoryIcon = prefs.getBool(_prefShowCategoryIcon) ?? true;
      _showPaymentIcon = prefs.getBool(_prefShowPaymentIcon) ?? false;
      _showTags = prefs.getBool(_prefShowTags) ?? true;
      _showAuthors = prefs.getBool(_prefShowAuthors) ?? false;
      _groupByDate = prefs.getBool(_prefGroupByDate) ?? true;
    });
  }

  Future<void> _saveDisplayPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefShowTotal, _showTotal);
    await prefs.setBool(_prefShowCategoryIcon, _showCategoryIcon);
    await prefs.setBool(_prefShowPaymentIcon, _showPaymentIcon);
    await prefs.setBool(_prefShowTags, _showTags);
    await prefs.setBool(_prefShowAuthors, _showAuthors);
    await prefs.setBool(_prefGroupByDate, _groupByDate);
  }

  Future<void> _openSearchFilter() async {
    final tempQuery = TextEditingController(text: _queryController.text);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              24 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Поиск',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                SoftCard(
                  child: TextField(
                    controller: tempQuery,
                    decoration: const InputDecoration(
                      hintText: 'Описание, категория, тег или сумма',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => tempQuery.clear(),
                        child: const Text('Сбросить'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          setState(() {
                            _queryController.text = tempQuery.text;
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
        );
      },
    );
  }

  Future<void> _openTypeFilter() async {
    var tempType = _filterType;
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Тип операций',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
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
                        setModalState(() {
                          tempType = selection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                tempType = FilterType.all;
                              });
                            },
                            child: const Text('Сбросить'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              setState(() {
                                _filterType = tempType;
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
            );
          },
        );
      },
    );
  }

  Future<void> _openDateFilter() async {
    var tempFromDate = _fromDate;
    var tempFromTime = _fromTime;
    var tempToDate = _toDate;
    var tempToTime = _toTime;

    void setRange(DateTime start, DateTime end) {
      tempFromDate = DateTime(start.year, start.month, start.day);
      tempFromTime = const TimeOfDay(hour: 0, minute: 0);
      tempToDate = DateTime(end.year, end.month, end.day);
      tempToTime = const TimeOfDay(hour: 23, minute: 59);
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final now = DateTime.now();
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Период',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _QuickChip(
                          label: 'Последний месяц',
                          onTap: () {
                            final start = DateTime(now.year, now.month - 1, 1);
                            final end = DateTime(now.year, now.month, 0);
                            setModalState(() => setRange(start, end));
                          },
                        ),
                        _QuickChip(
                          label: 'Квартал',
                          onTap: () {
                            final start = DateTime(now.year, now.month - 3, 1);
                            final end = DateTime(now.year, now.month, 0);
                            setModalState(() => setRange(start, end));
                          },
                        ),
                        _QuickChip(
                          label: 'Год',
                          onTap: () {
                            final start = DateTime(now.year - 1, now.month, 1);
                            final end = DateTime(now.year, now.month, 0);
                            setModalState(() => setRange(start, end));
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SoftCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: PopupMenuButton<DateTime>(
                              onSelected: (month) {
                                setModalState(() {
                                  final start = DateTime(
                                    month.year,
                                    month.month,
                                    1,
                                  );
                                  final end = DateTime(
                                    month.year,
                                    month.month + 1,
                                    0,
                                  );
                                  setRange(start, end);
                                });
                              },
                              itemBuilder: (context) {
                                return _monthOptions()
                                    .map(
                                      (month) => PopupMenuItem<DateTime>(
                                        value: month,
                                        child: Text(_monthLabel(month)),
                                      ),
                                    )
                                    .toList();
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    tempFromDate == null
                                        ? _monthLabel(now)
                                        : _monthLabel(tempFromDate!),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  Icon(
                                    Icons.expand_more,
                                    size: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
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
                        vertical: 10,
                      ),
                      child: Column(
                        children: [
                          _DateRow(
                            label: 'От',
                            value: tempFromDate == null
                                ? 'Выбери дату'
                                : _formatDateTime(tempFromDate!, tempFromTime),
                            onTap: () async {
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
                                    tempFromTime ?? TimeOfDay.fromDateTime(now),
                              );
                              setModalState(() {
                                tempFromDate = pickedDate;
                                tempFromTime =
                                    pickedTime ??
                                    tempFromTime ??
                                    const TimeOfDay(hour: 0, minute: 0);
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          _DateRow(
                            label: 'До',
                            value: tempToDate == null
                                ? 'Выбери дату'
                                : _formatDateTime(tempToDate!, tempToTime),
                            onTap: () async {
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
                                    tempToTime ?? TimeOfDay.fromDateTime(now),
                              );
                              setModalState(() {
                                tempToDate = pickedDate;
                                tempToTime =
                                    pickedTime ??
                                    tempToTime ??
                                    const TimeOfDay(hour: 23, minute: 59);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              final month = DateTime.now();
                              setModalState(() {
                                tempFromDate = _monthStart(month);
                                tempFromTime = const TimeOfDay(
                                  hour: 0,
                                  minute: 0,
                                );
                                final end = _monthEnd(month);
                                tempToDate = DateTime(
                                  end.year,
                                  end.month,
                                  end.day,
                                );
                                tempToTime = const TimeOfDay(
                                  hour: 23,
                                  minute: 59,
                                );
                              });
                            },
                            child: const Text('Сбросить'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              setState(() {
                                _fromDate = tempFromDate;
                                _fromTime = tempFromTime;
                                _toDate = tempToDate;
                                _toTime = tempToTime;
                                if (tempFromDate == null ||
                                    tempToDate == null) {
                                  _setMonthFilter(DateTime.now());
                                } else if (_isFullMonthRange(
                                  tempFromDate,
                                  tempFromTime,
                                  tempToDate,
                                  tempToTime,
                                )) {
                                  _selectedMonth = DateTime(
                                    tempFromDate!.year,
                                    tempFromDate!.month,
                                  );
                                  _useCustomRange = false;
                                } else {
                                  _selectedMonth = DateTime(
                                    tempFromDate!.year,
                                    tempFromDate!.month,
                                  );
                                  _useCustomRange = true;
                                }
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
            );
          },
        );
      },
    );
  }

  Future<void> _openCategoryFilter(AppState appState) async {
    final tempCategoryIds = <String>{..._selectedCategoryIds};
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Категории',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: appState.categories.map((category) {
                        final isSelected = tempCategoryIds.contains(
                          category.id,
                        );
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              if (isSelected) {
                                tempCategoryIds.remove(category.id);
                              } else {
                                tempCategoryIds.add(category.id);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.surface2
                                  : AppColors.surface1,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.accentTotal
                                    : AppColors.stroke,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  category.icon,
                                  color: category.color,
                                  size: 18,
                                ),
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
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                tempCategoryIds
                                  ..clear()
                                  ..addAll(
                                    appState.categories.map((c) => c.id),
                                  );
                              });
                            },
                            child: const Text('Сбросить'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              setState(() {
                                _selectedCategoryIds
                                  ..clear()
                                  ..addAll(tempCategoryIds);
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
            );
          },
        );
      },
    );
  }

  Future<void> _openTagFilter(AppState appState) async {
    final tempTagIds = <String>{..._selectedTagIds};
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Теги',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (appState.tags.isEmpty)
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
                        children: appState.tags.map((tag) {
                          final isSelected = tempTagIds.contains(tag.id);
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                if (isSelected) {
                                  tempTagIds.remove(tag.id);
                                } else {
                                  tempTagIds.add(tag.id);
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.surface2
                                    : AppColors.surface1,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.accentTotal
                                      : AppColors.stroke,
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
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                tempTagIds
                                  ..clear()
                                  ..addAll(appState.tags.map((t) => t.id));
                              });
                            },
                            child: const Text('Сбросить'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              setState(() {
                                _selectedTagIds
                                  ..clear()
                                  ..addAll(tempTagIds);
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
            );
          },
        );
      },
    );
  }

  Future<void> _openMethodFilter(AppState appState) async {
    final tempMethodIds = <String>{..._selectedMethodIds};
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Способы оплаты',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: appState.paymentMethods.map((method) {
                        final isSelected = tempMethodIds.contains(method.id);
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              if (isSelected) {
                                tempMethodIds.remove(method.id);
                              } else {
                                tempMethodIds.add(method.id);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.surface2
                                  : AppColors.surface1,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.accentTotal
                                    : AppColors.stroke,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  method.icon,
                                  color: method.color,
                                  size: 18,
                                ),
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
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                tempMethodIds
                                  ..clear()
                                  ..addAll(
                                    appState.paymentMethods.map((m) => m.id),
                                  );
                              });
                            },
                            child: const Text('Сбросить'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              setState(() {
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
            );
          },
        );
      },
    );
  }

  Widget _buildDisplayBar(AppState appState) {
    final barLine = AppColors.stroke;
    final barBackground = AppColors.surface1;
    final pillAccent = AppColors.chipBlue;
    return Column(
      children: [
        Container(width: double.infinity, height: 1, color: barLine),
        Container(
          width: double.infinity,
          color: barBackground,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Row(
                children: [
                  _FilterPill(
                    label: 'Итого',
                    active: _showTotal,
                    accentColor: pillAccent,
                    onTap: () {
                      setState(() {
                        _showTotal = !_showTotal;
                      });
                      _saveDisplayPrefs();
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterPill(
                    label: 'По датам',
                    active: _groupByDate,
                    accentColor: pillAccent,
                    onTap: () {
                      setState(() {
                        _groupByDate = !_groupByDate;
                      });
                      _saveDisplayPrefs();
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterPill(
                    label: 'Категории',
                    active: _showCategoryIcon,
                    accentColor: pillAccent,
                    onTap: () {
                      setState(() {
                        _showCategoryIcon = !_showCategoryIcon;
                      });
                      _saveDisplayPrefs();
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterPill(
                    label: 'Оплата',
                    active: _showPaymentIcon,
                    accentColor: pillAccent,
                    onTap: () {
                      setState(() {
                        _showPaymentIcon = !_showPaymentIcon;
                      });
                      _saveDisplayPrefs();
                    },
                  ),
                  const SizedBox(width: 8),
                  _FilterPill(
                    label: 'Теги',
                    active: _showTags,
                    accentColor: pillAccent,
                    onTap: () {
                      setState(() {
                        _showTags = !_showTags;
                      });
                      _saveDisplayPrefs();
                    },
                  ),
                  if (appState.isFamilyMode) ...[
                    const SizedBox(width: 8),
                    _FilterPill(
                      label: 'Автор',
                      active: _showAuthors,
                      accentColor: pillAccent,
                      onTap: () {
                        setState(() {
                          _showAuthors = !_showAuthors;
                        });
                        _saveDisplayPrefs();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        Container(width: double.infinity, height: 1, color: barLine),
      ],
    );
  }

  Widget _buildFilterBar(AppState appState) {
    final hasFilter = _isFilterActive(appState);
    final categoriesAll =
        _selectedCategoryIds.length == appState.categories.length;
    final methodsAll =
        _selectedMethodIds.length == appState.paymentMethods.length;
    final tagsAll = _selectedTagIds.length == appState.tags.length;
    final queryActive = _queryController.text.trim().isNotEmpty;
    final typeActive = _filterType != FilterType.all;
    final monthActive =
        _selectedMonth != null &&
        !_isSameMonth(_selectedMonth!, DateTime.now());
    final dateActive = _useCustomRange || monthActive;
    final categoryActive = !categoriesAll;
    final methodActive = !methodsAll;
    final tagActive = !tagsAll;
    final barLine = AppColors.stroke;
    final barBackground = AppColors.surface1;
    final pillAccent = AppColors.chipBlue;
    return Column(
      children: [
        Container(width: double.infinity, height: 1, color: barLine),
        Container(
          width: double.infinity,
          color: barBackground,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _FilterPill(
                    label: 'Сброс',
                    active: hasFilter,
                    accentColor: pillAccent,
                    emphasized: true,
                    enabled: hasFilter,
                    onTap: hasFilter ? () => _resetFilters(appState) : null,
                  ),
                  const SizedBox(width: 8),
                  _FilterPill(
                    label: 'Поиск',
                    active: queryActive,
                    accentColor: pillAccent,
                    onTap: _openSearchFilter,
                  ),
                  const SizedBox(width: 8),
                  _FilterPill(
                    label: 'Тип',
                    active: typeActive,
                    accentColor: pillAccent,
                    onTap: _openTypeFilter,
                  ),
                  const SizedBox(width: 8),
                  _FilterPill(
                    label: 'Период',
                    active: dateActive,
                    accentColor: pillAccent,
                    onTap: _openDateFilter,
                  ),
                  const SizedBox(width: 8),
                  _FilterPill(
                    label: 'Категории',
                    active: categoryActive,
                    accentColor: pillAccent,
                    onTap: () => _openCategoryFilter(appState),
                  ),
                  const SizedBox(width: 8),
                  _FilterPill(
                    label: 'Теги',
                    active: tagActive,
                    accentColor: pillAccent,
                    onTap: () => _openTagFilter(appState),
                  ),
                  const SizedBox(width: 8),
                  _FilterPill(
                    label: 'Оплата',
                    active: methodActive,
                    accentColor: pillAccent,
                    onTap: () => _openMethodFilter(appState),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(width: double.infinity, height: 1, color: barLine),
      ],
    );
  }

  List<Object> _groupedItems(List<TransactionEntry> entries) {
    final items = <Object>[];
    DateTime? currentDay;
    for (final entry in entries) {
      final day = DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (currentDay == null || day != currentDay) {
        items.add(day);
        currentDay = day;
      }
      items.add(entry);
    }
    return items;
  }

  Widget _buildDateHeader(DateTime day) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatGroupDate(day),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: AppColors.stroke),
        ],
      ),
    );
  }

  Widget _buildTransactionTile({
    required AppState appState,
    required TransactionEntry entry,
    required String symbol,
    required bool showAuthors,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Slidable(
        key: ValueKey(entry.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.26,
          children: [
            CustomSlidableAction(
              onPressed: (_) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddTransactionScreen(
                      initialType: entry.type,
                      initialEntry: entry,
                    ),
                  ),
                );
              },
              backgroundColor: Colors.transparent,
              autoClose: false,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 0),
                  child: SlideActionIcon(
                    icon: Icons.edit,
                    color: AppColors.accentIncome,
                  ),
                ),
              ),
            ),
            CustomSlidableAction(
              onPressed: (_) => _confirmDelete(context, appState, entry),
              backgroundColor: Colors.transparent,
              autoClose: false,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 0),
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
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddTransactionScreen(
                  initialType: entry.type,
                  initialEntry: entry,
                ),
              ),
            );
          },
          onLongPress: () => _openActionsSheet(context, appState, entry),
          child: SoftCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: TransactionRow(
              entry: entry,
              symbol: symbol,
              showCategoryIcon: _showCategoryIcon,
              showPaymentIcon: _showPaymentIcon,
              showTags: _showTags,
              authorName: showAuthors
                  ? appState.memberName(entry.createdByUserId)
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final budgetLabel = appState.isFamilyMode
        ? (appState.family?.name ?? 'Общий бюджет')
        : 'Личный бюджет';
    final budgetIcon = appState.isFamilyMode
        ? Icons.group
        : Icons.person_outline;
    final symbol = appState.currencySymbol();
    final transactions = _sorted(appState.transactions);
    final filteredTransactions = _applyFilters(transactions, appState);
    final income = _sumForType(filteredTransactions, TransactionType.income);
    final expense = _sumForType(filteredTransactions, TransactionType.expense);
    final balance = income - expense;
    final hasFilter = _isFilterActive(appState);
    final showAuthors = appState.isFamilyMode && _showAuthors;
    final emptyLabel = hasFilter ? 'Ничего не найдено' : 'Пока нет операций';
    final groupedItems = _groupByDate
        ? _groupedItems(filteredTransactions)
        : const <Object>[];

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AppHeader(
              title: 'Операции',
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              leading: Icon(
                Icons.swap_horiz,
                size: 32,
                color: AppColors.accentExpense,
              ),
              actions: [
                _BudgetChip(
                  label: budgetLabel,
                  icon: budgetIcon,
                  onTap: () => _openBudgetPicker(appState),
                ),
              ],
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _showDisplayBar
                  ? _buildDisplayBar(appState)
                  : (_showFilterBar
                        ? _buildFilterBar(appState)
                        : const SizedBox.shrink()),
            ),
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_showTotal) ...[
                          SoftCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                        ],
                        Expanded(
                          child: filteredTransactions.isEmpty
                              ? Center(
                                  child: Text(
                                    emptyLabel,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                )
                              : SlidableAutoCloseBehavior(
                                  child: _groupByDate
                                      ? ListView.builder(
                                          padding: EdgeInsets.zero,
                                          itemCount: groupedItems.length,
                                          itemBuilder: (context, index) {
                                            final item = groupedItems[index];
                                            if (item is DateTime) {
                                              return _buildDateHeader(item);
                                            }
                                            if (item is TransactionEntry) {
                                              return _buildTransactionTile(
                                                appState: appState,
                                                entry: item,
                                                symbol: symbol,
                                                showAuthors: showAuthors,
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          },
                                        )
                                      : ListView.separated(
                                          padding: EdgeInsets.zero,
                                          itemCount:
                                              filteredTransactions.length,
                                          separatorBuilder: (_, index) =>
                                              const SizedBox.shrink(),
                                          itemBuilder: (context, index) {
                                            final entry =
                                                filteredTransactions[index];
                                            return _buildTransactionTile(
                                              appState: appState,
                                              entry: entry,
                                              symbol: symbol,
                                              showAuthors: showAuthors,
                                            );
                                          },
                                        ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 80,
                    bottom: MediaQuery.of(context).padding.bottom + 16,
                    child: Row(
                      children: [
                        _ActionCircle(
                          icon: _showDisplayBar
                              ? Icons.tune
                              : Icons.tune_outlined,
                          color: _showDisplayBar
                              ? AppColors.accentIncome
                              : AppColors.textSecondary,
                          onTap: () {
                            setState(() {
                              _showDisplayBar = !_showDisplayBar;
                              if (_showDisplayBar) {
                                _showFilterBar = false;
                              }
                            });
                          },
                        ),
                        const SizedBox(width: 10),
                        _ActionCircle(
                          icon: _showFilterBar
                              ? Icons.filter_alt
                              : Icons.filter_alt_outlined,
                          color: (_showFilterBar || hasFilter)
                              ? AppColors.accentIncome
                              : AppColors.textSecondary,
                          onTap: () {
                            setState(() {
                              _showFilterBar = !_showFilterBar;
                              if (_showFilterBar) {
                                _showDisplayBar = false;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
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
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.stroke, width: 1),
        ),
        child: Icon(icon, color: color, size: 21),
      ),
    );
  }
}

class _BudgetChip extends StatelessWidget {
  const _BudgetChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 110),
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.expand_more, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.active,
    required this.onTap,
    this.accentColor,
    this.emphasized = false,
    this.enabled = true,
  });

  final String label;
  final bool active;
  final VoidCallback? onTap;
  final Color? accentColor;
  final bool emphasized;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final radius = 18.0;
    final resolvedAccentColor = accentColor ?? AppColors.accentIncome;
    final isEmphasizedActive = active && emphasized;
    final backgroundColor = isEmphasizedActive
        ? resolvedAccentColor.withValues(alpha: 0.16)
        : (active ? AppColors.surface2 : AppColors.surface1);
    final borderColor = active ? resolvedAccentColor : AppColors.stroke;
    final borderWidth = isEmphasizedActive ? 1.6 : 1.0;
    final contentColor = isEmphasizedActive
        ? resolvedAccentColor
        : AppColors.textPrimary;
    final canTap = enabled && onTap != null;
    return InkWell(
      onTap: canTap ? onTap : null,
      borderRadius: BorderRadius.circular(radius),
      child: Opacity(
        opacity: canTap ? 1 : 0.45,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: contentColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          children: [
            Icon(Icons.schedule, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const Spacer(),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
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
