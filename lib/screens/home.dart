import 'dart:async';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import '../l10n/app_strings.dart';
import '../models/location_model.dart';
import '../models/solar_forecast.dart';
import '../services/history_service.dart';
import '../services/location_preferences.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/weather_service.dart';
import 'dashboard_screen.dart';
import 'forecast_screen.dart';
import 'notification_banner.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

class CerShell extends StatefulWidget {
  const CerShell({
    super.key,
    required this.locale,
    required this.themeMode,
    required this.onLocaleToggle,
    required this.onThemeModeChanged,
  });

  final Locale locale;
  final ThemeMode themeMode;
  final VoidCallback onLocaleToggle;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<CerShell> createState() => _CerShellState();
}

class _CerShellState extends State<CerShell> {
  final TextEditingController cityController = TextEditingController(
    text: 'Bologna',
  );
  final LocationService locationService = LocationService();
  final WeatherService weatherService = WeatherService();
  final HistoryService historyService = HistoryService();

  Timer? refreshTimer;
  Timer? statusTimer;
  SolarForecast? forecast;
  SolarForecast? tomorrowForecast;
  bool loading = false;
  String? errorMessage;
  DateTime? lastUpdated;
  int selectedIndex = 0;

  // Stato banner in-app
  BannerData? _activeBanner;
  bool _windowStartNotified = false;
  bool _windowEndNotified = false;

  // Controller per scroll al top
  final ScrollController _dashboardScrollController = ScrollController();
  final ScrollController _forecastScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadInitialLocation();
    refreshTimer = Timer.periodic(
      const Duration(minutes: 30),
      (_) => loadForecast(silent: true),
    );
    statusTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkProductionStatus(),
    );
  }

  Future<void> _loadInitialLocation() async {
    final prefs = LocationPreferences();
    final saved = await prefs.load();
    if (saved != null) {
      cityController.text = saved.displayName;
    }
    unawaited(loadForecast());
  }

  Future<void> _initNotifications() async {
    await NotificationService.instance.initialize();
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    statusTimer?.cancel();
    cityController.dispose();
    _dashboardScrollController.dispose();
    _forecastScrollController.dispose();
    super.dispose();
  }

  Future<void> loadForecast({bool silent = false}) async {
    final text = cityController.text.trim();
    if (text.isEmpty) {
      setState(() { forecast = null; tomorrowForecast = null; errorMessage = null; lastUpdated = null; });
      return;
    }
    if (!silent) {
      setState(() { loading = true; errorMessage = null; });
    }

    try {
      final prefs = LocationPreferences();
      final saved = await prefs.load();
      
      late final LocationModel location;
      if (saved != null && saved.displayName == text) {
        // Usa le coordinate salvate per bypassare la rete (utile offline).
        location = LocationModel(
          lat: saved.lat,
          lon: saved.lon,
          name: saved.city,
          country: saved.country,
          detail: saved.detail,
        );
      } else {
        location = await locationService.getCoordinates(
          text, locale: widget.locale,
        );
      }

      final result48 = await weatherService.fetchForecast(
        lat: location.lat, lon: location.lon,
        locationName: location.name,
        locationDetail: location.detail,
        country: location.country,
        forecastHours: 48,
      );

      final result24 = await weatherService.fetchForecast(
        lat: location.lat, lon: location.lon,
        locationName: location.name,
        locationDetail: location.detail,
        country: location.country,
        forecastHours: 24,
      );

      if (!mounted) return;

      // Filtra le finestre del giorno successivo.
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
      final tomorrowWindows = result48.windows.where((w) =>
        w.start.year == tomorrowDate.year &&
        w.start.month == tomorrowDate.month &&
        w.start.day == tomorrowDate.day
      ).toList();

      SolarForecast? tmrw;
      if (tomorrowWindows.isNotEmpty) {
        tmrw = SolarForecast(
          locationName: result48.locationName,
          locationDetail: result48.locationDetail,
          country: result48.country,
          slots: result48.slots.where((s) =>
            s.time.year == tomorrowDate.year &&
            s.time.month == tomorrowDate.month &&
            s.time.day == tomorrowDate.day
          ).toList(),
          windows: tomorrowWindows,
          bestWindow: tomorrowWindows.first,
          bestSlot: null,
        );
      }

      setState(() {
        forecast = result24;
        tomorrowForecast = tmrw;
        loading = false;
        lastUpdated = DateTime.now();
        errorMessage = null;
        _windowStartNotified = false;
        _windowEndNotified = false;
      });

      // Salva nello storico locale (punto 4.1).
      await historyService.recordToday(result24);

      // Aggiorna il widget della home screen.
      await _updateHomeWidget(result24);

      // Programma le notifiche push.
      final strings = AppStrings.of(context);
      await NotificationService.instance.scheduleFromForecast(
        forecast: result24,
        tomorrowForecast: tmrw,
        isItalian: strings.isItalian,
      );

      if (!silent && mounted) {
        final message = result24.bestWindow == null
            ? strings.noDaylightBody
            : strings.windowAlert(
                _formatTime(result24.bestWindow!.start),
                _formatTime(result24.bestWindow!.end),
              );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        loading = false;
        errorMessage = error.toString().replaceFirst('Exception: ', '');
        if (!silent) { forecast = null; tomorrowForecast = null; }
      });
    }
  }

  /// Aggiorna il widget Android della schermata home, solo se la località corrisponde a quella salvata.
  Future<void> _updateHomeWidget(SolarForecast f) async {
    final prefs = LocationPreferences();
    final saved = await prefs.load();
    
    // Se l'utente ha salvato una località, il widget mostra SOLO quella località.
    if (saved != null && f.locationLabel != saved.displayName) {
      return;
    }

    try {
      final best = f.bestWindow;
      final windowText = best != null
          ? '${_formatTime(best.start)} – ${_formatTime(best.end)}'
          : '--:-- – --:--';
      final radiationText = best != null
          ? '${best.averageRadiation.toStringAsFixed(0)} W/m²'
          : '';

      await HomeWidget.saveWidgetData('window_text', windowText);
      await HomeWidget.saveWidgetData('radiation_text', radiationText);
      await HomeWidget.saveWidgetData('location_text', f.locationLabel);
      await HomeWidget.updateWidget(
        androidName: 'SolarWidgetProvider',
        iOSName: 'SolarWidget',
      );
    } catch (_) {
      // Il widget potrebbe non essere supportato su questa piattaforma.
    }
  }

  void _checkProductionStatus() {
    if (forecast == null || !mounted) return;
    final now = DateTime.now();
    final best = forecast!.bestWindow;
    if (best == null) return;

    final strings = AppStrings.of(context);

    if (!_windowStartNotified &&
        !now.isBefore(best.start) &&
        now.isBefore(best.start.add(const Duration(minutes: 5)))) {
      _windowStartNotified = true;
      setState(() {
        _activeBanner = BannerData(
          type: NotificationBannerType.windowStarted,
          title: strings.windowStartedTitle,
          body: strings.windowStartedBody,
        );
      });
    }

    if (!_windowEndNotified &&
        !now.isBefore(best.end.subtract(const Duration(minutes: 15))) &&
        now.isBefore(best.end)) {
      _windowEndNotified = true;
      setState(() {
        _activeBanner = BannerData(
          type: NotificationBannerType.windowEnding,
          title: strings.windowEndingTitle,
          body: strings.windowEndingBody,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: selectedIndex == 0 
          ? Text('Home', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)) 
          : null,
        actions: [
          TextButton(
            onPressed: widget.onLocaleToggle,
            child: Text(widget.locale.languageCode == 'it' ? 'EN' : 'IT'),
          ),
          IconButton(
            icon: Icon(switch (widget.themeMode) {
              ThemeMode.dark => Icons.light_mode_outlined,
              ThemeMode.light => Icons.dark_mode_outlined,
              ThemeMode.system => Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            }),
            onPressed: () {
              // Se è system, controlla la luminosità effettiva per capire dove andare
              final ThemeMode newMode;
              if (widget.themeMode == ThemeMode.system) {
                newMode = Theme.of(context).brightness == Brightness.dark
                    ? ThemeMode.light
                    : ThemeMode.dark;
              } else {
                newMode = widget.themeMode == ThemeMode.dark
                    ? ThemeMode.light
                    : ThemeMode.dark;
              }
              widget.onThemeModeChanged(newMode);
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          DashboardScreen(
            scrollController: _dashboardScrollController,
            cityController: cityController,
            forecast: forecast,
            tomorrowForecast: tomorrowForecast,
            loading: loading,
            errorMessage: errorMessage,
            lastUpdated: lastUpdated,
            onSearch: () => loadForecast(),
            onOpenForecast: () { setState(() { selectedIndex = 1; }); },
            activeBanner: _activeBanner,
            onDismissBanner: () { setState(() { _activeBanner = null; }); },
          ),
          ForecastScreen(
            scrollController: _forecastScrollController,
            forecast: forecast,
            loading: loading,
            errorMessage: errorMessage,
            onOpenDashboard: () { setState(() { selectedIndex = 0; }); },
          ),
          const StatisticsScreen(),
          SettingsScreen(
            locale: widget.locale,
            themeMode: widget.themeMode,
            onLocaleToggle: widget.onLocaleToggle,
            onThemeModeChanged: widget.onThemeModeChanged,
            onLocationChanged: _loadInitialLocation,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          if (index == selectedIndex) {
            // Se l'utente clicca di nuovo la tab corrente, scorri verso l'alto
            if (index == 0 && _dashboardScrollController.hasClients) {
              _dashboardScrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
            } else if (index == 1 && _forecastScrollController.hasClients) {
              _forecastScrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
            }
          } else {
            setState(() { selectedIndex = index; });
          }
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: strings.navDashboard),
          NavigationDestination(icon: const Icon(Icons.wb_sunny_outlined), selectedIcon: const Icon(Icons.wb_sunny), label: strings.navForecast),
          NavigationDestination(icon: const Icon(Icons.bar_chart_outlined), selectedIcon: const Icon(Icons.bar_chart), label: strings.navStatistics),
          NavigationDestination(icon: const Icon(Icons.settings_outlined), selectedIcon: const Icon(Icons.settings), label: strings.navSettings),
        ],
      ),
    );
  }
}

String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
