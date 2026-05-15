import 'package:shared_preferences/shared_preferences.dart';

/// Servizio per salvare e caricare la località preferita dell'utente.
class LocationPreferences {
  static const _keyCity = 'pref_city';
  static const _keyLat = 'pref_lat';
  static const _keyLon = 'pref_lon';
  static const _keyName = 'pref_name';
  static const _keyDetail = 'pref_detail';
  static const _keyCountry = 'pref_country';

  /// Salva la località preferita.
  Future<void> save({
    required String city,
    required double lat,
    required double lon,
    required String displayName,
    required String detail,
    required String country,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCity, city);
    await prefs.setDouble(_keyLat, lat);
    await prefs.setDouble(_keyLon, lon);
    await prefs.setString(_keyName, displayName);
    await prefs.setString(_keyDetail, detail);
    await prefs.setString(_keyCountry, country);
  }

  /// Carica la località salvata, o null se non esiste.
  Future<SavedLocation?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final city = prefs.getString(_keyCity);
    if (city == null || city.isEmpty) return null;
    return SavedLocation(
      city: city,
      lat: prefs.getDouble(_keyLat) ?? 0,
      lon: prefs.getDouble(_keyLon) ?? 0,
      displayName: prefs.getString(_keyName) ?? city,
      detail: prefs.getString(_keyDetail) ?? '',
      country: prefs.getString(_keyCountry) ?? '',
    );
  }

  /// Rimuove la località salvata.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCity);
    await prefs.remove(_keyLat);
    await prefs.remove(_keyLon);
    await prefs.remove(_keyName);
    await prefs.remove(_keyDetail);
    await prefs.remove(_keyCountry);
  }

  /// Controlla se esiste una località salvata.
  Future<bool> hasSaved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyCity);
  }
}

class SavedLocation {
  const SavedLocation({
    required this.city,
    required this.lat,
    required this.lon,
    required this.displayName,
    required this.detail,
    required this.country,
  });

  final String city;
  final double lat;
  final double lon;
  final String displayName;
  final String detail;
  final String country;
}
