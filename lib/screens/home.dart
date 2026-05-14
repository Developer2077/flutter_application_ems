import 'package:flutter/material.dart';

import '../services/location_service.dart';
import '../services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController cityController = TextEditingController();

  final LocationService locationService = LocationService();

  final WeatherService weatherService = WeatherService();

  String result = '';

  Future<void> searchCity() async {
    try {
      final city = cityController.text;

      final location = await locationService.getCoordinates(city);

      final weather = await weatherService.fetchWeather(
        lat: location.lat,
        lon: location.lon,
      );

      final cloudCover = weather.cloudCover[12];

      setState(() {
        result =
            'Località: ${location.name}\n'
            'Nazione: ${location.country}\n'
            'Lat: ${location.lat}\n'
            'Lon: ${location.lon}\n'
            'Nuvolosità: $cloudCover%';
      });
    } catch (e) {
      setState(() {
        result = 'Errore: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solar Smart')),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: cityController,

              decoration: const InputDecoration(
                labelText: 'Inserisci comune',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: searchCity,

                child: const Text('Cerca'),
              ),
            ),

            const SizedBox(height: 30),

            Text(result, style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
