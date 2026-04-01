import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/payment_method.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/soft_card.dart';

class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  void _openAddCard(
    BuildContext context,
    AppState appState, {
    PaymentMethod? method,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _AddCardSheet(
          initialMethod: method,
          onSave: (name, icon, color) {
            if (method == null) {
              appState.addCard(name: name, icon: icon, color: color);
            } else {
              appState.updateCard(
                id: method.id,
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
    PaymentMethod method,
  ) async {
    final l10n = context.l10n;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.cardsDeleteTitle),
          content: Text(l10n.cardsDeleteMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.commonDelete),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      if (!context.mounted) {
        return;
      }
      appState.removeCard(method.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.cardsDeleteSuccess)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final l10n = context.l10n;
    final cards = appState.paymentMethods
        .where((method) => method.type == PaymentMethodType.card)
        .toList();
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AppHeader(
              title: l10n.cardsTitle,
              leading: canPop
                  ? IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                    )
                  : null,
              actions: [
                IconButton(
                  onPressed: () => _openAddCard(context, appState),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: cards.isEmpty
                    ? Center(
                        child: Text(
                          l10n.cardsEmpty,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      )
                    : ReorderableListView.builder(
                        buildDefaultDragHandles: false,
                        itemCount: cards.length,
                        onReorder: (oldIndex, newIndex) {
                          appState.reorderCard(oldIndex, newIndex);
                        },
                        itemBuilder: (context, index) {
                          final method = cards[index];
                          return Padding(
                            key: ValueKey(method.id),
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
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          method.icon,
                                          color: method.color,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          method.name,
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
                                        onPressed: () => _openAddCard(
                                          context,
                                          appState,
                                          method: method,
                                        ),
                                        icon: Icon(
                                          Icons.edit,
                                          color: AppColors.accentIncome,
                                        ),
                                        iconSize: 26,
                                        padding: EdgeInsets.zero,
                                        constraints:
                                            const BoxConstraints.tightFor(
                                              width: 32,
                                              height: 32,
                                            ),
                                      ),
                                      const SizedBox(width: 2),
                                      IconButton(
                                        onPressed: () => _confirmDelete(
                                          context,
                                          appState,
                                          method,
                                        ),
                                        icon: Icon(
                                          Icons.delete,
                                          color: AppColors.accentExpense,
                                        ),
                                        iconSize: 26,
                                        padding: EdgeInsets.zero,
                                        constraints:
                                            const BoxConstraints.tightFor(
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

class _AddCardSheet extends StatefulWidget {
  const _AddCardSheet({required this.onSave, this.initialMethod});

  final void Function(String name, IconData icon, Color color) onSave;
  final PaymentMethod? initialMethod;

  @override
  State<_AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends State<_AddCardSheet> {
  final TextEditingController _controller = TextEditingController();
  IconData _selectedIcon = Icons.credit_card;
  Color _selectedColor = const Color(0xFF6C8BF5);
  bool _initialized = false;

  final List<IconData> _icons = const [
    Icons.credit_card,
    Icons.wallet,
    Icons.account_balance,
    Icons.card_giftcard,
    Icons.savings_outlined,
    Icons.payments_outlined,
    Icons.qr_code_2_outlined,
    Icons.local_atm_outlined,
    Icons.account_balance_wallet_outlined,
    Icons.credit_score_outlined,
    Icons.work_outline,
    Icons.receipt_long_outlined,
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
    final method = widget.initialMethod;
    if (method != null) {
      _controller.text = method.name;
      _selectedIcon = method.icon;
      _selectedColor = method.color;
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
                    widget.initialMethod == null
                        ? l10n.cardsNewTitle
                        : l10n.cardsEditTitle,
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
                  icon: Icon(
                    Icons.check_rounded,
                    color: const Color(0xFF9AD27A),
                  ),
                  iconSize: 32,
                  tooltip: l10n.commonSave,
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: InputDecoration(hintText: l10n.cardsNameHint),
            ),
            const SizedBox(height: 12),
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
