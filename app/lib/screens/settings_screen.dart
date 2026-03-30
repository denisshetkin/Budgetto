import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../services/transaction_import.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/app_header.dart';
import '../widgets/soft_card.dart';
import 'budgets_screen.dart';
import 'cards_screen.dart';
import 'categories_screen.dart';
import 'subscription_screen.dart';
import 'tags_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(CupertinoPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AppHeader(
              title: 'Настройки',
              padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
              leading: canPop
                  ? IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                    )
                  : Icon(Icons.settings, size: 32, color: AppColors.chipBlue),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  _SettingsMenuItem(
                    icon: Icons.workspace_premium_outlined,
                    title: 'Premium',
                    subtitle: 'Подписка и доступ к приложению',
                    value: appState.accessStatusLabel,
                    iconColor: AppColors.accentTotal,
                    onTap: () =>
                        _openScreen(context, const SubscriptionScreen()),
                  ),
                  const SizedBox(height: 8),
                  _SettingsMenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Бюджеты',
                    subtitle: 'Лимиты и цели по категориям',
                    iconColor: AppColors.accentTotal,
                    onTap: () => _openScreen(context, const BudgetsScreen()),
                  ),
                  const SizedBox(height: 8),
                  _SettingsMenuItem(
                    icon: Icons.credit_card_outlined,
                    title: 'Способы оплаты',
                    subtitle: 'Карты и счета для операций',
                    iconColor: AppColors.chipBlue,
                    onTap: () => _openScreen(context, const CardsScreen()),
                  ),
                  const SizedBox(height: 8),
                  _SettingsMenuItem(
                    icon: Icons.category_outlined,
                    title: 'Категории',
                    subtitle: 'Редактировать список категорий',
                    iconColor: AppColors.categoryPalette[4],
                    onTap: () => _openScreen(context, const CategoriesScreen()),
                  ),
                  const SizedBox(height: 8),
                  _SettingsMenuItem(
                    icon: Icons.sell_outlined,
                    title: 'Теги',
                    subtitle: 'Добавить и переименовать теги',
                    iconColor: AppColors.categoryPalette[7],
                    onTap: () => _openScreen(context, const TagsScreen()),
                  ),
                  const SizedBox(height: 8),
                  _SettingsMenuItem(
                    icon: Icons.currency_exchange_outlined,
                    title: 'Валюта',
                    subtitle: 'Валюта отображения суммы',
                    value: appState.currencyCode ?? 'Не выбрана',
                    iconColor: AppColors.accentDisplay,
                    onTap: () =>
                        _openScreen(context, const CurrencySettingsScreen()),
                  ),
                  const SizedBox(height: 8),
                  _SettingsMenuItem(
                    icon: Icons.dark_mode_outlined,
                    title: 'Тема',
                    subtitle: 'Темная или светлая тема',
                    value: appState.themeMode == ThemeMode.light
                        ? 'Светлая'
                        : 'Темная',
                    iconColor: AppColors.accentNeutral,
                    onTap: () =>
                        _openScreen(context, const ThemeSettingsScreen()),
                  ),
                  const SizedBox(height: 8),
                  _SettingsMenuItem(
                    icon: Icons.sync_rounded,
                    title: 'Синхронизация',
                    subtitle: 'Вход и перенос прогресса',
                    iconColor: AppColors.accentDisplay,
                    onTap: () =>
                        _openScreen(context, const SyncSettingsScreen()),
                  ),
                  const SizedBox(height: 8),
                  _SettingsMenuItem(
                    icon: Icons.storage_outlined,
                    title: 'Данные',
                    subtitle: 'Импорт затрат из CSV',
                    iconColor: AppColors.accentExpense,
                    onTap: () =>
                        _openScreen(context, const DataSettingsScreen()),
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

class _SettingsMenuItem extends StatelessWidget {
  const _SettingsMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.value,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.stroke, width: 1),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor ?? AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: 8),
                Text(
                  value!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class CurrencySettingsScreen extends StatelessWidget {
  const CurrencySettingsScreen({super.key});

  static const List<Map<String, String>> _currencies = [
    {'code': 'USD', 'name': 'Доллар США'},
    {'code': 'EUR', 'name': 'Евро'},
    {'code': 'GBP', 'name': 'Фунт стерлингов'},
    {'code': 'UAH', 'name': 'Гривна'},
    {'code': 'JPY', 'name': 'Йена'},
    {'code': 'RUB', 'name': 'Рубль'},
  ];

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AppHeader(
              title: 'Валюта',
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: _currencies.map((currency) {
                  final code = currency['code']!;
                  final name = currency['name']!;
                  final isSelected = code == appState.currencyCode;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SoftCard(
                      padding: EdgeInsets.zero,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => appState.setCurrency(code),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              Text(
                                code,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: isSelected
                                    ? AppColors.accentIncome
                                    : AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AppHeader(
              title: 'Тема',
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Оформление',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        SegmentedButton<ThemeMode>(
                          segments: const [
                            ButtonSegment(
                              value: ThemeMode.dark,
                              label: Text('Темная'),
                            ),
                            ButtonSegment(
                              value: ThemeMode.light,
                              label: Text('Светлая'),
                            ),
                          ],
                          selected: {appState.themeMode},
                          onSelectionChanged: (selection) {
                            appState.setThemeMode(selection.first);
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Тема влияет на фон, карточки и оттенки интерфейса.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
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

class SyncSettingsScreen extends StatelessWidget {
  const SyncSettingsScreen({super.key});

  Future<void> _connectGoogle(BuildContext context, AppState appState) async {
    try {
      final connected = await appState.signInWithGoogle();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(connected ? 'Google подключен' : 'Вход отменен'),
        ),
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось подключить Google')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final status = appState.syncEnabled ? 'Включена' : 'Выключена';
    final statusColor = appState.syncEnabled
        ? AppColors.accentDisplay
        : AppColors.textSecondary;
    final isGoogle = appState.isGoogleSignedIn;
    final email = appState.currentUserEmail ?? '';
    final accountStatus = isGoogle ? 'Google подключен' : 'Гость';
    final accountStatusColor = isGoogle
        ? AppColors.accentDisplay
        : AppColors.textSecondary;

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AppHeader(
              title: 'Синхронизация',
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Аккаунт',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Статус',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              accountStatus,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: accountStatusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        if (email.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            email,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: isGoogle
                                ? null
                                : () => _connectGoogle(context, appState),
                            child: Text(
                              isGoogle
                                  ? 'Google подключен'
                                  : 'Войти через Google',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Подключи Google, чтобы переносить прогресс между устройствами.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Статус',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Синхронизация данных',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              status,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Синхронизация нужна для хранения данных в облаке и совместного бюджета.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
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

class DataSettingsScreen extends StatefulWidget {
  const DataSettingsScreen({super.key});

  @override
  State<DataSettingsScreen> createState() => _DataSettingsScreenState();
}

class _DataSettingsScreenState extends State<DataSettingsScreen> {
  bool _importBusy = false;

  Future<void> _pickAndImportCsv(AppState appState) async {
    if (_importBusy) {
      return;
    }

    setState(() {
      _importBusy = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['csv'],
        withData: true,
        withReadStream: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      if (!mounted) {
        return;
      }

      final file = result.files.single;
      final bytes = file.bytes ?? await _readFileBytes(file.readStream);
      if (bytes == null) {
        _showMessage('Не удалось прочитать выбранный файл.');
        return;
      }

      final csvContent = utf8.decode(bytes, allowMalformed: true);
      final preview = TransactionImportService.analyzeCsv(
        csvContent: csvContent,
        existingCategoryNames: appState.categories.map((item) => item.name),
        existingPaymentMethodNames: appState.paymentMethods.map(
          (item) => item.name,
        ),
        existingTagNames: appState.tags.map((item) => item.name),
        sourceName: file.name,
      );

      if (!mounted) {
        return;
      }

      if (preview.hasErrors) {
        await _showImportErrors(preview);
        return;
      }

      await _confirmImportPreview(appState, preview);
    } catch (error) {
      if (mounted) {
        _showMessage('Импорт не удался: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _importBusy = false;
        });
      }
    }
  }

  Future<void> _showImportErrors(TransactionImportPreview preview) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Исправь ошибки в CSV'),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    preview.sourceName == null
                        ? 'Файл не прошёл валидацию.'
                        : 'Файл "${preview.sourceName}" не прошёл валидацию.',
                  ),
                  const SizedBox(height: 12),
                  ...preview.errors.map(
                    (issue) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('• ${issue.displayMessage}'),
                    ),
                  ),
                ],
              ),
            ),
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
  }

  Future<void> _confirmImportPreview(
    AppState appState,
    TransactionImportPreview preview,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Подтвердить импорт'),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (preview.sourceName != null) ...[
                    Text('Файл: ${preview.sourceName}'),
                    const SizedBox(height: 12),
                  ],
                  Text('Будет добавлено записей: ${preview.rows.length}'),
                  const SizedBox(height: 8),
                  _PreviewList(
                    title: 'Новые категории',
                    items: preview.newCategoryNames,
                  ),
                  const SizedBox(height: 12),
                  _PreviewList(
                    title: 'Новые способы оплаты',
                    items: preview.newPaymentMethodNames,
                  ),
                  const SizedBox(height: 12),
                  _PreviewList(title: 'Новые теги', items: preview.newTagNames),
                  const SizedBox(height: 12),
                  const Text(
                    'Новые категории, способы оплаты, теги и сами записи будут добавлены только после нажатия кнопки "Импортировать".',
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Все импортированные записи также получат системный тег импорта, чтобы их можно было быстро отфильтровать и удалить.',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Импортировать'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final result = TransactionImportService.commitImport(
      appState: appState,
      preview: preview,
    );

    _showMessage(
      'Импортировано ${result.addedTransactions} записей. '
      'Тег: ${result.importTagName}.',
    );
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<Uint8List?> _readFileBytes(Stream<List<int>>? stream) async {
    if (stream == null) {
      return null;
    }
    final builder = BytesBuilder(copy: false);
    await for (final chunk in stream) {
      builder.add(chunk);
    }
    final bytes = builder.takeBytes();
    if (bytes.isEmpty) {
      return null;
    }
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final instructionSections =
        TransactionImportService.buildInstructionSections();

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            AppHeader(
              title: 'Импорт затрат',
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Импорт затрат из CSV',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(
                          instructionSections.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _InstructionSection(
                              number: index + 1,
                              section: instructionSections[index],
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.stroke.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.stroke.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Пример данных в документе',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              SelectableText(
                                TransactionImportService.sampleCsv(),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontFamily: 'monospace',
                                      color: AppColors.textSecondary,
                                      height: 1.5,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _importBusy
                                ? null
                                : () => _pickAndImportCsv(appState),
                            icon: _importBusy
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.upload_file_rounded),
                            label: Text(
                              _importBusy
                                  ? 'Проверяем CSV...'
                                  : 'Выбрать CSV и проверить',
                            ),
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

class _InstructionSection extends StatelessWidget {
  const _InstructionSection({required this.number, required this.section});

  final int number;
  final TransactionImportInstructionSection section;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.chipBlue.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            '$number',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...section.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('•', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(height: 1.45),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviewList extends StatelessWidget {
  const _PreviewList({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title: ${items.length}'),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('• $item'),
            ),
          ),
        ],
      ],
    );
  }
}
