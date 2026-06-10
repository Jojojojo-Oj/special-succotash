import 'package:agapay_users/features/weather/domain/entities/weather_bundle.dart';

abstract class WeatherRepository {
  Future<WeatherBundle> getWeatherBundle();
  Future<WeatherBundle> getWeatherBundleForCoordinates(
    double latitude,
    double longitude,
  );
}
