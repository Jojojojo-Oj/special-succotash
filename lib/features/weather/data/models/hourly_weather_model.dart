import 'package:agapay_users/features/weather/domain/entities/weather_bundle.dart';

class HourlyWeatherModel {
  final DateTime date;
  final double temp;
  final String description;

  HourlyWeatherModel({
    required this.date,
    required this.temp,
    required this.description,
  });

  HourlyWeather toEntity() {
    return HourlyWeather(
      date: date,
      temp: temp,
      description: description,
    );
  }
}
