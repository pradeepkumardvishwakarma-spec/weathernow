import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../weather/data/datasources/weather_local_datasource.dart';
import '../../../weather/domain/entities/weather_entity.dart';
import '../../../weather/domain/usecases/get_current_weather.dart';

/// Per the spec: favorites should "read from local cache first, refresh
/// in the background." This is intentionally different from the Home
/// screen (which is online-first, cache-as-fallback) — here we always
/// show cached data instantly (no spinner for a saved favorite), then
/// silently replace it once a fresh fetch completes.
class FavoritePreviewNotifier extends StateNotifier<AsyncValue<WeatherEntity>> {
  final String city;
  FavoritePreviewNotifier(this.city) : super(const AsyncValue.loading()) {
    _loadCacheThenRefresh();
  }

  Future<void> _loadCacheThenRefresh() async {
    try {
      final cached = await sl<WeatherLocalDataSource>().getCachedWeather(city);
      state = AsyncValue.data(cached);
    } catch (_) {
      // No cache yet — fall through to a real fetch below with a loading state.
    }

    final result = await sl<GetCurrentWeather>().call(GetCurrentWeatherParams(city: city));
    result.fold(
      (failure) {
        // If we already have cached data on screen, keep showing it
        // (with its own "isFromCache" flag) instead of surfacing an error.
        if (!state.hasValue) {
          state = AsyncValue.error(failure.message, StackTrace.current);
        }
      },
      (fresh) => state = AsyncValue.data(fresh),
    );
  }
}

final favoritePreviewProvider =
    StateNotifierProvider.family<FavoritePreviewNotifier, AsyncValue<WeatherEntity>, String>(
  (ref, city) => FavoritePreviewNotifier(city),
);
