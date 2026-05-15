import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/solar_forecast.dart';

/// Servizio per il recupero delle previsioni meteo e solari
/// tramite l'API Open-Meteo (open source, senza chiave API).
class WeatherService {
  static const String _cacheKey = 'weather_forecast_cache';

  /// Recupera la previsione solare per le prossime [forecastHours] ore.
  /// Di default 24h, impostare 48 per ottenere anche il giorno successivo.
  Future<SolarForecast> fetchForecast({
    required double lat,
    required double lon,
    required String locationName,
    required String locationDetail,
    required String country,
    int forecastHours = 24,
  }) async {
    final url = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '$lat',
      'longitude': '$lon',
      'hourly': 'cloud_cover,shortwave_radiation',
      'daily': 'sunrise,sunset',
      'forecast_hours': '$forecastHours',
      'forecast_days': forecastHours > 24 ? '2' : '1',
      'timezone': 'auto',
    });

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Errore meteo');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, response.body);

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return _buildForecast(
        data: data,
        locationName: locationName,
        locationDetail: locationDetail,
        country: country,
        isOffline: false,
      );
    } catch (e) {
      // Fallback: carica dalla cache
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString(_cacheKey);
      if (cachedString != null) {
        final data = jsonDecode(cachedString) as Map<String, dynamic>;
        return _buildForecast(
          data: data,
          locationName: locationName,
          locationDetail: locationDetail,
          country: country,
          isOffline: true,
        );
      }
      rethrow;
    }
  }

  /// Costruisce un [SolarForecast] a partire dalla risposta JSON
  /// dell'API Open-Meteo.
  SolarForecast _buildForecast({
    required Map<String, dynamic> data,
    required String locationName,
    required String locationDetail,
    required String country,
    required bool isOffline,
  }) {
    final hourly = data['hourly'] as Map<String, dynamic>;
    final daily = data['daily'] as Map<String, dynamic>?;

    final times = (hourly['time'] as List<dynamic>)
        .map((value) => DateTime.parse(value as String))
        .toList();
    final cloudCover = (hourly['cloud_cover'] as List<dynamic>)
        .map((value) => (value as num).round())
        .toList();
    final radiation = (hourly['shortwave_radiation'] as List<dynamic>)
        .map((value) => (value as num).round())
        .toList();

    if (times.isEmpty || cloudCover.isEmpty || radiation.isEmpty) {
      throw Exception('Dati meteo non disponibili');
    }

    final slotCount = math.min(
      times.length,
      math.min(cloudCover.length, radiation.length),
    );
    final daylightByDate = _buildDaylightMap(daily);
    final slots = <SolarForecastSlot>[];

    for (var i = 0; i < slotCount; i++) {
      final time = times[i];
      final bounds = daylightByDate[_dateKey(time)];
      final isDaylight = bounds == null
          ? radiation[i] > 0
          : !time.isBefore(bounds.sunrise) && time.isBefore(bounds.sunset);

      slots.add(
        SolarForecastSlot(
          time: time,
          cloudCover: cloudCover[i],
          radiation: radiation[i],
          isDaylight: isDaylight,
        ),
      );
    }

    final windows = _findBestWindows(slots);
    final bestWindow = windows.isEmpty ? null : windows.first;

    final daylightSlots = slots.where((slot) => slot.isDaylight).toList();
    final bestSlot = daylightSlots.isEmpty
        ? null
        : daylightSlots.reduce(
            (current, next) => next.score > current.score ? next : current,
          );

    // Estrai alba e tramonto del primo giorno disponibile.
    DateTime? sunrise;
    DateTime? sunset;
    if (daylightByDate.isNotEmpty) {
      final firstDay = daylightByDate.values.first;
      sunrise = firstDay.sunrise;
      sunset = firstDay.sunset;
    }

    return SolarForecast(
      locationName: locationName,
      locationDetail: locationDetail,
      country: country,
      slots: slots,
      windows: windows,
      bestWindow: bestWindow,
      bestSlot: bestSlot,
      sunrise: sunrise,
      sunset: sunset,
      isOffline: isOffline,
    );
  }

  /// Costruisce una mappa data → alba/tramonto dalla sezione "daily"
  /// della risposta API.
  Map<DateTime, _DaylightBounds> _buildDaylightMap(
    Map<String, dynamic>? daily,
  ) {
    if (daily == null) {
      return {};
    }

    final sunrise = (daily['sunrise'] as List<dynamic>? ?? const [])
        .map((value) => DateTime.parse(value as String))
        .toList();
    final sunset = (daily['sunset'] as List<dynamic>? ?? const [])
        .map((value) => DateTime.parse(value as String))
        .toList();

    final bounds = <DateTime, _DaylightBounds>{};
    final entries = math.min(sunrise.length, sunset.length);
    for (var i = 0; i < entries; i++) {
      bounds[_dateKey(sunrise[i])] = _DaylightBounds(
        sunrise: sunrise[i],
        sunset: sunset[i],
      );
    }

    return bounds;
  }

  /// Individua le finestre di alta produzione solare: gruppi contigui
  /// di slot diurni con score superiore al 40° percentile degli score
  /// diurni. Le finestre non si sovrappongono e richiedono almeno 2
  /// slot consecutivi. Ordinate per punteggio medio decrescente.
  List<SolarForecastWindow> _findBestWindows(List<SolarForecastSlot> slots) {
    final daylightSlots = slots.where((s) => s.isDaylight && s.score > 0).toList();
    if (daylightSlots.isEmpty) return [];

    // Calcola la soglia: 40° percentile degli score diurni.
    final scores = daylightSlots.map((s) => s.score).toList()..sort();
    final thresholdIndex = (scores.length * 0.4).floor().clamp(0, scores.length - 1);
    final threshold = scores[thresholdIndex];

    // Raggruppa slot consecutivi sopra soglia.
    final windows = <SolarForecastWindow>[];
    List<SolarForecastSlot> currentGroup = [];

    for (final slot in slots) {
      if (slot.isDaylight && slot.score >= threshold) {
        currentGroup.add(slot);
      } else {
        if (currentGroup.length >= 2) {
          windows.add(SolarForecastWindow(
            start: currentGroup.first.time,
            end: currentGroup.last.time.add(const Duration(hours: 1)),
            slots: List.of(currentGroup),
          ));
        }
        currentGroup = [];
      }
    }
    // Ultimo gruppo
    if (currentGroup.length >= 2) {
      windows.add(SolarForecastWindow(
        start: currentGroup.first.time,
        end: currentGroup.last.time.add(const Duration(hours: 1)),
        slots: List.of(currentGroup),
      ));
    }

    // Se non troviamo finestre con la soglia, fallback: tutta la fascia diurna.
    if (windows.isEmpty && daylightSlots.length >= 2) {
      windows.add(SolarForecastWindow(
        start: daylightSlots.first.time,
        end: daylightSlots.last.time.add(const Duration(hours: 1)),
        slots: daylightSlots,
      ));
    }

    windows.sort((a, b) => b.averageScore.compareTo(a.averageScore));
    return windows;
  }

  DateTime _dateKey(DateTime time) {
    return DateTime(time.year, time.month, time.day);
  }
}

class _DaylightBounds {
  _DaylightBounds({required this.sunrise, required this.sunset});

  final DateTime sunrise;
  final DateTime sunset;
}
