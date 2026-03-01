import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/currency_picker_sheet.dart';
import '../widgets/soft_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _initialized = false;

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
    final controller = TextEditingController(
      text: appState.family?.name ?? 'Семейный бюджет',
    );
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Создать семейный бюджет',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Название бюджета',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      appState.createFamily(controller.text);
                      Navigator.of(context).pop();
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
  }

  void _openJoinFamily(BuildContext context, AppState appState) {
    final controller = TextEditingController();
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Вступить по коду',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(hintText: 'Код семьи'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      appState.joinFamily(controller.text);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Вступить'),
                  ),
                ),
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
          title: const Text('Покинуть семейный бюджет?'),
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
      appState.leaveFamily();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    final appState = AppStateScope.of(context);
    _nameController.text = appState.currentUser.name;
    _initialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final family = appState.family;

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
                      children: [
                        Text(
                          'Профиль',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(hintText: 'Имя'),
                          onChanged: (value) => appState.setUserName(value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Семейный бюджет',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        _SettingsRow(
                          title: 'Режим',
                          value: appState.isFamilyMode ? 'Семейный' : 'Личный',
                        ),
                        if (family != null) ...[
                          const SizedBox(height: 12),
                          _SettingsRow(title: 'Название', value: family.name),
                          const SizedBox(height: 12),
                          _SettingsRow(title: 'Код', value: family.inviteCode),
                        ],
                        const SizedBox(height: 16),
                        if (family == null) ...[
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () =>
                                  _openCreateFamily(context, appState),
                              child: const Text('Создать семейный бюджет'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () =>
                                  _openJoinFamily(context, appState),
                              child: const Text('Вступить по коду'),
                            ),
                          ),
                        ] else ...[
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () =>
                                  _confirmLeaveFamily(context, appState),
                              child: const Text('Покинуть семейный бюджет'),
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
  const _SettingsRow({required this.title, this.value});

  final String title;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value ?? '—',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
