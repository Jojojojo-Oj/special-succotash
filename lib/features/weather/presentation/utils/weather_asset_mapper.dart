String titleCase(String text) {
  return text.split(' ').map((w) {
    if (w.isEmpty) return w;
    return w[0].toUpperCase() + w.substring(1);
  }).join(' ');
}

String weatherAsset(String description, DateTime date) {
  final desc = description.toLowerCase();
  final hour = date.hour;
  final isNight = hour < 6 || hour >= 18;

  if (desc.contains('thunder')) {
    if (desc.contains('rain')) {
      return 'assets/weather/thunderstorm_rain.png';
    }
    if (desc.contains('clear')) {
      return 'assets/weather/thunderstorm_clear.png';
    }
    return 'assets/weather/thunderstorm_day.png';
  }

  if (desc.contains('snow')) {
    if (desc.contains('rain') || desc.contains('sleet')) {
      return 'assets/weather/snow_rain.png';
    }
    return 'assets/weather/snow.png';
  }

  if (desc.contains('rain') || desc.contains('drizzle')) {
    return isNight ? 'assets/weather/rain.png' : 'assets/weather/rain_day.png';
  }

  if (desc.contains('mist') ||
      desc.contains('fog') ||
      desc.contains('smoke') ||
      desc.contains('haze') ||
      desc.contains('dust') ||
      desc.contains('sand') ||
      desc.contains('ash')) {
    return desc.contains('haze')
        ? 'assets/weather/clear_haze.png'
        : 'assets/weather/mist.png';
  }

  if (desc.contains('wind') ||
      desc.contains('squall') ||
      desc.contains('tornado')) {
    return 'assets/weather/wind.png';
  }

  if (desc.contains('clear')) {
    return isNight ? 'assets/weather/clear_night.png' : 'assets/weather/clear.png';
  }

  if (desc.contains('broken')) {
    return 'assets/weather/broken_clouds.png';
  }

  if (desc.contains('overcast') || desc.contains('cloudy')) {
    return 'assets/weather/cloudy.png';
  }

  if (desc.contains('few') || desc.contains('scattered') || desc.contains('partly')) {
    return isNight
        ? 'assets/weather/partly_cloudy_night.png'
        : 'assets/weather/partly_cloudy_day.png';
  }

  if (desc.contains('cloud')) {
    return 'assets/weather/cloudy.png';
  }

  return isNight ? 'assets/weather/clear_night.png' : 'assets/weather/clear.png';
}
