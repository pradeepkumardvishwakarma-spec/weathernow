import 'package:go_router/go_router.dart';
import 'package:weathernow/features/weather/presentation/screens/search_home_screen.dart';
import 'package:weathernow/features/weather/presentation/screens/forecast_detail_screen.dart';
import 'package:weathernow/features/weather/presentation/screens/city_weather_screen.dart';
import 'package:weathernow/features/weather/domain/entities/forecast_entity.dart';
import 'package:weathernow/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:weathernow/features/settings/presentation/screens/settings_screen.dart';
import 'package:weathernow/core/router/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        final index = switch (state.uri.path) {
          '/' => 0,
          '/favorites' => 1,
          '/settings' => 2,
          _ => 0,
        };
        return AppShell(currentIndex: index, child: child);
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SearchHomeScreen()),
        GoRoute(path: '/favorites', builder: (context, state) => const FavoritesScreen()),
        GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      ],
    ),
    // Pushed on top of the shell (keeps bottom nav out of the stack).
    GoRoute(
      path: '/forecast-detail',
      builder: (context, state) => ForecastDetailScreen(day: state.extra as DailyForecastEntity),
    ),
    GoRoute(
      path: '/city/:cityName',
      builder: (context, state) => CityWeatherScreen(cityName: state.pathParameters['cityName']!),
    ),
  ],
);
