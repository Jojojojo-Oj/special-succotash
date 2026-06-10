import 'package:agapay_users/features/weather/data/datasources/location_datasource.dart';
import 'package:agapay_users/features/weather/data/datasources/open_weather_api.dart';
import 'package:agapay_users/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:agapay_users/features/weather/domain/entities/weather_bundle.dart';
import 'package:agapay_users/features/weather/domain/usecases/get_weather_bundle_for_coordinates.dart';
import 'package:agapay_users/features/weather/presentation/utils/weather_asset_mapper.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';


const String openWeatherApiKey = 'fafdb23a141d54b7b3d3e94fe4d6ce4f';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late final GetWeatherBundleForCoordinates _getWeatherBundleForCoordinates;
  late Future<WeatherBundle> _future;
  late final List<_PhilippineCity> _cities;
  late _PhilippineCity _selectedCity;
  int? _selectedHour;

  @override
  void initState() {
    super.initState();
    final repository = WeatherRepositoryImpl(
      api: OpenWeatherApi(apiKey: openWeatherApiKey),
      location: GeolocatorLocationDataSource(),
    );
    _getWeatherBundleForCoordinates =
        GetWeatherBundleForCoordinates(repository);
    _cities = _philippineCities();
    _selectedCity = _cities.first;
    _future = _getWeatherBundleForCoordinates(
      _selectedCity.latitude,
      _selectedCity.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF0D3B8C),
      body: FutureBuilder<WeatherBundle>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;
          final today = data.current;
          final selectedHour =
              _selectedHour ?? (data.hourly.isNotEmpty ? data.hourly.first.date.hour : DateTime.now().hour);
          final nextByHour = _buildNextForecastByHour(
            data.hourlyAll,
            selectedHour,
          );

          return SafeArea(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: _backgroundGradient(DateTime.now()),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        const Spacer(),
                       _LocationPicker(
                        selected: _selectedCity,
                        cities: _cities,
                        onSelected: (city) {
                          setState(() {
                            _selectedCity = city;
                            _future = _getWeatherBundleForCoordinates(
                              city.latitude,
                              city.longitude,
                            );
                          });
                        },
                      ),

                        const Spacer(),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Image.asset(
                      weatherAsset(today.description, DateTime.now()),
                      height: size.width * 0.32,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${today.temp.round()}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      titleCase(today.description),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),

                    

                    Text(
                      'Max.: ${today.maxTemp.round()}°   Min.: ${(today.temp - 3).round()}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 18),

                    _GlassContainer(
                      width: size.width * 0.85,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      borderRadius: 22,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _StatPill(
                            icon: Icons.grain,
                            label: '${(today.humidity / 10).round()}%',
                          ),
                          _StatPill(
                            icon: Icons.water_drop,
                            label: '${today.humidity}%',
                          ),
                          _StatPill(
                            icon: Icons.air,
                            label: '${today.wind.round()} km/h',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    _GlassContainer(
                      width: size.width * 0.85,
                      padding: const EdgeInsets.all(16),
                      borderRadius: 22,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Today',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                DateFormat('MMM, d').format(DateTime.now()),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          SizedBox(
                            height: size.height * 0.14,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: data.hourly.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final d = data.hourly[index];
                                final isSelected = d.date.hour == selectedHour;
                                return _HourCard(
                                  day: d,
                                  isActive: isSelected,
                                  onTap: () {
                                    setState(() {
                                      _selectedHour = d.date.hour;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    _GlassContainer(
                      width: size.width * 0.85,
                      padding: const EdgeInsets.all(16),
                      borderRadius: 22,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Next Forecast',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.calendar_month,
                                  color: Colors.white, size: 25),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...nextByHour.map((d) => _NextForecastRow(day: d)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatPill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _HourCard extends StatelessWidget {
  final HourlyWeather day;
  final bool isActive;
  final VoidCallback onTap;

  const _HourCard({
    required this.day,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('h a').format(day.date),
              style: GoogleFonts.poppins(
                color: isActive ? Colors.white : Colors.white70,
                fontSize: 16,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 8),
            Image.asset(
              weatherAsset(day.description, day.date),
              height: 25,
            ),
            const SizedBox(height: 8),
            Text(
              '${day.temp.round()}°',
              style: GoogleFonts.poppins(
                color: isActive ? Colors.white : Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextForecastRow extends StatelessWidget {
  final HourlyWeather day;

  const _NextForecastRow({required this.day});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              DateFormat('MMM, d').format(day.date),
              style: GoogleFonts.alegreyaSans(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          Image.asset(
            weatherAsset(day.description, day.date),
            height: 35,
          ),
          const SizedBox(width: 70),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${day.temp.round()}°',
                  style: GoogleFonts.alegreyaSans(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(text: '  '),
                TextSpan(
                  text: '${(day.temp - 3).round()}°',
                  style: GoogleFonts.alegreyaSans(
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<HourlyWeather> _buildNextForecastByHour(
  List<HourlyWeather> hourlyAll,
  int selectedHour,
) {
  if (hourlyAll.isEmpty) return [];

  int hourToUse = selectedHour;
  final hoursAvailable = hourlyAll
      .map((h) => h.date.hour)
      .toSet()
      .toList()
    ..sort();

  if (!hoursAvailable.contains(hourToUse)) {
    hourToUse = hoursAvailable.reduce(
      (a, b) => (a - selectedHour).abs() <= (b - selectedHour).abs() ? a : b,
    );
  }

  final Map<String, HourlyWeather> byDay = {};
  for (final h in hourlyAll) {
    if (h.date.hour != hourToUse) continue;
    final key = DateFormat('yyyy-MM-dd').format(h.date);
    if (!byDay.containsKey(key)) {
      byDay[key] = h;
    }
    if (byDay.length >= 5) break;
  }

  return byDay.values.toList();
}

class _GlassContainer extends StatelessWidget {
  final double? width;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool showBorder;
  final double opacity;
  final Widget child;

  const _GlassContainer({
    required this.child,
    this.width,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.showBorder = true,
    this.opacity = 0.12,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: width,
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0xFF104084).withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: showBorder
                ? Border.all(color: Colors.white.withOpacity(0.15))
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}

LinearGradient _backgroundGradient(DateTime date) {
  final hour = date.hour;
  final isNight = hour < 6 || hour >= 18;

  if (isNight) {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF08244F),
        Color(0xFF134CB5),
        Color(0xFF74A4FF),
      ],
      stops: [0.0, 0.5, 1.0],
    );
  }

  return const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF38B9EA),
      Color(0xFFBFE9FF),
    ],
  );
}

class _PhilippineCity {
  final String name;
  final double latitude;
  final double longitude;

  const _PhilippineCity({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

class _LocationPicker extends StatelessWidget {
  final _PhilippineCity selected;
  final List<_PhilippineCity> cities;
  final ValueChanged<_PhilippineCity> onSelected;

  const _LocationPicker({
    required this.selected,
    required this.cities,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showCityPicker(context),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on,
              color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            selected.name,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 2),
          const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white70,
            size: 22,
          ),
        ],
      ),
    );
  }

  void _showCityPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0C56B8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: cities.length,
            separatorBuilder: (_, __) =>
                Divider(color: Colors.white.withOpacity(0.1)),
            itemBuilder: (context, index) {
              final city = cities[index];
              final isSelected = city.name == selected.name;

              return ListTile(
                title: Text(
                  city.name,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check,
                        color: Colors.white)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  onSelected(city);
                },
              );
            },
          ),
        );
      },
    );
  }
}
List<_PhilippineCity> _philippineCities() {
  return const [
    _PhilippineCity(name: 'Caloocan', latitude: 14.7566, longitude: 121.0450),
    _PhilippineCity(name: 'Manila', latitude: 14.5995, longitude: 120.9842),
    _PhilippineCity(name: 'Quezon City', latitude: 14.6760, longitude: 121.0437),
    _PhilippineCity(name: 'Makati', latitude: 14.5547, longitude: 121.0244),
    _PhilippineCity(name: 'Pasig', latitude: 14.5764, longitude: 121.0851),
    _PhilippineCity(name: 'Taguig', latitude: 14.5176, longitude: 121.0509),
    _PhilippineCity(name: 'Cebu City', latitude: 10.3157, longitude: 123.8854),
    _PhilippineCity(name: 'Davao City', latitude: 7.1907, longitude: 125.4553),
    _PhilippineCity(name: 'Baguio', latitude: 16.4023, longitude: 120.5960),
  ];
}
