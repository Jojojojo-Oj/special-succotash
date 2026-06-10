import 'package:agapay_users/features/weather/domain/entities/weather_bundle.dart';

class DailyWeatherModel {
  final DateTime date;
  final double temp;
  final String description;

  DailyWeatherModel({
    required this.date,
    required this.temp,
    required this.description,
  });

  DailyWeather toEntity() {
    return DailyWeather(date: date, temp: temp, description: description);
  }
}
