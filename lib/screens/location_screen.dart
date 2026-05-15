import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../l10n/app_strings.dart';
import '../services/location_preferences.dart';
import '../services/location_service.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key, this.onLocationChanged});

  final VoidCallback? onLocationChanged;

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  SavedLocation? _savedLocation;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final prefs = LocationPreferences();
    final saved = await prefs.load();
    setState(() {
      _savedLocation = saved;
      _loading = false;
    });
  }

  Future<void> _promptChangeLocation(AppStrings strings) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.changeLocation),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: strings.searchHint,
            prefixIcon: const Icon(Icons.search),
          ),
          autofocus: true,
          onSubmitted: (val) => Navigator.pop(context, val),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Salva'),
          ),
        ],
      ),
    );

    if (result != null && result.trim().isNotEmpty && mounted) {
      setState(() => _loading = true);
      try {
        final locService = LocationService();
        final loc = await locService.getCoordinates(result.trim(), locale: Localizations.localeOf(context));
        
        final prefs = LocationPreferences();
        await prefs.save(
          city: loc.name,
          lat: loc.lat,
          lon: loc.lon,
          displayName: loc.name,
          detail: loc.detail,
          country: loc.country,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.locationSaved)));
        }
        widget.onLocationChanged?.call();
        await _loadLocation();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
          setState(() => _loading = false);
        }
      }
    }
  }

  Future<void> _removeLocation(AppStrings strings) async {
    final prefs = LocationPreferences();
    await prefs.clear();
    setState(() => _savedLocation = null);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.locationRemoved)));
    }
    widget.onLocationChanged?.call();
  }

  Future<void> _useCurrentLocation(AppStrings strings) async {
    setState(() => _loading = true);

    try {
      if (Platform.isWindows) {
        throw Exception('La localizzazione GPS automatica è supportata solo su Android e iOS. Inserisci la città manualmente.');
      }
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('I servizi di localizzazione sono disabilitati.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permessi di localizzazione negati.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permessi negati permanentemente. Abilitali nelle impostazioni del telefono.');
      }

      // Prova a prendere l'ultima posizione nota (più veloce)
      Position? position = await Geolocator.getLastKnownPosition();
      
      // Se non c'è o è vecchia, richiedi quella attuale con un timeout
      position ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final locService = LocationService();
      if (!mounted) return;
      final loc = await locService.getLocationFromCoordinates(
        position.latitude,
        position.longitude,
        locale: Localizations.localeOf(context),
      );

      final prefs = LocationPreferences();
      await prefs.save(
        city: loc.name,
        lat: loc.lat,
        lon: loc.lon,
        displayName: loc.name,
        detail: loc.detail,
        country: loc.country,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.locationSaved)));
      }
      widget.onLocationChanged?.call();
      await _loadLocation();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.savedLocationTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            strings.savedLocationSubtitle,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_savedLocation != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withAlpha(50),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.primary.withAlpha(50)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.place, color: theme.colorScheme.primary, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _savedLocation!.displayName,
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(strings.savedLocationInfo(_savedLocation!.displayName), style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(strings.autoLoadEnabled, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _promptChangeLocation(strings),
                    icon: const Icon(Icons.edit_location_alt_outlined),
                    label: Text(strings.changeLocation),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _useCurrentLocation(strings),
                    icon: const Icon(Icons.my_location),
                    label: Text(strings.useCurrentLocation),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: () => _removeLocation(strings),
                icon: const Icon(Icons.delete_outline),
                label: Text(strings.removeLocation),
                style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
              ),
            ),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.location_off_outlined, size: 64, color: theme.colorScheme.onSurface.withAlpha(100)),
                    const SizedBox(height: 16),
                    Text(strings.noSavedLocation, style: theme.textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _promptChangeLocation(strings),
                icon: const Icon(Icons.add_location_alt_outlined),
                label: Text(strings.saveLocation),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _useCurrentLocation(strings),
                icon: const Icon(Icons.my_location),
                label: Text(strings.useCurrentLocation),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
