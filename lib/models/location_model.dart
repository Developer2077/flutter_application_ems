class LocationModel {

  final String name;
  final String country;

  final double lat;
  final double lon;

  LocationModel({
    required this.name,
    required this.country,
    required this.lat,
    required this.lon,
  });

  factory LocationModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return LocationModel(

      name: json['display_name'] ?? '',

      country: json['address']?['country'] ?? '',

      lat: double.parse(json['lat']),
      lon: double.parse(json['lon']),
    );
  }
}