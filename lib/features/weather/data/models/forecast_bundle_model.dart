import 'package:agapay_users/features/weather/data/models/daily_weather_model.dart';
import 'package:agapay_users/features/weather/data/models/hourly_weather_model.dart';

class ForecastBundleModel {
  final List<DailyWeatherModel> daily;
  final List<HourlyWeatherModel> hourly;
  final List<HourlyWeatherModel> hourlyAll;

  ForecastBundleModel({
    required this.daily,
    required this.hourly,
    required this.hourlyAll,
  });
}
