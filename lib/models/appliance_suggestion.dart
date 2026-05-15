import 'package:flutter/material.dart';

import 'solar_forecast.dart';

/// Tipo di elettrodomestico energivoro supportato dall'app.
enum ApplianceType {
  washingMachine,
  dishwasher,
  evCharger,
  dryer,
  oven,
  lights,
}

/// Livello di raccomandazione per l'utilizzo di un elettrodomestico.
enum RecommendationLevel {
  /// La finestra è in corso adesso: ideale per avviare.
  optimal,

  /// La finestra inizierà a breve (entro 2 ore).
  good,

  /// La prossima finestra utile è lontana o assente.
  poor,
}

/// Suggerimento concreto per un elettrodomestico, generato a partire
/// dalla previsione solare corrente.
class ApplianceSuggestion {
  const ApplianceSuggestion({
    required this.type,
    required this.windowStart,
    required this.windowEnd,
    required this.level,
  });

  final ApplianceType type;

  /// Orario di inizio della finestra consigliata.
  final DateTime windowStart;

  /// Orario di fine della finestra consigliata.
  final DateTime windowEnd;

  /// Livello di raccomandazione calcolato.
  final RecommendationLevel level;

  /// Icona Material per il tipo di elettrodomestico.
  IconData get icon => switch (type) {
        ApplianceType.washingMachine => Icons.local_laundry_service_outlined,
        ApplianceType.dishwasher => Icons.countertops_outlined,
        ApplianceType.evCharger => Icons.ev_station_outlined,
        ApplianceType.dryer => Icons.dry_cleaning_outlined,
        ApplianceType.oven => Icons.microwave_outlined,
        ApplianceType.lights => Icons.lightbulb_outline,
      };

  /// Colore semantico associato al livello.
  Color color(ColorScheme scheme) => switch (level) {
        RecommendationLevel.optimal => const Color(0xFF1B5E20),
        RecommendationLevel.good => const Color(0xFFBF360C),
        RecommendationLevel.poor => scheme.outline,
      };

  /// Colore di sfondo per la card.
  Color background(ColorScheme scheme) {
    final isLight = scheme.brightness == Brightness.light;
    return switch (level) {
      RecommendationLevel.optimal =>
        const Color(0xFF2E7D32).withOpacity(isLight ? 0.25 : 0.15),
      RecommendationLevel.good =>
        const Color(0xFFE65100).withOpacity(isLight ? 0.20 : 0.12),
      RecommendationLevel.poor =>
        scheme.surfaceContainerHighest.withOpacity(isLight ? 0.9 : 0.6),
    };
  }

  /// Genera i suggerimenti per tutti gli elettrodomestici a partire
  /// dalla previsione solare. La logica considera la finestra migliore
  /// per i grandi carichi e una soglia minima per le luci.
  static List<ApplianceSuggestion> fromForecast(SolarForecast forecast) {
    final now = DateTime.now();
    final bestWindow = forecast.bestWindow;

    return ApplianceType.values.map((type) {
      if (type == ApplianceType.lights) {
        // Per le luci usiamo una soglia bassa: qualsiasi slot con irraggiamento > 50.
        final currentSlot = forecast.slots.firstWhere(
          (s) => s.time.hour == now.hour,
          orElse: () => forecast.slots.first,
        );

        if (currentSlot.isDaylight && currentSlot.radiation >= 50) {
          return ApplianceSuggestion(
            type: type,
            windowStart: currentSlot.time,
            windowEnd: currentSlot.time.add(const Duration(hours: 1)),
            level: RecommendationLevel.optimal,
          );
        }

        // Se non adesso, cerchiamo la prossima ora con luce.
        final nextLightSlot = forecast.slots.firstWhere(
          (s) => s.time.isAfter(now) && s.isDaylight && s.radiation >= 50,
          orElse: () => currentSlot,
        );

        return ApplianceSuggestion(
          type: type,
          windowStart: nextLightSlot.time,
          windowEnd: nextLightSlot.time.add(const Duration(hours: 1)),
          level: nextLightSlot.time.difference(now).inHours < 3
              ? RecommendationLevel.good
              : RecommendationLevel.poor,
        );
      }

      // Per gli altri (grandi carichi), usiamo la bestWindow come prima.
      if (bestWindow == null) {
        return ApplianceSuggestion(
          type: type,
          windowStart: now,
          windowEnd: now,
          level: RecommendationLevel.poor,
        );
      }

      return ApplianceSuggestion(
        type: type,
        windowStart: bestWindow.start,
        windowEnd: bestWindow.end,
        level: _computeLevel(now, bestWindow),
      );
    }).toList();
  }

  /// Determina il livello di raccomandazione in base alla posizione
  /// temporale rispetto alla finestra.
  static RecommendationLevel _computeLevel(
    DateTime now,
    SolarForecastWindow window,
  ) {
    // Se siamo dentro la finestra → ottimale.
    if (!now.isBefore(window.start) && now.isBefore(window.end)) {
      return RecommendationLevel.optimal;
    }

    // Se la finestra è nel futuro e a meno di 2 ore → buono.
    if (now.isBefore(window.start)) {
      final diff = window.start.difference(now);
      if (diff.inHours < 2) return RecommendationLevel.good;
    }

    return RecommendationLevel.poor;
  }
}
