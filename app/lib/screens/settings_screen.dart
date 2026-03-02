import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/currency_picker_sheet.dart';
import '../widgets/soft_card.dart';

enum _BudgetMode { personal, family }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _memberNameController = TextEditingController();
  final TextEditingController _familyNameController = TextEditingController();
  bool _memberNameDirty = false;
  bool _familyNameDirty = false;
  bool _showFamilyErrors = false;
  bool _initialized = false;

  bool _validateFamilyForm() {
    final memberValid =
        _memberNameController.text.trim().isNotEmpty &&
        _memberNameController.text.trim().toLowerCase() != 'я';
    final budgetValid = _familyNameController.text.trim().isNotEmpty;
    setState(() {
      _showFamilyErrors = !memberValid || !budgetValid;
    });
    if (!memberValid || !budgetValid) {
      return false;
    }
    return true;
  }

  InputDecoration _inlineInputDecoration({
    required String hint,
    required bool showError,
  }) {
    return InputDecoration(
      isDense: true,
      hintText: hint,
      hintStyle: TextStyle(
        color: showError ? AppColors.accentExpense : AppColors.textSecondary,
      ),
      border: InputBorder.none,
    );
  }

  void _openCurrencyPicker(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return CurrencyPickerSheet(
          selectedCode: appState.currencyCode,
          onSelected: (code) {
            appState.setCurrency(code);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  void _openCreateFamily(BuildContext context, AppState appState) {
    final controller = TextEditingController(text: '');
    final nameController = TextEditingController(
      text: _memberNameController.text,
    );
    var showErrors = false;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void refresh() => setModalState(() {});
            final budgetError = showErrors && controller.text.trim().isEmpty;
            final nameError =
                showErrors &&
                (nameController.text.trim().isEmpty ||
                    nameController.text.trim().toLowerCase() == 'я');
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Создать общий бюджет',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SoftCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 130,
                            child: Text(
                              'Название',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: controller,
                              decoration: _inlineInputDecoration(
                                hint: 'Название бюджета',
                                showError: budgetError,
                              ),
                              onChanged: (_) => refresh(),
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
                      child: Row(
                        children: [
                          SizedBox(
                            width: 130,
                            child: Text(
                              'Ваше имя',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: nameController,
                              decoration: _inlineInputDecoration(
                                hint: 'Ваше имя',
                                showError: nameError,
                              ),
                              onChanged: (_) => refresh(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          showErrors = true;
                          refresh();
                          if (controller.text.trim().isEmpty ||
                              nameController.text.trim().isEmpty ||
                              nameController.text.trim().toLowerCase() == 'я') {
                            return;
                          }
                          Navigator.of(context).pop();
                          await appState.updateDisplayName(nameController.text);
                          await appState.createFamily(controller.text);
                        },
                        child: const Text('Создать'),
                      ),
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

  void _openJoinFamily(BuildContext context, AppState appState) {
    final controller = TextEditingController();
    final nameController = TextEditingController(
      text: _memberNameController.text,
    );
    var showErrors = false;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void refresh() => setModalState(() {});
            final codeError = showErrors && controller.text.trim().isEmpty;
            final nameError =
                showErrors &&
                (nameController.text.trim().isEmpty ||
                    nameController.text.trim().toLowerCase() == 'я');
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Присоединиться по коду',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SoftCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 130,
                            child: Text(
                              'Код бюджета',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: controller,
                              textCapitalization: TextCapitalization.characters,
                              decoration: _inlineInputDecoration(
                                hint: 'Код бюджета',
                                showError: codeError,
                              ),
                              onChanged: (_) => refresh(),
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
                      child: Row(
                        children: [
                          SizedBox(
                            width: 130,
                            child: Text(
                              'Ваше имя',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: nameController,
                              decoration: _inlineInputDecoration(
                                hint: 'Ваше имя',
                                showError: nameError,
                              ),
                              onChanged: (_) => refresh(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          showErrors = true;
                          refresh();
                          if (controller.text.trim().isEmpty ||
                              nameController.text.trim().isEmpty ||
                              nameController.text.trim().toLowerCase() == 'я') {
                            return;
                          }
                          Navigator.of(context).pop();
                          await appState.updateDisplayName(nameController.text);
                          final success = await appState.joinFamily(
                            controller.text,
                          );
                          if (!context.mounted) {
                            return;
                          }
                          if (!success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Код не найден')),
                            );
                          }
                        },
                        child: const Text('Присоединиться'),
                      ),
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

  Future<void> _selectFamilyBudget(AppState appState) async {
    final families = appState.availableFamilies;
    if (families.isEmpty) {
      return;
    }
    if (families.length == 1) {
      await appState.switchToFamilyBudget(families.first.id);
      return;
    }
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
                ...families.map((family) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SoftCard(
                      child: ListTile(
                        title: Text(family.name),
                        subtitle: Text(family.inviteCode),
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

  Future<void> _confirmLeaveFamily(
    BuildContext context,
    AppState appState,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Покинуть общий бюджет?'),
          content: const Text('Вы уверены, что хотите выйти?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Выйти'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await appState.leaveFamily();
    }
  }

  Future<void> _confirmClearTransactions(
    BuildContext context,
    AppState appState,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Очистить операции?'),
          content: const Text('Все операции будут удалены без восстановления.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Очистить'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await appState.clearTransactions();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Операции очищены')));
    }
  }

  Future<void> _confirmResetAccount(
    BuildContext context,
    AppState appState,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Сбросить приложение?'),
          content: const Text(
            'Будет создан новый аккаунт и новый личный бюджет. '
            'Старые данные останутся в облаке, но будут недоступны.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Сбросить'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await appState.resetAccount();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Аккаунт сброшен')));
    }
  }

  Future<void> _onBudgetModeChanged(AppState appState, _BudgetMode mode) async {
    if (mode == _BudgetMode.personal) {
      if (!appState.isFamilyMode) {
        return;
      }
      await appState.switchToPersonalBudget();
      return;
    }
    if (appState.availableFamilies.isEmpty) {
      return;
    }
    await _selectFamilyBudget(appState);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    final appState = AppStateScope.of(context);
    _memberNameController.text = appState.currentUser.name;
    _familyNameController.text = appState.family?.name ?? '';
    _initialized = true;
  }

  @override
  void dispose() {
    _memberNameController.dispose();
    _familyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final family = appState.family;
    final hasFamilyOption = appState.availableFamilies.isNotEmpty;
    final activeMode = appState.isFamilyMode
        ? _BudgetMode.family
        : _BudgetMode.personal;
    final familyLabel = appState.isFamilyMode
        ? (family?.name ?? 'Общий бюджет')
        : (hasFamilyOption
              ? appState.availableFamilies.first.name
              : 'Общий бюджет');
    if (family != null) {
      if (!_familyNameDirty &&
          _familyNameController.text.trim() != family.name.trim()) {
        _familyNameController.text = family.name;
      }
      if (!_memberNameDirty &&
          _memberNameController.text.trim() !=
              appState.currentUser.name.trim()) {
        _memberNameController.text = appState.currentUser.name;
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'Настройки'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Общий бюджет',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        _SettingsRow(
                          title: 'Режим',
                          value: appState.isFamilyMode ? 'Общий' : 'Личный',
                        ),
                        const SizedBox(height: 12),
                        SegmentedButton<_BudgetMode>(
                          segments: [
                            const ButtonSegment(
                              value: _BudgetMode.personal,
                              label: Text('Личный'),
                            ),
                            ButtonSegment(
                              value: _BudgetMode.family,
                              label: Text(familyLabel),
                              enabled: hasFamilyOption,
                            ),
                          ],
                          selected: {activeMode},
                          onSelectionChanged: (selection) {
                            _onBudgetModeChanged(appState, selection.first);
                          },
                          showSelectedIcon: false,
                        ),
                        if (family != null) ...[
                          const SizedBox(height: 12),
                          SoftCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 130,
                                  child: Text(
                                    'Название',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _familyNameController,
                                    decoration: _inlineInputDecoration(
                                      hint: 'Название бюджета',
                                      showError:
                                          _showFamilyErrors &&
                                          _familyNameController.text
                                              .trim()
                                              .isEmpty,
                                    ),
                                    onChanged: (_) {
                                      _familyNameDirty = true;
                                      if (_showFamilyErrors) {
                                        setState(() {});
                                      }
                                    },
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
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 130,
                                  child: Text(
                                    'Ваше имя',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _memberNameController,
                                    decoration: _inlineInputDecoration(
                                      hint: 'Ваше имя',
                                      showError:
                                          _showFamilyErrors &&
                                          (_memberNameController.text
                                                  .trim()
                                                  .isEmpty ||
                                              _memberNameController.text
                                                      .trim()
                                                      .toLowerCase() ==
                                                  'я'),
                                    ),
                                    onChanged: (_) {
                                      _memberNameDirty = true;
                                      if (_showFamilyErrors) {
                                        setState(() {});
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () async {
                                if (!_validateFamilyForm()) {
                                  return;
                                }
                                if (_familyNameDirty) {
                                  await appState.updateFamilyName(
                                    _familyNameController.text,
                                  );
                                  _familyNameDirty = false;
                                }
                                if (_memberNameDirty) {
                                  await appState.updateDisplayName(
                                    _memberNameController.text,
                                  );
                                  _memberNameDirty = false;
                                }
                                if (!context.mounted) {
                                  return;
                                }
                                setState(() {
                                  _showFamilyErrors = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Изменения сохранены'),
                                  ),
                                );
                              },
                              child: const Text('Применить изменения'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _SettingsRow(
                            title: 'Код',
                            value: family.inviteCode,
                            trailing: IconButton(
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: family.inviteCode),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Код скопирован'),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.copy_rounded,
                                size: 18,
                                color: AppColors.textSecondary,
                              ),
                              tooltip: 'Скопировать код',
                            ),
                          ),
                          if (appState.familyMembers.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Участники',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: appState.familyMembers.map((member) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface2,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    member.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                        const SizedBox(height: 16),
                        if (family == null) ...[
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () =>
                                  _openCreateFamily(context, appState),
                              child: const Text('Создать общий бюджет'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () =>
                                  _openJoinFamily(context, appState),
                              child: const Text('Присоединиться по коду'),
                            ),
                          ),
                        ] else ...[
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () =>
                                  _confirmLeaveFamily(context, appState),
                              child: const Text('Покинуть общий бюджет'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SoftCard(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () => _openCurrencyPicker(context, appState),
                          borderRadius: BorderRadius.circular(16),
                          child: _SettingsRow(
                            title: 'Валюта',
                            value: appState.currencyCode ?? 'Не выбрана',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _SettingsRow(
                          title: 'Синхронизация',
                          value: appState.syncEnabled
                              ? 'Включена'
                              : 'Выключена',
                        ),
                        const SizedBox(height: 12),
                        const _SettingsRow(title: 'Тема', value: 'Темная'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Данные',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () =>
                                _confirmClearTransactions(context, appState),
                            child: const Text('Очистить операции'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () =>
                                _confirmResetAccount(context, appState),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.accentExpense,
                            ),
                            child: const Text('Сбросить и начать заново'),
                          ),
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

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.title, this.value, this.trailing});

  final String title;
  final String? value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          value ?? '—',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        if (trailing != null) ...[const SizedBox(width: 6), trailing!],
      ],
    );
  }
}
