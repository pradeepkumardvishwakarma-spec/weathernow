import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weathernow/features/weather/presentation/providers/weather_provider.dart';
import 'package:weathernow/features/weather/presentation/providers/weather_state.dart';
import 'package:weathernow/features/weather/presentation/screens/search_home_screen.dart';

// A fake notifier so the widget test doesn't touch DI/Hive/Dio at all —
// it only checks that a given WeatherState renders the right UI.
class FakeWeatherNotifier extends WeatherNotifier {
  FakeWeatherNotifier(WeatherState initial)
      : super(getCurrentWeather: throw UnimplementedError(), getForecast: throw UnimplementedError()) {
    state = initial;
  }

  @override
  Future<void> searchCity(String city) async {}

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
