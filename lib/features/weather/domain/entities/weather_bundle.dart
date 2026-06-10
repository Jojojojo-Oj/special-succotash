class WeatherBundle {
  final CurrentWeather current;
  final List<DailyWeather> daily;
  final List<HourlyWeather> hourly;
  final List<HourlyWeather> hourlyAll;

  WeatherBundle({
    required this.current,
    required this.daily,
    required this.hourly,
    required this.hourlyAll,
  });
}

class CurrentWeather {
  final String city;
  final double temp;
  final double maxTemp;
  final int humidity;
  final double wind;
  final String description;

  CurrentWeather({
    required this.city,
    required this.temp,
    required this.maxTemp,
    required this.humidity,
    required this.wind,
    required this.description,
  });
}

class DailyWeather {
  final DateTime date;
  final double temp;
  final String description;

  DailyWeather({
    required this.date,
    required this.temp,
    required this.description,
  });
}

class HourlyWeather {
  final DateTime date;
  final double temp;
  final String description;

  HourlyWeather({
    required this.date,
    required this.temp,
    required this.description,
  });
}
