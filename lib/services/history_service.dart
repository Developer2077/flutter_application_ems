import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/savings_model.dart';
import '../models/solar_forecast.dart';

/// Servizio per la persistenza locale dello storico giornaliero
/// di produzione solare e risparmio. Accumula i dati giorno per giorno
/// per costruire lo storico settimanale e mensile.
class HistoryService {
  static const String _historyKey = 'daily_history';
  static const int _maxDays = 30;

  /// Registra i dati di oggi. Se oggi è già registrato, aggiorna.
  Future<void> recordToday(SolarForecast forecast) async {
    final prefs = await SharedPreferences.getInstance();
    final history = _loadHistory(prefs);

    final todayKey = _dateKey(DateTime.now());
    final bestWindow = forecast.bestWindow;
    final optimalHours = bestWindow?.durationHours ?? 0;
    final avgRadiation = bestWindow?.averageRadiation ?? 0;

    history[todayKey] = DailyRecord(
      date: todayKey,
      peakRadiation: forecast.bestSlot?.radiation.toDouble() ?? 0,
      averageRadiation: avgRadiation,
      daylightHours: forecast.daylightHours,
      optimalHours: optimalHours,
      savings: SavingsModel.fromProduction(
        averageRadiationWm2: avgRadiation,
        optimalHours: optimalHours,
      ),
    );

    // Mantieni solo gli ultimi 30 giorni.
    final sortedKeys = history.keys.toList()..sort();
    while (sortedKeys.length > _maxDays) {
      history.remove(sortedKeys.removeAt(0));
    }

    _saveHistory(prefs, history);
  }

  /// Restituisce lo storico degli ultimi [days] giorni, ordinato per data.
  Future<List<DailyRecord>> getHistory({int days = 7}) async {
    final prefs = await SharedPreferences.getInstance();
    final history = _loadHistory(prefs);

    final cutoff = DateTime.now().subtract(Duration(days: days));
    final cutoffKey = _dateKey(cutoff);

    final records = history.entries
        .where((e) => e.key.compareTo(cutoffKey) >= 0)
        .map((e) => e.value)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return records;
  }

  /// Calcola il risparmio cumulativo degli ultimi [days] giorni.
  Future<SavingsModel> getCumulativeSavings({int days = 7}) async {
    final records = await getHistory(days: days);
    if (records.isEmpty) return SavingsModel.zero;
    return records.map((r) => r.savings).reduce((a, b) => a + b);
  }

  Map<String, DailyRecord> _loadHistory(SharedPreferences prefs) {
    final raw = prefs.getString(_historyKey);
    if (raw == null) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, DailyRecord.fromJson(v as Map<String, dynamic>)));
  }

  void _saveHistory(SharedPreferences prefs, Map<String, DailyRecord> history) {
    final map = history.map((k, v) => MapEntry(k, v.toJson()));
    prefs.setString(_historyKey, jsonEncode(map));
  }

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  /// Genera dati di esempio per i primi 10 giorni se non esiste storico.
  /// Questo permette di visualizzare i grafici subito.
  Future<void> seedSampleData() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = _loadHistory(prefs);
    if (existing.isNotEmpty) return; // Non sovrascrivere dati reali.

    final now = DateTime.now();
    final history = <String, DailyRecord>{};

    // Valori realistici di radiazione media per l'Italia in maggio.
    const sampleRadiations = [420.0, 380.0, 510.0, 290.0, 460.0, 350.0, 490.0, 310.0, 440.0, 470.0];
    const sampleOptimalHours = [4, 3, 5, 2, 4, 3, 5, 2, 4, 5];
    const sampleDaylightHours = [14, 14, 14, 14, 14, 14, 14, 14, 14, 14];

    for (var i = 9; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = _dateKey(day);
      final idx = 9 - i;
      final rad = sampleRadiations[idx];
      final optHours = sampleOptimalHours[idx];

      history[key] = DailyRecord(
        date: key,
        peakRadiation: rad * 1.3,
        averageRadiation: rad,
        daylightHours: sampleDaylightHours[idx],
        optimalHours: optHours,
        savings: SavingsModel.fromProduction(
          averageRadiationWm2: rad,
          optimalHours: optHours,
        ),
      );
    }

    _saveHistory(prefs, history);
  }
}

/// Record di una singola giornata di produzione solare.
class DailyRecord {
  const DailyRecord({
    required this.date,
    required this.peakRadiation,
    required this.averageRadiation,
    required this.daylightHours,
    required this.optimalHours,
    required this.savings,
  });

  final String date;
  final double peakRadiation;
  final double averageRadiation;
  final int daylightHours;
  final int optimalHours;
  final SavingsModel savings;

  Map<String, dynamic> toJson() => {
        'date': date,
        'peak': peakRadiation,
        'avg': averageRadiation,
        'daylight': daylightHours,
        'optimal': optimalHours,
        'savings': savings.toJson(),
      };

  factory DailyRecord.fromJson(Map<String, dynamic> json) => DailyRecord(
        date: json['date'] as String,
        peakRadiation: (json['peak'] as num).toDouble(),
        averageRadiation: (json['avg'] as num).toDouble(),
        daylightHours: json['daylight'] as int,
        optimalHours: json['optimal'] as int,
        savings: SavingsModel.fromJson(json['savings'] as Map<String, dynamic>),
      );
}
