/// Previsione solare completa per una località, con slot orari,
/// finestre di alta produzione e informazioni su alba/tramonto.
class SolarForecast {
  SolarForecast({
    required this.locationName,
    required this.locationDetail,
    required this.country,
    required this.slots,
    required this.windows,
    required this.bestWindow,
    required this.bestSlot,
    this.sunrise,
    this.sunset,
    this.isOffline = false,
  });

  final String locationName;
  final String locationDetail;
  final String country;
  final List<SolarForecastSlot> slots;
  final List<SolarForecastWindow> windows;
  final SolarForecastWindow? bestWindow;
  final SolarForecastSlot? bestSlot;
  final bool isOffline;

  /// Alba del primo giorno della previsione (se disponibile).
  final DateTime? sunrise;

  /// Tramonto del primo giorno della previsione (se disponibile).
  final DateTime? sunset;

  String get locationLabel => locationName;

  String get locationSubtitle {
    final parts = <String>[];
    if (locationDetail.isNotEmpty) {
      parts.add(locationDetail);
    }
    if (country.isNotEmpty) {
      parts.add(country);
    }
    return parts.join(', ');
  }

  List<SolarForecastSlot> get daylightSlots =>
      slots.where((slot) => slot.isDaylight).toList();

  int get daylightHours => daylightSlots.length;

  bool get hasDaylight => daylightHours > 0;

  /// Verifica se in questo momento ci troviamo dentro la migliore
  /// finestra di alta produzione solare (non una qualunque).
  bool get isCurrentlyHighProduction {
    if (bestWindow == null) return false;
    final now = DateTime.now();
    return !now.isBefore(bestWindow!.start) && now.isBefore(bestWindow!.end);
  }

  /// Restituisce la prossima finestra di alta produzione solare
  /// rispetto all'ora corrente, oppure null se non ce ne sono.
  SolarForecastWindow? get nextHighProductionWindow {
    final now = DateTime.now();
    for (final window in windows) {
      if (window.end.isAfter(now)) return window;
    }
    return null;
  }

  /// Durata fino all'inizio della migliore finestra di produzione.
  /// Null se la finestra è già passata o non esiste.
  /// Duration.zero se siamo già dentro la finestra.
  Duration? get timeUntilNextWindow {
    if (bestWindow == null) return null;
    final now = DateTime.now();
    if (now.isAfter(bestWindow!.end) || now.isAtSameMomentAs(bestWindow!.end)) return null;
    if (!now.isBefore(bestWindow!.start)) return Duration.zero;
    return bestWindow!.start.difference(now);
  }
}

/// Singolo slot orario nella previsione solare (1 ora).
class SolarForecastSlot {
  SolarForecastSlot({
    required this.time,
    required this.cloudCover,
    required this.radiation,
    required this.isDaylight,
  }) : score = radiation * (1 - cloudCover / 100);

  final DateTime time;
  final int cloudCover;
  final int radiation;
  final bool isDaylight;

  /// Punteggio combinato: radiazione pesata per la copertura nuvolosa.
  final double score;
}

/// Finestra continua di alta produzione solare (≥ 1 slot consecutivi).
class SolarForecastWindow {
  SolarForecastWindow({
    required this.start,
    required this.end,
    required this.slots,
  }) : averageScore =
           slots.map((slot) => slot.score).reduce((a, b) => a + b) /
           slots.length,
       averageCloudCover =
           slots.map((slot) => slot.cloudCover).reduce((a, b) => a + b) /
           slots.length,
       averageRadiation =
           slots.map((slot) => slot.radiation).reduce((a, b) => a + b) /
           slots.length;

  final DateTime start;
  final DateTime end;
  final List<SolarForecastSlot> slots;
  final double averageScore;
  final double averageCloudCover;
  final double averageRadiation;

  bool get daylightOnly => slots.every((slot) => slot.isDaylight);

  int get durationHours => slots.length;
}
