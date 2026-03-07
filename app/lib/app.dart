import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/app_shell.dart';
import 'state/app_state.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

class SmartWalletApp extends StatefulWidget {
  const SmartWalletApp({super.key});

  @override
  State<SmartWalletApp> createState() => _SmartWalletAppState();
}

class _SmartWalletAppState extends State<SmartWalletApp> {
  final AppState _appState = AppState();
  bool _ready = false;
  bool _fontsReady = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final fontStyle = GoogleFonts.sacramento();
    await GoogleFonts.pendingFonts([fontStyle]);
    if (!mounted) {
      return;
    }
    setState(() {
      _fontsReady = true;
    });
    await _appState.initialize();
    if (!mounted) {
      return;
    }
    setState(() {
      _ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: _appState,
      child: AnimatedBuilder(
        animation: _appState,
        builder: (context, _) {
          AppColors.setThemeMode(_appState.themeMode);
          return MaterialApp(
            title: 'Budgetto',
            debugShowCheckedModeBanner: false,
            theme: buildLightTheme(),
            darkTheme: buildDarkTheme(),
            themeMode: _appState.themeMode,
            home: _ready
                ? const AppShell()
                : (_fontsReady
                    ? const _SplashScreen()
                    : const _BlankScreen()),
          );
        },
      ),
    );
  }
}

class _BlankScreen extends StatelessWidget {
  const _BlankScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.expand(),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Budgetto',
              style: GoogleFonts.sacramento(
                fontSize: 64,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
