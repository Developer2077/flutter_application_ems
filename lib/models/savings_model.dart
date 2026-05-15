/// Modello per il calcolo del risparmio energetico e ambientale.
class SavingsModel {
  const SavingsModel({
    required this.selfConsumedKwh,
    required this.savedEuros,
    required this.avoidedCo2Kg,
  });

  /// kWh auto-consumati durante le fasce ottimali.
  final double selfConsumedKwh;

  /// Risparmio economico stimato in euro.
  final double savedEuros;

  /// CO₂ evitata in kg.
  final double avoidedCo2Kg;

  /// Prezzo medio dell'elettricità in Italia (€/kWh).
  static const double pricePerKwh = 0.25;

  /// Fattore di emissione della rete italiana (kg CO₂/kWh).
  static const double co2PerKwh = 0.4;

  /// Calcola il risparmio a partire dalla radiazione media
  /// e dalle ore di autoconsumo ottimale.
  factory SavingsModel.fromProduction({
    required double averageRadiationWm2,
    required int optimalHours,
    double panelAreaM2 = 10.0,
    double efficiency = 0.18,
  }) {
    // Stima produzione: W/m² × area × efficienza × ore → kWh
    final kwh = averageRadiationWm2 * panelAreaM2 * efficiency * optimalHours / 1000;
    return SavingsModel(
      selfConsumedKwh: kwh,
      savedEuros: kwh * pricePerKwh,
      avoidedCo2Kg: kwh * co2PerKwh,
    );
  }

  /// Somma due modelli (per cumulativo settimanale/mensile).
  SavingsModel operator +(SavingsModel other) => SavingsModel(
        selfConsumedKwh: selfConsumedKwh + other.selfConsumedKwh,
        savedEuros: savedEuros + other.savedEuros,
        avoidedCo2Kg: avoidedCo2Kg + other.avoidedCo2Kg,
      );

  Map<String, dynamic> toJson() => {
        'kwh': selfConsumedKwh,
        'eur': savedEuros,
        'co2': avoidedCo2Kg,
      };

  factory SavingsModel.fromJson(Map<String, dynamic> json) => SavingsModel(
        selfConsumedKwh: (json['kwh'] as num?)?.toDouble() ?? 0,
        savedEuros: (json['eur'] as num?)?.toDouble() ?? 0,
        avoidedCo2Kg: (json['co2'] as num?)?.toDouble() ?? 0,
      );

  static const SavingsModel zero = SavingsModel(
    selfConsumedKwh: 0,
    savedEuros: 0,
    avoidedCo2Kg: 0,
  );
}
