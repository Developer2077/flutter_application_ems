import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/location_model.dart';

class LocationService {
  Future<LocationModel> getCoordinates(
    String city, {
    required Locale locale,
  }) async {
    final url = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': city,
      'format': 'json',
      'addressdetails': '1',
      'limit': '1',
      'accept-language': locale.languageCode,
    });

    final response = await http.get(
      url,
      headers: {'User-Agent': 'solar-smart-app'},
    );

    if (response.statusCode != 200) {
      throw Exception('Errore geocoding');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    if (data.isEmpty) {
      throw Exception('Localita non trovata');
    }

    return LocationModel.fromJson(
      data.first as Map<String, dynamic>,
      locale: locale,
    );
  }

  Future<LocationModel> getLocationFromCoordinates(
    double lat,
    double lon, {
    required Locale locale,
  }) async {
    final url = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'format': 'json',
      'addressdetails': '1',
      'accept-language': locale.languageCode,
    });

    final response = await http.get(
      url,
      headers: {'User-Agent': 'solar-smart-app'},
    );

    if (response.statusCode != 200) {
      throw Exception('Errore reverse geocoding');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['error'] != null) {
      throw Exception('Posizione non trovata');
    }

    return LocationModel.fromJson(
      data,
      locale: locale,
    );
  }
}
