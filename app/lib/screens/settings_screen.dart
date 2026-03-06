import 'package:flutter/material.dart';

import 'cards_screen.dart';
import 'categories_screen.dart';
import 'reminders_screen.dart';
import 'tags_screen.dart';
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
  void _openCategories(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CategoriesScreen()),
    );
  }

  void _openTags(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TagsScreen()),
    );
  }

  void _openPaymentMethods(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CardsScreen()),
    );
  }

  void _openReminders(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RemindersScreen()),
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

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

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
                          'Справочники',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => _openCategories(context),
                          borderRadius: BorderRadius.circular(16),
                          child: const _SettingsRow(
                            title: 'Категории',
                            trailing: Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => _openTags(context),
                          borderRadius: BorderRadius.circular(16),
                          child: const _SettingsRow(
                            title: 'Теги',
                            trailing: Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => _openPaymentMethods(context),
                          borderRadius: BorderRadius.circular(16),
                          child: const _SettingsRow(
                            title: 'Способы оплаты',
                            trailing: Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSecondary,
                            ),
                          ),
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
                          'Планирование',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => _openReminders(context),
                          borderRadius: BorderRadius.circular(16),
                          child: const _SettingsRow(
                            title: 'Напоминания',
                            trailing: Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (appState.isFamilyMode) ...[
                    SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Уведомления',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Операции семьи',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium,
                                ),
                              ),
                              Switch(
                                value: appState.familyNotificationsEnabled,
                                onChanged: (value) {
                                  appState.setFamilyNotificationsEnabled(value);
                                },
                              ),
                            ],
                          ),
                          Text(
                            'Получать уведомления, когда участники семьи добавляют расходы',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
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
