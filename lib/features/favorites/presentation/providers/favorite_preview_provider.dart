import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weathernow/core/di/injection_container.dart';
import 'package:weathernow/features/weather/domain/entities/weather_entity.dart';
import 'package:weathernow/features/weather/domain/usecases/get_cached_weather.dart';
import 'package:weathernow/features/weather/domain/usecases/get_current_weather.dart';

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
    final cachedResult = await sl<GetCachedWeather>().call(city);
    cachedResult.fold(
      (_) {}, // No cache yet — fall through to a real fetch below with a loading state.
      (cached) => state = AsyncValue.data(cached),
    );

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
