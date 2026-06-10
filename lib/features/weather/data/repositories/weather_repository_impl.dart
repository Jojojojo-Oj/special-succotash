import 'package:agapay_users/features/weather/data/datasources/location_datasource.dart';
import 'package:agapay_users/features/weather/data/datasources/open_weather_api.dart';
import 'package:agapay_users/features/weather/domain/entities/weather_bundle.dart';
import 'package:agapay_users/features/weather/domain/repositories/weather_repository.dart';
import 'package:geolocator/geolocator.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final OpenWeatherApi _api;
  final LocationDataSource _location;

  WeatherRepositoryImpl({
    required OpenWeatherApi api,
    required LocationDataSource location,
  })  : _api = api,
        _location = location;

  @override
  Future<WeatherBundle> getWeatherBundle() async {
    Position position;

    try {
      position = await _location.getPosition();
    } catch (_) {
      position = Position(
        latitude: 14.5995,
        longitude: 120.9842,
        timestamp: DateTime.now(),
        accuracy: 1,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
        isMocked: false,
      );
    }

    final currentModel = await _api.fetchCurrent(
      position.latitude,
      position.longitude,
    );

    final forecastModels = await _api.fetchForecast(
      position.latitude,
      position.longitude,
    );

    return WeatherBundle(
      current: currentModel.toEntity(),
      daily: forecastModels.daily.map((d) => d.toEntity()).toList(),
      hourly: forecastModels.hourly.map((h) => h.toEntity()).toList(),
      hourlyAll: forecastModels.hourlyAll.map((h) => h.toEntity()).toList(),
    );
  }

  @override
  Future<WeatherBundle> getWeatherBundleForCoordinates(
    double latitude,
    double longitude,
  ) async {
    final currentModel = await _api.fetchCurrent(latitude, longitude);
    final forecastModels = await _api.fetchForecast(latitude, longitude);

    return WeatherBundle(
      current: currentModel.toEntity(),
      daily: forecastModels.daily.map((d) => d.toEntity()).toList(),
      hourly: forecastModels.hourly.map((h) => h.toEntity()).toList(),
      hourlyAll: forecastModels.hourlyAll.map((h) => h.toEntity()).toList(),
    );
  }
}
