import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../l10n/l10n.dart';
import '../models/category_entry.dart';
import '../models/payment_method.dart';
import '../models/tag_entry.dart';
import '../models/transaction_entry.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/soft_card.dart';

typedef _CategoryItem = CategoryEntry;

typedef _PaymentItem = PaymentMethod;

typedef _TagItem = TagEntry;

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({
    super.key,
    required this.initialType,
    this.initialEntry,
  });

  final TransactionType initialType;
  final TransactionEntry? initialEntry;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late TransactionType _type = widget.initialEntry?.type ?? widget.initialType;
  late DateTime _selectedDate = widget.initialEntry?.date ?? DateTime.now();
  late TimeOfDay _selectedTime = TimeOfDay.fromDateTime(
    widget.initialEntry?.date ?? DateTime.now(),
  );
  _CategoryItem? _selectedCategory;
  _PaymentItem? _selectedMethod;
  Set<String> _selectedTagIds = {};
  bool _initialized = false;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }

    final appState = AppStateScope.of(context);
    final entry = widget.initialEntry;

    if (entry != null) {
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
    } else {
      _selectedCategory = appState.categories.isNotEmpty
          ? appState.categories.first
          : null;
      _selectedMethod = appState.paymentMethods.isNotEmpty
          ? appState.paymentMethods.first
          : null;
      _selectedTagIds = {};
    }

    _initialized = true;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _save() {
    final appState = AppStateScope.of(context);
    final l10n = context.l10n;
    final raw = _amountController.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(raw);
    if (amount == null || amount <= 0) {
      _showError(l10n.formAmountPositiveError);
      return;
    }

    if (_selectedCategory == null) {
      _showError(l10n.formChooseCategoryError);
      return;
    }

    if (_selectedMethod == null) {
      _showError(l10n.formChoosePaymentError);
      return;
    }

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final entry = TransactionEntry(
      id:
          widget.initialEntry?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      type: _type,
      amount: amount,
      categoryId: _selectedCategory!.id,
      categoryName: _selectedCategory!.name,
      categoryIcon: _selectedCategory!.icon,
      categoryColor: _selectedCategory!.color,
      date: dateTime,
      paymentMethod: _selectedMethod!,
      tags: appState.tags
          .where((tag) => _selectedTagIds.contains(tag.id))
          .toList(),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      createdByUserId:
          widget.initialEntry?.createdByUserId ?? appState.currentUser.id,
    );

    if (widget.initialEntry == null) {
      appState.addTransaction(entry);
    } else {
      appState.updateTransaction(entry);
    }

    Navigator.of(context).pop();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final l10n = context.l10n;
    final typeLabel = _type == TransactionType.expense
        ? l10n.transactionTypeExpense
        : l10n.transactionTypeIncome;
    final accent = _type == TransactionType.expense
        ? AppColors.accentExpense
        : AppColors.accentIncome;
    const leftColumnWidth = 120.0;

    final categories = appState.categories;
    final methods = appState.paymentMethods;
    final tags = appState.tags;

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialEntry == null
              ? l10n.addTransactionNewTitle(typeLabel)
              : l10n.addTransactionEditTitle,
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
            icon: Icon(Icons.close_rounded, color: AppColors.accentExpense),
            iconSize: 36,
            tooltip: l10n.commonCancel,
          ),
          IconButton(
            onPressed: _save,
            icon: Icon(Icons.check_rounded, color: Color(0xFF9AD27A)),
            iconSize: 36,
            tooltip: l10n.commonSave,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SoftCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: leftColumnWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(16),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_month_outlined, size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _formatDate(_selectedDate),
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _pickTime,
                            borderRadius: BorderRadius.circular(16),
                            child: Row(
                              children: [
                                Icon(Icons.access_time, size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _formatTime(_selectedTime),
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SegmentedButton<TransactionType>(
                        showSelectedIcon: false,
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith((
                            states,
                          ) {
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
                        segments: [
                          ButtonSegment(
                            value: TransactionType.expense,
                            label: Text(l10n.transactionTypeExpense),
                          ),
                          ButtonSegment(
                            value: TransactionType.income,
                            label: Text(l10n.transactionTypeIncome),
                          ),
                        ],
                        selected: {_type},
                        onSelectionChanged: (selection) {
                          setState(() {
                            _type = selection.first;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SoftCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: leftColumnWidth,
                      child: Text(
                        l10n.formAmountLabel,
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
                          style: Theme.of(context).textTheme.headlineMedium
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
              const SizedBox(height: 16),
              SoftCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: leftColumnWidth,
                      child: Text(
                        l10n.formDescriptionLabel,
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
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: l10n.addTransactionDescriptionHint,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.formPaymentLabel,
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
                        color: isSelected
                            ? AppColors.surface2
                            : AppColors.surface1,
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
                l10n.formCategoryLabel,
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
                        color: isSelected
                            ? AppColors.surface2
                            : AppColors.surface1,
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
                l10n.formTagsLabel,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              if (tags.isEmpty)
                Text(
                  l10n.formTagsEmpty,
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
                          color: isSelected
                              ? AppColors.surface2
                              : AppColors.surface1,
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

  String _formatDate(DateTime date) {
    return DateFormat.yMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(date);
  }

  String _formatTime(TimeOfDay time) {
    final date = DateTime(2000, 1, 1, time.hour, time.minute);
    return DateFormat.Hm(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(date);
  }
}
