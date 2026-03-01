import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/currency_picker_sheet.dart';
import 'cards_screen.dart';
import 'categories_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'transactions_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  bool _askedCurrency = false;

  final List<Widget> _screens = const [
    TransactionsScreen(),
    SearchScreen(),
    CategoriesScreen(),
    CardsScreen(),
    SettingsScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_askedCurrency) {
      return;
    }

    final appState = AppStateScope.of(context);
    if (appState.currencyCode == null) {
      _askedCurrency = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCurrencyPicker(appState);
      });
    }
  }

  void _showCurrencyPicker(AppState appState) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
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
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: 'Поиск',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view),
              label: 'Категории',
            ),
            NavigationDestination(
              icon: Icon(Icons.credit_card_outlined),
              selectedIcon: Icon(Icons.credit_card),
              label: 'Карты',
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
