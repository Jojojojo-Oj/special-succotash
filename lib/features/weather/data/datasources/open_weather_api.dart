import 'dart:convert';

import 'package:agapay_users/features/weather/data/models/current_weather_model.dart';
import 'package:agapay_users/features/weather/data/models/daily_weather_model.dart';
import 'package:agapay_users/features/weather/data/models/forecast_bundle_model.dart';
import 'package:agapay_users/features/weather/data/models/hourly_weather_model.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class OpenWeatherApi {
  final String apiKey;
  final http.Client _client;

  OpenWeatherApi({required this.apiKey, http.Client? client})
      : _client = client ?? http.Client();

  Future<CurrentWeatherModel> fetchCurrent(double lat, double lng) async {
    final res = await _client.get(Uri.https(
      'api.openweathermap.org',
      '/data/2.5/weather',
      {
        'lat': '$lat',
        'lon': '$lng',
        'units': 'metric',
        'appid': apiKey,
      },
    ));

    if (res.statusCode != 200) {
      throw Exception('Failed to load current weather');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return CurrentWeatherModel.fromJson(json);
  }

  Future<ForecastBundleModel> fetchForecast(double lat, double lng) async {
    final res = await _client.get(Uri.https(
      'api.openweathermap.org',
      '/data/2.5/forecast',
      {
        'lat': '$lat',
        'lon': '$lng',
        'units': 'metric',
        'appid': apiKey,
      },
    ));

    if (res.statusCode != 200) {
      throw Exception('Failed to load forecast');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final List list = json['list'] as List;

    final Map<String, DailyWeatherModel> days = {};
    final List<HourlyWeatherModel> hourly = [];
    final List<HourlyWeatherModel> hourlyAll = [];

    for (final item in list) {
      final dt = DateTime.fromMillisecondsSinceEpoch(
        (item['dt'] as num).toInt() * 1000,
        isUtc: true,
      ).toLocal();

      final hourlyItem = HourlyWeatherModel(
        date: dt,
        temp: (item['main']['temp'] as num).toDouble(),
        description: (item['weather'] as List).first['description'] as String,
      );

      hourlyAll.add(hourlyItem);

      if (hourly.length < 8) {
        hourly.add(hourlyItem);
      }

      final key = DateFormat('yyyy-MM-dd').format(dt);
      if (!days.containsKey(key)) {
        days[key] = DailyWeatherModel(
          date: dt,
          temp: (item['main']['temp'] as num).toDouble(),
          description: (item['weather'] as List).first['description'] as String,
        );
      }
    }

    return ForecastBundleModel(
      daily: days.values.take(5).toList(),
      hourly: hourly,
      hourlyAll: hourlyAll,
    );
  }
}
