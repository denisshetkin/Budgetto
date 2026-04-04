import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/category_entry.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/premium_feature_gate.dart';
import '../widgets/soft_card.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  void _openAddCategory(
    BuildContext context,
    AppState appState, {
    CategoryEntry? category,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _AddCategorySheet(
          initialCategory: category,
          onSave: (name, icon, color) {
            if (category == null) {
              appState.addCategory(name: name, icon: icon, color: color);
            } else {
              appState.updateCategory(
                id: category.id,
                name: name,
                icon: icon,
                color: color,
              );
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AppState appState,
    CategoryEntry category,
  ) async {
    final l10n = context.l10n;
    final usedTransactionCount = appState.transactions
        .where((entry) => entry.categoryId == category.id)
        .length;
    final usedPlannedCount = appState.plannedEntries
        .where((entry) => entry.categoryId == category.id)
        .length;
    final totalUsageCount = usedTransactionCount + usedPlannedCount;
    final replacementOptions = appState.categories
        .where((item) => item.id != category.id)
        .toList(growable: false);

    if (totalUsageCount > 0 && replacementOptions.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(l10n.categoriesDeleteBlockedTitle),
            content: Text(l10n.categoriesDeleteBlockedMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.settingsDataUnderstoodButton),
              ),
            ],
          );
        },
      );
      return;
    }

    CategoryEntry? replacementCategory = replacementOptions.isNotEmpty
        ? replacementOptions.first
        : null;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.categoriesDeleteTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    totalUsageCount == 0
                        ? l10n.categoriesDeleteMessage
                        : l10n.categoriesDeleteUsedMessage(
                            usedTransactionCount,
                            usedPlannedCount,
                          ),
                  ),
                  if (totalUsageCount > 0) ...[
                    const SizedBox(height: 12),
                    Text(l10n.categoriesDeleteReplacementHint),
                    const SizedBox(height: 12),
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.categoriesReplacementLabel,
                        border: const OutlineInputBorder(),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: replacementCategory?.id,
                          items: replacementOptions
                              .map(
                                (item) => DropdownMenuItem<String>(
                                  value: item.id,
                                  child: Text(item.name),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: (value) {
                            replacementCategory = replacementOptions
                                .where((item) => item.id == value)
                                .cast<CategoryEntry?>()
                                .firstWhere(
                                  (item) => item != null,
                                  orElse: () => null,
                                );
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.commonCancel),
                ),
                TextButton(
                  onPressed: totalUsageCount > 0 && replacementCategory == null
                      ? null
                      : () => Navigator.of(context).pop(true),
                  child: Text(l10n.commonDelete),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirm == true) {
      if (!context.mounted) {
        return;
      }
      if (totalUsageCount > 0 && replacementCategory != null) {
        await appState.replaceCategoryAndRemove(
          fromCategoryId: category.id,
          toCategoryId: replacementCategory!.id,
        );
      } else {
        appState.removeCategory(category.id);
      }
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            totalUsageCount > 0 && replacementCategory != null
                ? l10n.categoriesDeleteMovedSuccess(replacementCategory!.name)
                : l10n.categoriesDeleteSuccess,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final l10n = context.l10n;
    final categories = appState.categories;
    final canPop = Navigator.of(context).canPop();
    final canManageCategories = appState.canManageCustomCategories;

    Widget buildCategoryRow(CategoryEntry category, {int? index}) {
      final row = SoftCard(
        child: SizedBox(
          height: 44,
          child: Row(
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.name,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              if (canManageCategories) ...[
                Icon(
                  Icons.drag_indicator,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: () => _openAddCategory(
                    context,
                    appState,
                    category: category,
                  ),
                  icon: Icon(Icons.edit, color: AppColors.accentIncome),
                  iconSize: 26,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 32,
                    height: 32,
                  ),
                ),
                const SizedBox(width: 2),
                IconButton(
                  onPressed: () => _confirmDelete(context, appState, category),
                  icon: Icon(Icons.delete, color: AppColors.accentExpense),
                  iconSize: 26,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 32,
                    height: 32,
                  ),
                ),
              ] else
                Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
            ],
          ),
        ),
      );

      if (index == null) {
        return row;
      }

      return ReorderableDelayedDragStartListener(
        index: index,
        child: row,
      );
    }

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AppHeader(
              title: l10n.settingsCategoriesTitle,
              leading: canPop
                  ? IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                    )
                  : null,
              actions: [
                IconButton(
                  onPressed: () {
                    if (!canManageCategories) {
                      showPremiumFeatureSheet(
                        context,
                        featureName: l10n.premiumFeatureCustomCategories,
                        message: l10n.premiumCategoriesInlineHint,
                      );
                      return;
                    }
                    _openAddCategory(context, appState);
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (!canManageCategories) ...[
                      PremiumFeatureCard(
                        featureName: l10n.premiumFeatureCustomCategories,
                        message: l10n.premiumCategoriesInlineHint,
                      ),
                      const SizedBox(height: 12),
                    ],
                    Expanded(
                      child: canManageCategories
                          ? ReorderableListView.builder(
                              buildDefaultDragHandles: false,
                              itemCount: categories.length,
                              onReorder: (oldIndex, newIndex) {
                                appState.reorderCategory(oldIndex, newIndex);
                              },
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                return Padding(
                                  key: ValueKey(category.id),
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: buildCategoryRow(
                                    category,
                                    index: index,
                                  ),
                                );
                              },
                            )
                          : ListView.builder(
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: buildCategoryRow(category),
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

class _AddCategorySheet extends StatefulWidget {
  const _AddCategorySheet({required this.onSave, this.initialCategory});

  final void Function(String name, IconData icon, Color color) onSave;
  final CategoryEntry? initialCategory;

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
  final TextEditingController _controller = TextEditingController();
  IconData _selectedIcon = Icons.category_outlined;
  Color _selectedColor = const Color(0xFF6C8BF5);
  bool _initialized = false;

  final List<IconData> _icons = const [
    Icons.restaurant_outlined,
    Icons.local_cafe_outlined,
    Icons.fastfood_outlined,
    Icons.home_outlined,
    Icons.directions_car_outlined,
    Icons.directions_bus_outlined,
    Icons.train_outlined,
    Icons.local_taxi_outlined,
    Icons.shopping_bag_outlined,
    Icons.shopping_cart_outlined,
    Icons.local_grocery_store_outlined,
    Icons.favorite_border,
    Icons.health_and_safety_outlined,
    Icons.fitness_center_outlined,
    Icons.movie_outlined,
    Icons.music_note_outlined,
    Icons.sports_soccer_outlined,
    Icons.school_outlined,
    Icons.work_outline,
    Icons.card_giftcard_outlined,
    Icons.flight_outlined,
    Icons.beach_access_outlined,
    Icons.hotel_outlined,
    Icons.pets_outlined,
    Icons.phone_iphone,
    Icons.wifi,
    Icons.lightbulb_outline,
    Icons.water_drop_outlined,
    Icons.savings_outlined,
    Icons.category_outlined,
  ];

  final List<Color> _colors = const [
    Color(0xFF6C8BF5),
    Color(0xFFFF6B6B),
    Color(0xFF9AD27A),
    Color(0xFFF4B266),
    Color(0xFF8C9BFF),
    Color(0xFF7BD3C2),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    final category = widget.initialCategory;
    if (category != null) {
      _controller.text = category.name;
      _selectedIcon = category.icon;
      _selectedColor = category.color;
    }
    _initialized = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openColorPicker() async {
    final l10n = context.l10n;
    final initial = _selectedColor;
    HSVColor hsv = HSVColor.fromColor(initial);
    Color temp = initial;

    final picked = await showDialog<Color>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.editorColorPickerTitle),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: temp,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.stroke, width: 1),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: hsv.hue,
                    min: 0,
                    max: 360,
                    onChanged: (value) {
                      setDialogState(() {
                        hsv = hsv.withHue(value);
                        temp = hsv.toColor();
                      });
                    },
                  ),
                  Slider(
                    value: hsv.saturation,
                    min: 0,
                    max: 1,
                    onChanged: (value) {
                      setDialogState(() {
                        hsv = hsv.withSaturation(value);
                        temp = hsv.toColor();
                      });
                    },
                  ),
                  Slider(
                    value: hsv.value,
                    min: 0,
                    max: 1,
                    onChanged: (value) {
                      setDialogState(() {
                        hsv = hsv.withValue(value);
                        temp = hsv.toColor();
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(temp),
              child: Text(l10n.commonSelect),
            ),
          ],
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedColor = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.initialCategory == null
                        ? l10n.categoriesNewTitle
                        : l10n.categoriesEditTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.accentExpense,
                  ),
                  iconSize: 32,
                  tooltip: l10n.commonCancel,
                ),
                IconButton(
                  onPressed: () {
                    final name = _controller.text.trim();
                    if (name.isEmpty) {
                      return;
                    }
                    widget.onSave(name, _selectedIcon, _selectedColor);
                  },
                  icon: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF9AD27A),
                  ),
                  iconSize: 32,
                  tooltip: l10n.commonSave,
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: InputDecoration(hintText: l10n.categoriesNameHint),
            ),
            Text(
              l10n.editorIconColorLabel,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                ..._colors.map((color) {
                  final isSelected =
                      color.toARGB32() == _selectedColor.toARGB32();
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.textPrimary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }),
                GestureDetector(
                  onTap: _openColorPicker,
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.stroke, width: 1),
                    ),
                    child: Icon(Icons.palette_outlined, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              l10n.editorIconLabel,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            LayoutBuilder(
              builder: (context, constraints) {
                const columns = 6;
                const spacing = 10.0;
                final itemSize =
                    ((constraints.maxWidth - spacing * (columns - 1)) / columns)
                        .clamp(44.0, 56.0);
                return Wrap(
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  spacing: spacing,
                  runSpacing: 12,
                  children: _icons.map((icon) {
                    final isSelected = icon == _selectedIcon;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIcon = icon;
                        });
                      },
                      child: Container(
                        height: itemSize,
                        width: itemSize,
                        decoration: BoxDecoration(
                          color: AppColors.surface2,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accentIncome
                                : AppColors.stroke,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: _selectedColor,
                          size: itemSize * 0.5,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
