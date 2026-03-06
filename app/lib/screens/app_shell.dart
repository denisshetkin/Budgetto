import 'package:flutter/material.dart';

import '../models/transaction_entry.dart';
import '../theme/app_colors.dart';
import 'add_transaction_screen.dart';
import 'budgets_screen.dart';
import 'planned_screen.dart';
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
    TransactionsScreen(),
    PlannedScreen(),
    BudgetsScreen(),
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
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTransaction,
        backgroundColor: AppColors.surface2,
        foregroundColor: AppColors.accentIncome,
        shape: CircleBorder(
          side: BorderSide(color: AppColors.accentIncome, width: 2),
        ),
        elevation: 2,
        heroTag: 'global_add_transaction',
        child: const Icon(Icons.add, size: 24),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface1,
          border: Border(top: BorderSide(color: AppColors.stroke, width: 1)),
        ),
        child: NavigationBar(
          height: 68,
          backgroundColor: AppColors.surface1,
          indicatorColor: AppColors.surface2,
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.swap_horiz),
              selectedIcon: Icon(Icons.swap_horiz),
              label: 'Операции',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_note_outlined),
              selectedIcon: Icon(Icons.event_note),
              label: 'Регулярные платежи',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet),
              label: 'Бюджеты',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Настройки',
            ),
          ],
        ),
      ),
    );
  }
}
