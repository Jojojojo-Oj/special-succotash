import 'package:agapay_users/features/weather/domain/entities/weather_bundle.dart';

class CurrentWeatherModel {
  final String city;
  final double temp;
  final double maxTemp;
  final int humidity;
  final double wind;
  final String description;

  CurrentWeatherModel({
    required this.city,
    required this.temp,
    required this.maxTemp,
    required this.humidity,
    required this.wind,
    required this.description,
  });

  factory CurrentWeatherModel.fromJson(Map<String, dynamic> json) {
    return CurrentWeatherModel(
      city: json['name'] as String? ?? '',
      temp: (json['main']['temp'] as num).toDouble(),
      maxTemp: (json['main']['temp_max'] as num).toDouble(),
      humidity: (json['main']['humidity'] as num).toInt(),
      wind: (json['wind']['speed'] as num).toDouble() * 3.6,
      description: (json['weather'] as List).first['description'] as String,
    );
  }

  CurrentWeather toEntity() {
    return CurrentWeather(
      city: city,
      temp: temp,
      maxTemp: maxTemp,
      humidity: humidity,
      wind: wind,
      description: description,
    );
  }
}
