import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weathernow/features/weather/presentation/providers/weather_provider.dart';
import 'package:weathernow/features/weather/presentation/providers/weather_state.dart';
import 'package:weathernow/features/weather/presentation/widgets/weather_card.dart';
import 'package:weathernow/features/weather/presentation/widgets/forecast_strip.dart';

/// "Tapping [a favorite] opens the same detail view as a fresh search."
/// Rather than duplicating Home's body, we trigger the same
/// [weatherProvider] search and render the same widgets it uses.
class CityWeatherScreen extends ConsumerStatefulWidget {
  final String cityName;
  const CityWeatherScreen({super.key, required this.cityName});

  @override
  ConsumerState<CityWeatherScreen> createState() => _CityWeatherScreenState();
}

class _CityWeatherScreenState extends ConsumerState<CityWeatherScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(weatherProvider.notifier).searchCity(widget.cityName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weatherProvider);
    return Scaffold(
      appBar: AppBar(title: Text(widget.cityName)),
      body: switch (state.status) {
        WeatherStatus.loading || WeatherStatus.initial => const Center(child: CircularProgressIndicator()),
        WeatherStatus.error => Center(child: Text(state.errorMessage ?? 'Something went wrong.')),
        WeatherStatus.success => ListView(
            children: [
              if (state.weather != null) WeatherCard(weather: state.weather!),
              if (state.forecast != null) ForecastStrip(forecast: state.forecast!),
            ],
          ),
      },
    );
  }
}
