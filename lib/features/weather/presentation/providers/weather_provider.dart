import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/usecases/get_current_weather.dart';
import '../../domain/usecases/get_forecast.dart';
import 'weather_state.dart';

/// A StateNotifier per "session" of searching. It owns a CancelToken
/// so that if the user types a new city before the previous request
/// finishes, we cancel the in-flight one instead of racing them.
class WeatherNotifier extends StateNotifier<WeatherState> {
  final GetCurrentWeather getCurrentWeather;
  final GetForecast getForecast;
  CancelToken? _cancelToken;

  WeatherNotifier({
    required this.getCurrentWeather,
    required this.getForecast,
  }) : super(const WeatherState());

  Future<void> searchCity(String city) async {
    if (city.trim().isEmpty) return;

    // Cancel any in-flight request for a previous city before starting a new one.
    _cancelToken?.cancel('New search started');
    _cancelToken = CancelToken();

    state = state.copyWith(status: WeatherStatus.loading, lastQueriedCity: city);

    final weatherResult = await getCurrentWeather(
      GetCurrentWeatherParams(city: city, cancelToken: _cancelToken),
    );

    // If the request was cancelled (superseded by a newer search), do nothing —
    // the newer search's own call will update state.
    final cancelled = weatherResult.fold((f) => f.message.contains('cancelled'), (_) => false);
    if (cancelled) return;

    await weatherResult.fold(
      (failure) async {
        state = state.copyWith(status: WeatherStatus.error, errorMessage: failure.message);
      },
      (weather) async {
        final forecastResult = await getForecast(
          GetForecastParams(city: city, cancelToken: _cancelToken),
        );
        forecastResult.fold(
          (failure) {
            // Current weather succeeded but forecast failed — still show
            // what we have rather than blanking the whole screen.
            state = state.copyWith(status: WeatherStatus.success, weather: weather);
          },
          (forecast) {
            state = state.copyWith(
              status: WeatherStatus.success,
              weather: weather,
              forecast: forecast,
            );
          },
        );
      },
    );
  }

  void retry() {
    if (state.lastQueriedCity != null) {
      searchCity(state.lastQueriedCity!);
    }
  }

  @override
  void dispose() {
    _cancelToken?.cancel('Provider disposed');
    super.dispose();
  }
}

final weatherProvider = StateNotifierProvider.autoDispose<WeatherNotifier, WeatherState>((ref) {
  return WeatherNotifier(
    getCurrentWeather: sl<GetCurrentWeather>(),
    getForecast: sl<GetForecast>(),
  );
});
