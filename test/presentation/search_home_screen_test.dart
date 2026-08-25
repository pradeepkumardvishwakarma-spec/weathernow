import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weathernow/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:weathernow/features/favorites/domain/usecases/manage_favorites.dart';
import 'package:weathernow/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:weathernow/features/settings/domain/repositories/settings_repository.dart';
import 'package:weathernow/features/settings/presentation/providers/settings_provider.dart';
import 'package:weathernow/features/weather/domain/repositories/weather_repository.dart';
import 'package:weathernow/features/weather/domain/usecases/get_current_weather.dart';
import 'package:weathernow/features/weather/domain/usecases/get_forecast.dart';
import 'package:weathernow/features/weather/presentation/providers/weather_provider.dart';
import 'package:weathernow/features/weather/presentation/providers/weather_state.dart';
import 'package:weathernow/features/weather/presentation/screens/search_home_screen.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

// search_home_screen.dart reads favoritesProvider unconditionally at the
// top of build() (for the star-icon state) regardless of which
// WeatherState is being tested - so it needs overriding here too, same
// reasoning as FakeWeatherNotifier: avoid real DI/GetIt entirely.
// Overriding refresh() to a no-op means the mock use cases below are
// constructed but never actually invoked.
class FakeFavoritesNotifier extends FavoritesNotifier {
  FakeFavoritesNotifier()
      : super(
          getFavorites: GetFavorites(MockFavoritesRepository()),
          addFavoriteUseCase: AddFavorite(MockFavoritesRepository()),
          removeFavoriteUseCase: RemoveFavorite(MockFavoritesRepository()),
        );

  @override
  Future<void> refresh() async {}
}

// A fake notifier so the widget test doesn't touch DI/Hive/Dio at all —
// it only checks that a given WeatherState renders the right UI.
// getCurrentWeather/getForecast are never actually called here (searchCity
// and retry are both overridden to no-ops below), so a mock with no
// stubs configured is a safe, harmless placeholder — unlike
// `throw UnimplementedError()` passed directly as an argument, which
// evaluates eagerly and throws immediately on construction, before the
// constructor body even runs.
class FakeWeatherNotifier extends WeatherNotifier {
  FakeWeatherNotifier(WeatherState initial)
      : super(
          getCurrentWeather: GetCurrentWeather(MockWeatherRepository()),
          getForecast: GetForecast(MockWeatherRepository()),
        ) {
    state = initial;
  }

  @override
  Future<bool> searchCity(String city) async => false;

  @override
  void retry() {}
}

void main() {
  testWidgets('shows a friendly retry message, never a raw exception string', (tester) async {
    const errorState = WeatherState(
      status: WeatherStatus.error,
      errorMessage: "We couldn't find that city. Check the spelling and try again.",
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weatherProvider.overrideWith((ref) => FakeWeatherNotifier(errorState)),
          favoritesProvider.overrideWith((ref) => FakeFavoritesNotifier()),
          // SearchHomeScreen.initState() reads settingsProvider.notifier.lastCity —
          // override with a mocked repository so it never touches real DI/Hive.
          // The default `null` lastCity is exactly what this test wants (no
          // auto-search on open).
          settingsProvider.overrideWith((ref) => SettingsNotifier(MockSettingsRepository())),
        ],
        child: const MaterialApp(home: SearchHomeScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("We couldn't find that city. Check the spelling and try again."), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    // Guard against ever regressing to raw error text leaking through.
    expect(find.textContaining('Exception'), findsNothing);
    expect(find.textContaining('DioException'), findsNothing);
  });
}
