import 'package:flutter/material.dart';

import '../models/transaction_entry.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_icon.dart';
import 'add_transaction_screen.dart';
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
    PlannedScreen(),
    RemindersScreen(),
    SettingsScreen(),
  ];

  void _openAddTransaction() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddTransactionScreen(
          initialType: TransactionType.expense,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final navIndicator =
        Color.lerp(colorScheme.surface, colorScheme.primary, 0.18) ??
            colorScheme.surface;
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: Transform.scale(
        scale: 1.05,
        child: FloatingActionButton(
          onPressed: _openAddTransaction,
          backgroundColor:
              Color.lerp(colorScheme.surface, colorScheme.primary, 0.2),
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
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: theme.dividerColor, width: 1)),
        ),
        child: NavigationBarTheme(
          data: const NavigationBarThemeData(
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            overlayColor: WidgetStatePropertyAll(Colors.transparent),
          ),
          child: NavigationBar(
            height: 68,
            backgroundColor: colorScheme.surface,
            indicatorColor: Colors.transparent,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
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
                    Icons.event_note_outlined,
                    size: 30,
                    color: AppColors.accentTotal,
                  ),
                ),
                selectedIcon: _NavIcon(
                  backgroundColor: navIndicator,
                  selected: true,
                  icon: Icon(
                    Icons.event_note,
                    size: 30,
                    color: AppColors.accentTotal,
                  ),
                ),
                label: '',
              ),
              NavigationDestination(
                icon: _NavIcon(
                  backgroundColor: navIndicator,
                  icon: Icon(
                    Icons.notifications_outlined,
                    size: 30,
                    color: AppColors.accentDisplay,
                  ),
                ),
                selectedIcon: _NavIcon(
                  backgroundColor: navIndicator,
                  selected: true,
                  icon: Icon(
                    Icons.notifications,
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
                    Icons.settings_outlined,
                    size: 30,
                    color: AppColors.categoryPalette[5],
                  ),
                ),
                selectedIcon: _NavIcon(
                  backgroundColor: navIndicator,
                  selected: true,
                  icon: Icon(
                    Icons.settings,
                    size: 30,
                    color: AppColors.categoryPalette[5],
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
