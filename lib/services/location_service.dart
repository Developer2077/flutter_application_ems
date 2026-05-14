import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/location_model.dart';

class LocationService {

  Future<LocationModel> getCoordinates(
    String city,
  ) async {

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=$city'
      '&format=json'
      '&addressdetails=1'
      '&limit=1',
    );

    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'solar-smart-app',
      },
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      if (data.isNotEmpty) {

        return LocationModel.fromJson(
          data[0],
        );

      } else {

        throw Exception(
          'Località non trovata',
        );
      }

    } else {

      throw Exception(
        'Errore geocoding',
      );
    }
  }
}