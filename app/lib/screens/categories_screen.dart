import 'package:flutter/material.dart';
import '../models/category_entry.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';
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
            title: const Text('Нельзя удалить категорию'),
            content: const Text(
              'Эта категория уже используется. Сначала создай другую категорию, чтобы перенести в неё записи.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Понятно'),
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
              title: const Text('Удалить категорию?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    totalUsageCount == 0
                        ? 'Уверен, что хочешь удалить эту категорию?'
                        : 'Категория используется в $usedTransactionCount операциях и $usedPlannedCount запланированных записях.',
                  ),
                  if (totalUsageCount > 0) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Перед удалением выбери категорию, в которую нужно перенести эти записи.',
                    ),
                    const SizedBox(height: 12),
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Новая категория',
                        border: OutlineInputBorder(),
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
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: totalUsageCount > 0 && replacementCategory == null
                      ? null
                      : () => Navigator.of(context).pop(true),
                  child: const Text('Удалить'),
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
                ? 'Категория удалена, записи перенесены в "${replacementCategory!.name}".'
                : 'Категория удалена',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final categories = appState.categories;
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AppHeader(
              title: 'Категории',
              leading: canPop
                  ? IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.arrow_back),
                    )
                  : null,
              actions: [
                IconButton(
                  onPressed: () => _openAddCategory(context, appState),
                  icon: Icon(Icons.add),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ReorderableListView.builder(
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
                      child: ReorderableDelayedDragStartListener(
                        index: index,
                        child: SoftCard(
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
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                ),
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
                                  icon: Icon(
                                    Icons.edit,
                                    color: AppColors.accentIncome,
                                  ),
                                  iconSize: 26,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints.tightFor(
                                    width: 32,
                                    height: 32,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                IconButton(
                                  onPressed: () => _confirmDelete(
                                    context,
                                    appState,
                                    category,
                                  ),
                                  icon: Icon(
                                    Icons.delete,
                                    color: AppColors.accentExpense,
                                  ),
                                  iconSize: 26,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints.tightFor(
                                    width: 32,
                                    height: 32,
                                  ),
                                ),
                              ],
                            ),
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
    final initial = _selectedColor;
    HSVColor hsv = HSVColor.fromColor(initial);
    Color temp = initial;

    final picked = await showDialog<Color>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Выбор цвета'),
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
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(temp),
              child: const Text('Выбрать'),
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
                        ? 'Новая категория'
                        : 'Редактировать категорию',
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
                  tooltip: 'Отмена',
                ),
                IconButton(
                  onPressed: () {
                    final name = _controller.text.trim();
                    if (name.isEmpty) {
                      return;
                    }
                    widget.onSave(name, _selectedIcon, _selectedColor);
                  },
                  icon: Icon(Icons.check_rounded, color: Color(0xFF9AD27A)),
                  iconSize: 32,
                  tooltip: 'Сохранить',
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Например, Спорт'),
            ),
            Text(
              'Цвет иконки',
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
              'Иконка',
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
