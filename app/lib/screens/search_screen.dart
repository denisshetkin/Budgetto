import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/l10n.dart';
import '../models/transaction_entry.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../utils/transaction_filters.dart';
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
  final Set<String> _selectedTagIds = {};
  int _lastCategoryCount = 0;
  int _lastMethodCount = 0;
  int _lastTagCount = 0;
  DateTime? _fromDate;
  TimeOfDay? _fromTime;
  DateTime? _toDate;
  TimeOfDay? _toTime;
  final TextEditingController _queryController = TextEditingController();
  bool _initialized = false;

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
    if (_initialized) {
      return;
    }
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
    if (!mounted) {
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
    if (!mounted) {
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
    switch (_type) {
      case SearchType.income:
        return FilterMode.income;
      case SearchType.expense:
        return FilterMode.expense;
      case SearchType.all:
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

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final l10n = context.l10n;
    final transactions = _applyFilters(appState.transactions, appState);
    final symbol = appState.currencySymbol();
    final categories = appState.categories;
    final tags = appState.tags;
    final methods = appState.paymentMethods;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              l10n.searchTitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            SoftCard(
              child: TextField(
                controller: _queryController,
                decoration: InputDecoration(hintText: l10n.searchHint),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<SearchType>(
              segments: [
                ButtonSegment(
                  value: SearchType.all,
                  label: Text(l10n.searchAll),
                ),
                ButtonSegment(
                  value: SearchType.expense,
                  label: Text(l10n.overviewExpenses),
                ),
                ButtonSegment(
                  value: SearchType.income,
                  label: Text(l10n.overviewIncome),
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
                  Expanded(
                    child: TextButton.icon(
                      onPressed: _pickFromDateTime,
                      icon: Icon(Icons.schedule, size: 18),
                      label: Text(
                        _fromDate == null
                            ? l10n.searchFromPlaceholder
                            : l10n.searchFromValue(
                                _formatDateTime(context, _fromDate!, _fromTime),
                              ),
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
                            ? l10n.searchToPlaceholder
                            : l10n.searchToValue(
                                _formatDateTime(context, _toDate!, _toTime),
                              ),
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
                  title: Text(l10n.settingsTagsTitle),
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
                    if (tags.isEmpty)
                      Text(
                        l10n.searchTagsEmpty,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: tags.map((tag) {
                          final isSelected = _selectedTagIds.contains(tag.id);
                          return FilterChip(
                            label: Text(tag.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedTagIds.add(tag.id);
                                } else {
                                  _selectedTagIds.remove(tag.id);
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
                  title: Text(l10n.settingsCategoriesTitle),
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
                  title: Text(l10n.settingsPaymentMethodsTitle),
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
                  l10n.searchNoResults,
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

  String _formatDate(BuildContext context, DateTime date) {
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    return DateFormat('dd.MM.yyyy', localeTag).format(date);
  }

  String _formatTime(BuildContext context, TimeOfDay time) {
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final date = DateTime(2000, 1, 1, time.hour, time.minute);
    return DateFormat.Hm(localeTag).format(date);
  }

  String _formatDateTime(BuildContext context, DateTime date, TimeOfDay? time) {
    final t = time ?? const TimeOfDay(hour: 0, minute: 0);
    return '${_formatDate(context, date)} ${_formatTime(context, t)}';
  }
}
