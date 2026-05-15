import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/solar_forecast.dart';

/// Servizio singleton per la gestione delle notifiche locali.
///
/// Gestisce sia le notifiche push programmate (che funzionano anche
/// con l'app chiusa) sia le notifiche in-app (banner e overlay).
class NotificationService {
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// ID univoci per le notifiche programmate.
  static const int _windowStartId = 1001;
  static const int _windowEndId = 1002;
  static const int _eveningReminderId = 1003;
  static const int _applianceReminderId = 1004;

  /// Canale Android per le notifiche solari.
  static const AndroidNotificationChannel _solarChannel =
      AndroidNotificationChannel(
    'cer_solar_channel',
    'Produzione solare',
    description: 'Notifiche sulle fasce di alta produzione solare',
    importance: Importance.high,
  );

  /// Inizializza il plugin di notifiche locali e il timezone.
  /// Deve essere chiamato una sola volta all'avvio dell'app.
  Future<void> initialize() async {
    if (_initialized) return;

    // Inizializza il database dei fusi orari.
    tz.initializeTimeZones();
    try {
      final dynamic localTz = await FlutterTimezone.getLocalTimezone();
      final String tzName = localTz is String ? localTz : localTz.name;
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (_) {
      // Se fallisce, usiamo UTC come fallback
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const linuxSettings =
        LinuxInitializationSettings(defaultActionName: 'Apri');

    // Su Windows e Web le notifiche locali richiedono configurazioni extra 
    // o non sono supportate da questo plugin. Saltiamo per evitare crash in dev.
    if (kIsWeb || Platform.isWindows) {
      _initialized = true;
      return;
    }

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    await _plugin.initialize(settings);

    // Crea il canale Android (idempotente).
    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(_solarChannel);
        // Richiedi il permesso per le notifiche (Android 13+).
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
      }
    }

    _initialized = true;
  }

  /// Cancella tutte le notifiche programmate in precedenza.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Programma le notifiche relative alla previsione solare:
  /// - Inizio della fascia migliore
  /// - Fine della fascia migliore
  /// - Suggerimento serale per il giorno dopo
  /// - Anticipo per elettrodomestici (la sera prima)
  Future<void> scheduleFromForecast({
    required SolarForecast forecast,
    required SolarForecast? tomorrowForecast,
    required bool isItalian,
  }) async {
    if (!_initialized) return;

    // Cancella le notifiche vecchie prima di riprogrammare.
    await cancelAll();

    final now = DateTime.now();

    // ── 1. Notifica all'INIZIO della finestra migliore ──
    final bestWindow = forecast.bestWindow;
    if (bestWindow != null && bestWindow.start.isAfter(now)) {
      await _scheduleNotification(
        id: _windowStartId,
        scheduledTime: bestWindow.start,
        title: isItalian
            ? '☀️ Fascia di alta produzione iniziata!'
            : '☀️ High production window started!',
        body: isItalian
            ? 'Avvia ora lavatrice, lavastoviglie o ricarica EV per massimizzare l\'autoconsumo.'
            : 'Start your washing machine, dishwasher or EV charger now to maximize self-consumption.',
      );
    }

    // ── 2. Notifica alla FINE della finestra migliore ──
    if (bestWindow != null && bestWindow.end.isAfter(now)) {
      // Notifica 15 minuti prima della fine.
      final endAlert = bestWindow.end.subtract(const Duration(minutes: 15));
      if (endAlert.isAfter(now)) {
        await _scheduleNotification(
          id: _windowEndId,
          scheduledTime: endAlert,
          title: isItalian
              ? '⏳ Fascia solare in chiusura tra 15 min'
              : '⏳ Solar window closing in 15 min',
          body: isItalian
              ? 'La fascia di alta produzione sta per terminare. Completa i consumi energivori.'
              : 'The high production window is about to end. Complete your heavy energy usage.',
        );
      }
    }

    // ── 3. Suggerimento SERALE per il giorno dopo ──
    if (tomorrowForecast != null && tomorrowForecast.bestWindow != null) {
      final tomorrowWindow = tomorrowForecast.bestWindow!;
      final startStr = _formatTime(tomorrowWindow.start);
      final endStr = _formatTime(tomorrowWindow.end);

      // Programma alle 20:00 di oggi (se non è già passato).
      final today = DateTime.now();
      var eveningTime = DateTime(today.year, today.month, today.day, 20, 0);

      // Se le 20:00 sono già passate, programma per domani sera.
      if (eveningTime.isBefore(now)) {
        eveningTime = eveningTime.add(const Duration(days: 1));
      }

      await _scheduleNotification(
        id: _eveningReminderId,
        scheduledTime: eveningTime,
        title: isItalian
            ? '🌅 Programma per domani!'
            : '🌅 Plan for tomorrow!',
        body: isItalian
            ? 'Domani il picco solare è previsto tra le $startStr e le $endStr. Programma lavatrice o lavastoviglie in anticipo!'
            : 'Tomorrow\'s solar peak is expected between $startStr and $endStr. Schedule laundry or dishwasher in advance!',
      );

      // ── 4. Promemoria ANTICIPO elettrodomestici (la sera prima) ──
      // Programma alle 21:00 come reminder addizionale.
      var applianceTime = DateTime(today.year, today.month, today.day, 21, 0);
      if (applianceTime.isBefore(now)) {
        applianceTime = applianceTime.add(const Duration(days: 1));
      }

      await _scheduleNotification(
        id: _applianceReminderId,
        scheduledTime: applianceTime,
        title: isItalian
            ? '🔌 Prepara gli elettrodomestici'
            : '🔌 Prepare your appliances',
        body: isItalian
            ? 'Carica la lavatrice/lavastoviglie stasera e programma l\'avvio per le $startStr di domani.'
            : 'Load your washer/dishwasher tonight and schedule the start for $startStr tomorrow.',
      );
    }
  }

  /// Programma una singola notifica locale a un orario specifico.
  Future<void> _scheduleNotification({
    required int id,
    required DateTime scheduledTime,
    required String title,
    required String body,
  }) async {
    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'cer_solar_channel',
      'Produzione solare',
      channelDescription: 'Notifiche sulle fasce di alta produzione solare',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'CER Smart',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: null,
    );
  }

  /// Mostra una notifica istantanea (utile per avvisi in-app immediati).
  Future<void> showInstant({
    required String title,
    required String body,
    int id = 0,
  }) async {
    if (!_initialized) return;

    const androidDetails = AndroidNotificationDetails(
      'cer_solar_channel',
      'Produzione solare',
      channelDescription: 'Notifiche sulle fasce di alta produzione solare',
      importance: Importance.high,
      priority: Priority.high,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _plugin.show(id, title, body, details);
  }

  /// Formatta un [DateTime] come "HH:mm".
  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
