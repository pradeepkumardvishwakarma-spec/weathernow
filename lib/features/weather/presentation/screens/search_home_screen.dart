import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:weathernow/core/utils/constants.dart';
import 'package:weathernow/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:weathernow/features/weather/presentation/providers/weather_provider.dart';
import 'package:weathernow/features/weather/presentation/providers/weather_state.dart';
import 'package:weathernow/features/weather/presentation/widgets/city_search_bar.dart';
import 'package:weathernow/features/weather/presentation/widgets/weather_card.dart';
import 'package:weathernow/features/weather/presentation/widgets/forecast_strip.dart';

class SearchHomeScreen extends ConsumerStatefulWidget {
  const SearchHomeScreen({super.key});

  @override
  ConsumerState<SearchHomeScreen> createState() => _SearchHomeScreenState();
}

class _SearchHomeScreenState extends ConsumerState<SearchHomeScreen> {
  String? _lastCity;

  @override
  void initState() {
    super.initState();
    // "Opens on ... the last city you looked at, if any" — restore
    // it and kick off a search automatically.
    _lastCity = Hive.box(HiveBoxes.settings).get(SettingsKeys.lastCity) as String?;
    if (_lastCity != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(weatherProvider.notifier).searchCity(_lastCity!);
      });
    }
  }

  void _search(String city) {
    Hive.box(HiveBoxes.settings).put(SettingsKeys.lastCity, city);
    ref.read(weatherProvider.notifier).searchCity(city);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weatherProvider);
    final favoritesNotifier = ref.read(favoritesProvider.notifier);
    final isFav = state.weather != null && ref.watch(favoritesProvider).any(
          (f) => f.cityName.toLowerCase() == state.weather!.cityName.toLowerCase(),
        );

    return Scaffold(
      // The search bar sits at the top, above where the keyboard covers -
      // nothing on this screen needs to shift when it opens.
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('WeatherNow'),
        actions: [
          if (state.status == WeatherStatus.success && state.weather != null)
            IconButton(
              icon: Icon(isFav ? Icons.star : Icons.star_border, color: isFav ? Colors.amber : null),
              onPressed: () {
                final city = state.weather!.cityName;
                if (isFav) {
                  favoritesNotifier.remove(city);
                } else {
                  favoritesNotifier.add(city);
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          CitySearchBar(initialCity: _lastCity, onSubmittedCity: _search),
          Expanded(child: _buildBody(state)),
        ],
      ),
    );
  }

  Widget _buildBody(WeatherState state) {
    switch (state.status) {
      case WeatherStatus.initial:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Search for a city to see the current weather.', textAlign: TextAlign.center),
          ),
        );
      case WeatherStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case WeatherStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 12),
                // Never show raw exception text — Failure.message is already
                // a friendly, pre-mapped string (see core/error/failures.dart).
                Text(state.errorMessage ?? 'Something went wrong.', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref.read(weatherProvider.notifier).retry(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      case WeatherStatus.success:
        final items = <Widget>[
          if (state.weather != null) WeatherCard(weather: state.weather!),
          if (state.forecast != null) ForecastStrip(forecast: state.forecast!),
          const SizedBox(height: 24),
        ];
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => items[index],
        );
    }
  }
}
