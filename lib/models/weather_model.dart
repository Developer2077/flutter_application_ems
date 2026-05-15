class WeatherModel {
  final List<dynamic> time;
  final List<dynamic> cloudCover;

  WeatherModel({required this.time, required this.cloudCover});

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      time: json['hourly']['time'],

      cloudCover: json['hourly']['cloud_cover'],
    );
  }
}
