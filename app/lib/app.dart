import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/app_shell.dart';
import 'screens/subscription_screen.dart';
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
    GoogleFonts.config.allowRuntimeFetching = false;
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    if (mounted) {
      setState(() {
        _fontsReady = true;
      });
    }
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
                ? (_appState.isAccessLocked
                      ? const SubscriptionScreen()
                      : const AppShell())
                : (_fontsReady ? const _SplashScreen() : const _BlankScreen()),
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
    return const Scaffold(body: SizedBox.expand());
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),
            Text(
              'Budgetto',
              style: TextStyle(
                fontFamily: 'Sacramento',
                fontSize: 64,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
            const Spacer(flex: 4),
            Padding(
              padding: const EdgeInsets.fromLTRB(48, 0, 48, 32),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  color: colorScheme.primary,
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
