import 'package:flutter/material.dart';

import '../models/transaction_entry.dart';
import '../services/data_export.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_icon.dart';
import 'add_transaction_screen.dart';
import 'lists_screen.dart';
import 'overview_screen.dart';
import 'planned_screen.dart';
import 'reminders_screen.dart';
import 'settings_screen.dart';
import 'transactions_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    OverviewScreen(),
    TransactionsScreen(),
    SizedBox.shrink(),
    SettingsScreen(),
  ];

  void _openAddTransaction() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            const AddTransactionScreen(initialType: TransactionType.expense),
      ),
    );
  }

  Future<void> _openMoreMenu() async {
    final appState = AppStateScope.of(context);
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.event_note_outlined,
                    color: AppColors.accentTotal,
                  ),
                  title: const Text('Регулярные платежи'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PlannedScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.notifications,
                    color: AppColors.accentDisplay,
                  ),
                  title: const Text('Напоминания'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RemindersScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.fact_check, color: AppColors.chipBlue),
                  title: const Text('Списки покупок'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ListsScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.file_download_outlined,
                    color: AppColors.accentDisplay,
                  ),
                  title: const Text('Импорт CSV'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DataSettingsScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.file_upload_outlined,
                    color: AppColors.accentTotal,
                  ),
                  title: const Text('Экспорт CSV'),
                  onTap: () {
                    Navigator.of(context).pop();
                    DataExport.exportTransactionsCsv(this.context, appState);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final chrome = AppColors.chrome;
    final navIndicator =
        Color.lerp(chrome, colorScheme.primary, 0.18) ?? chrome;
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: Transform.scale(
        scale: 1.05,
        child: FloatingActionButton(
          onPressed: _openAddTransaction,
          backgroundColor: Color.lerp(
            colorScheme.surface,
            colorScheme.primary,
            0.2,
          ),
          foregroundColor: colorScheme.primary,
          shape: CircleBorder(
            side: BorderSide(color: colorScheme.primary, width: 2.5),
          ),
          elevation: 3,
          heroTag: 'global_add_transaction',
          child: const Icon(Icons.add, size: 25),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: chrome,
          border: Border(top: BorderSide(color: theme.dividerColor, width: 1)),
        ),
        child: NavigationBarTheme(
          data: const NavigationBarThemeData(
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            overlayColor: WidgetStatePropertyAll(Colors.transparent),
          ),
          child: NavigationBar(
            height: 68,
            backgroundColor: chrome,
            indicatorColor: Colors.transparent,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              if (index == 2) {
                _openMoreMenu();
                return;
              }
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: [
              NavigationDestination(
                icon: _NavIcon(
                  backgroundColor: navIndicator,
                  icon: GradientIcon(
                    icon: Icons.pie_chart_outline,
                    size: 30,
                    colors: [
                      AppColors.accentIncome,
                      AppColors.accentTotal,
                      AppColors.accentExpense,
                    ],
                  ),
                ),
                selectedIcon: _NavIcon(
                  backgroundColor: navIndicator,
                  selected: true,
                  icon: GradientIcon(
                    icon: Icons.pie_chart,
                    size: 30,
                    colors: [
                      AppColors.accentIncome,
                      AppColors.accentTotal,
                      AppColors.accentExpense,
                    ],
                  ),
                ),
                label: '',
              ),
              NavigationDestination(
                icon: _NavIcon(
                  backgroundColor: navIndicator,
                  icon: Icon(
                    Icons.swap_horiz,
                    size: 30,
                    color: AppColors.accentExpense,
                  ),
                ),
                selectedIcon: _NavIcon(
                  backgroundColor: navIndicator,
                  selected: true,
                  icon: Icon(
                    Icons.swap_horiz,
                    size: 30,
                    color: AppColors.accentExpense,
                  ),
                ),
                label: '',
              ),
              NavigationDestination(
                icon: _NavIcon(
                  backgroundColor: navIndicator,
                  icon: Icon(
                    Icons.widgets_outlined,
                    size: 30,
                    color: AppColors.accentDisplay,
                  ),
                ),
                selectedIcon: _NavIcon(
                  backgroundColor: navIndicator,
                  selected: true,
                  icon: Icon(
                    Icons.widgets_rounded,
                    size: 30,
                    color: AppColors.accentDisplay,
                  ),
                ),
                label: '',
              ),
              NavigationDestination(
                icon: _NavIcon(
                  backgroundColor: navIndicator,
                  icon: Icon(
                    Icons.settings,
                    size: 32,
                    color: AppColors.accentNeutral,
                  ),
                ),
                selectedIcon: _NavIcon(
                  backgroundColor: navIndicator,
                  selected: true,
                  icon: Icon(
                    Icons.settings,
                    size: 32,
                    color: AppColors.accentNeutral,
                  ),
                ),
                label: '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.backgroundColor,
    this.selected = false,
  });

  final Widget icon;
  final Color backgroundColor;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (!selected) {
      return icon;
    }
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: icon,
    );
  }
}
