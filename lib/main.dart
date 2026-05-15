import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_strings.dart';
import 'screens/home.dart';
import 'screens/splash_screen.dart';
import 'services/history_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  // Popola dati di esempio per la demo (solo al primo avvio).
  await HistoryService().seedSampleData();
  runApp(const CerApp());
}

class CerApp extends StatefulWidget {
  const CerApp({super.key});

  @override
  State<CerApp> createState() => _CerAppState();
}

class _CerAppState extends State<CerApp> {
  Locale _locale = const Locale('it');
  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;

  void _toggleLocale() {
    setState(() {
      _locale = _locale.languageCode == 'it'
          ? const Locale('en')
          : const Locale('it');
    });
  }

  void _setThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(
              mediaQuery.textScaler.scale(1.05),
            ),
          ),
          child: child!,
        );
      },
      locale: _locale,
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: const [
        AppStrings.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      themeMode: _themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: _isInitialized
          ? CerShell(
              locale: _locale,
              themeMode: _themeMode,
              onLocaleToggle: _toggleLocale,
              onThemeModeChanged: _setThemeMode,
            )
          : SplashScreen(
              onInitializationComplete: () {
                setState(() {
                  _isInitialized = true;
                });
              },
            ),
    );
  }
}
