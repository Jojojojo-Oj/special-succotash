import 'package:agapay_users/features/weather/domain/entities/weather_bundle.dart';
import 'package:agapay_users/features/weather/domain/repositories/weather_repository.dart';

class GetWeatherBundleForCoordinates {
  final WeatherRepository _repository;

  GetWeatherBundleForCoordinates(this._repository);

  Future<WeatherBundle> call(double latitude, double longitude) {
    return _repository.getWeatherBundleForCoordinates(latitude, longitude);
  }
}
