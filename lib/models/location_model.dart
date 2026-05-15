import 'package:flutter/material.dart';

class LocationModel {
  LocationModel({
    required this.name,
    required this.detail,
    required this.country,
    required this.lat,
    required this.lon,
  });

  final String name;
  final String detail;
  final String country;
  final double lat;
  final double lon;

  String get displayLabel => name;

  String get subtitle {
    final parts = <String>[];
    if (detail.isNotEmpty) {
      parts.add(detail);
    }
    if (country.isNotEmpty) {
      parts.add(country);
    }
    return parts.join(', ');
  }

  factory LocationModel.fromJson(
    Map<String, dynamic> json, {
    required Locale locale,
  }) {
    final address = (json['address'] as Map<String, dynamic>?) ?? const {};
    final name = _pickName(address, json['display_name'] as String? ?? '');
    final detail = _pickDetail(address, name);
    final country = _translateCountry(
      address['country'] as String? ?? '',
      locale,
    );

    return LocationModel(
      name: name,
      detail: detail,
      country: country,
      lat: double.parse(json['lat'] as String),
      lon: double.parse(json['lon'] as String),
    );
  }
}

String _pickName(Map<String, dynamic> address, String fallback) {
  const keys = <String>[
    'city',
    'town',
    'village',
    'municipality',
    'hamlet',
    'suburb',
    'district',
    'quarter',
    'county',
    'state_district',
    'state',
  ];

  for (final key in keys) {
    final value = address[key] as String?;
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
  }

  if (fallback.isEmpty) {
    return '';
  }

  return fallback.split(',').first.trim();
}

String _pickDetail(Map<String, dynamic> address, String name) {
  const keys = <String>[
    'county',
    'state_district',
    'state',
    'region',
  ];

  for (final key in keys) {
    final value = address[key] as String?;
    if (value != null && value.trim().isNotEmpty && value.trim() != name) {
      return value.trim();
    }
  }

  return '';
}

String _translateCountry(String country, Locale locale) {
  final normalized = country.trim();
  if (normalized.isEmpty) {
    return '';
  }

  const italianMap = {
    'Italy': 'Italia',
    'United States': 'Stati Uniti',
  };

  const englishMap = {
    'Italia': 'Italy',
    'Stati Uniti': 'United States',
  };

  if (locale.languageCode == 'it') {
    return italianMap[normalized] ?? normalized;
  }

  return englishMap[normalized] ?? normalized;
}
