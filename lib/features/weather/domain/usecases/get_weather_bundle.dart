import 'package:agapay_users/features/weather/domain/entities/weather_bundle.dart';
import 'package:agapay_users/features/weather/domain/repositories/weather_repository.dart';

class GetWeatherBundle {
  final WeatherRepository _repository;

  GetWeatherBundle(this._repository);

  Future<WeatherBundle> call() {
    return _repository.getWeatherBundle();
  }
}
