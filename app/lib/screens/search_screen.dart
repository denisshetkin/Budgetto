import 'package:flutter/material.dart';

import '../models/transaction_entry.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/soft_card.dart';
import '../widgets/transaction_row.dart';

enum SearchType { all, income, expense }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  SearchType _type = SearchType.all;
  final Set<String> _selectedCategoryIds = {};
  final Set<String> _selectedMethodIds = {};
  DateTime? _fromDate;
  TimeOfDay? _fromTime;
  DateTime? _toDate;
  TimeOfDay? _toTime;
  final TextEditingController _queryController = TextEditingController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    final appState = AppStateScope.of(context);
    _selectedCategoryIds.addAll(
      appState.categories.map((category) => category.id),
    );
    _selectedMethodIds.addAll(
      appState.paymentMethods.map((method) => method.id),
    );
    _initialized = true;
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _pickFromDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
    );
    if (pickedDate == null) {
      return;
    }
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _fromTime ?? TimeOfDay.fromDateTime(now),
    );
    setState(() {
      _fromDate = pickedDate;
      _fromTime =
          pickedTime ?? _fromTime ?? const TimeOfDay(hour: 0, minute: 0);
    });
  }

  Future<void> _pickToDateTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _toDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
    );
    if (pickedDate == null) {
      return;
    }
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _toTime ?? TimeOfDay.fromDateTime(now),
    );
    setState(() {
      _toDate = pickedDate;
      _toTime = pickedTime ?? _toTime ?? const TimeOfDay(hour: 23, minute: 59);
    });
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
      if (_type == SearchType.income && entry.type != TransactionType.income) {
        return false;
      }
      if (_type == SearchType.expense &&
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

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final transactions = _applyFilters(appState.transactions);
    final symbol = appState.currencySymbol();
    final categories = appState.categories;
    final methods = appState.paymentMethods;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
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
                controller: _queryController,
                decoration: const InputDecoration(
                  hintText: 'Поиск по описанию или категории',
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<SearchType>(
              segments: const [
                ButtonSegment(value: SearchType.all, label: Text('Все')),
                ButtonSegment(
                  value: SearchType.expense,
                  label: Text('Расходы'),
                ),
                ButtonSegment(value: SearchType.income, label: Text('Доходы')),
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
                  Expanded(
                    child: TextButton.icon(
                      onPressed: _pickFromDateTime,
                      icon: Icon(Icons.schedule, size: 18),
                      label: Text(
                        _fromDate == null
                            ? 'От: дата и время'
                            : 'От: ${_formatDateTime(_fromDate!, _fromTime)}',
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
                      onPressed: _pickToDateTime,
                      icon: Icon(Icons.schedule, size: 18),
                      label: Text(
                        _toDate == null
                            ? 'До: дата и время'
                            : 'До: ${_formatDateTime(_toDate!, _toTime)}',
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: const Text('Категории'),
                  initiallyExpanded: false,
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
                      children: categories.map((category) {
                        final isSelected = _selectedCategoryIds.contains(
                          category.id,
                        );
                        return FilterChip(
                          label: Text(category.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCategoryIds.add(category.id);
                              } else {
                                _selectedCategoryIds.remove(category.id);
                              }
                            });
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
                          labelStyle: Theme.of(context).textTheme.bodySmall,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: const Text('Способы оплаты'),
                  initiallyExpanded: false,
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
                      children: methods.map((method) {
                        final isSelected = _selectedMethodIds.contains(
                          method.id,
                        );
                        return FilterChip(
                          label: Text(method.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedMethodIds.add(method.id);
                              } else {
                                _selectedMethodIds.remove(method.id);
                              }
                            });
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
                          labelStyle: Theme.of(context).textTheme.bodySmall,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (transactions.isEmpty)
              Center(
                child: Text(
                  'Ничего не найдено',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              ListView.separated(
                itemCount: transactions.length,
                separatorBuilder: (_, index) => const SizedBox(height: 12),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final entry = transactions[index];
                  return SoftCard(
                    child: TransactionRow(
                      entry: entry,
                      symbol: symbol,
                      authorName: null,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
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
}
