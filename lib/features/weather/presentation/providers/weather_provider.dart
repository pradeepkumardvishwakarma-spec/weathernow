import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weathernow/core/di/injection_container.dart';
import 'package:weathernow/core/usecase/cancellation_token.dart';
import 'package:weathernow/features/weather/domain/usecases/get_current_weather.dart';
import 'package:weathernow/features/weather/domain/usecases/get_forecast.dart';
import 'package:weathernow/features/weather/presentation/providers/weather_state.dart';

/// A StateNotifier per "session" of searching. It owns a CancellationToken
/// so that if the user types a new city before the previous request
/// finishes, we cancel the in-flight one instead of racing them.
class WeatherNotifier extends StateNotifier<WeatherState> {
  final GetCurrentWeather getCurrentWeather;
  final GetForecast getForecast;
  CancellationToken? _cancelToken;

  WeatherNotifier({
    required this.getCurrentWeather,
    required this.getForecast,
  }) : super(const WeatherState());

  /// Returns whether the search actually succeeded (fresh fetch or a
  /// successful cache fallback) - callers that persist "last searched
  /// city" should only do so when this is true, never on a failed search.
  Future<bool> searchCity(String city) async {
    if (city.trim().isEmpty) return false;

    // Cancel any in-flight request for a previous city before starting a new one.
    _cancelToken?.cancel();
    final cancelToken = CancellationToken();
    _cancelToken = cancelToken;

    state = state.copyWith(status: WeatherStatus.loading, lastQueriedCity: city);

    final weatherResult = await getCurrentWeather(
      GetCurrentWeatherParams(city: city, cancelToken: cancelToken),
    );

    // If this search was superseded by a newer one, do nothing — the newer
    // search's own call will update state.
    if (cancelToken.isCancelled) return false;

    return weatherResult.fold(
      (failure) async {
        state = state.copyWith(status: WeatherStatus.error, errorMessage: failure.message);
        return false;
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
        return true;
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
    _cancelToken?.cancel();
    super.dispose();
  }
}

final weatherProvider = StateNotifierProvider.autoDispose<WeatherNotifier, WeatherState>((ref) {
  return WeatherNotifier(
    getCurrentWeather: sl<GetCurrentWeather>(),
    getForecast: sl<GetForecast>(),
  );
});
