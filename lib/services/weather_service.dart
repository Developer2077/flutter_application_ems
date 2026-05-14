import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather_model.dart';

class WeatherService {

  Future<WeatherModel> fetchWeather({
    required double lat,
    required double lon,
  }) async {

    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat'
      '&longitude=$lon'
      '&hourly=cloud_cover'
      '&forecast_days=1',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      return WeatherModel.fromJson(data);

    } else {

      throw Exception(
        'Errore meteo',
      );
    }
  }
}