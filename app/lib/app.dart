import 'package:flutter/material.dart';

import 'screens/app_shell.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

class SmartWalletApp extends StatefulWidget {
  const SmartWalletApp({super.key});

  @override
  State<SmartWalletApp> createState() => _SmartWalletAppState();
}

class _SmartWalletAppState extends State<SmartWalletApp> {
  final AppState _appState = AppState();

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: _appState,
      child: MaterialApp(
        title: 'Smart Wallet',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const AppShell(),
      ),
    );
  }
}
