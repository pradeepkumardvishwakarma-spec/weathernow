import 'package:go_router/go_router.dart';
import 'package:weathernow/core/utils/constants.dart';
import 'package:weathernow/features/weather/presentation/screens/search_home_screen.dart';
import 'package:weathernow/features/weather/presentation/screens/forecast_detail_screen.dart';
import 'package:weathernow/features/weather/presentation/screens/city_weather_screen.dart';
import 'package:weathernow/features/weather/domain/entities/forecast_entity.dart';
import 'package:weathernow/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:weathernow/features/settings/presentation/screens/settings_screen.dart';
import 'package:weathernow/core/router/app_shell.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        final index = switch (state.uri.path) {
          AppRoutes.home => 0,
          AppRoutes.favorites => 1,
          AppRoutes.settings => 2,
          _ => 0,
        };
        return AppShell(currentIndex: index, child: child);
      },
      routes: [
        GoRoute(path: AppRoutes.home, builder: (context, state) => const SearchHomeScreen()),
        GoRoute(path: AppRoutes.favorites, builder: (context, state) => const FavoritesScreen()),
        GoRoute(path: AppRoutes.settings, builder: (context, state) => const SettingsScreen()),
      ],
    ),
    // Pushed on top of the shell (keeps bottom nav out of the stack).
    GoRoute(
      path: AppRoutes.forecastDetail,
      builder: (context, state) => ForecastDetailScreen(day: state.extra as DailyForecastEntity),
    ),
    GoRoute(
      path: AppRoutes.cityPattern,
      builder: (context, state) => CityWeatherScreen(cityName: state.pathParameters['cityName']!),
    ),
  ],
);
