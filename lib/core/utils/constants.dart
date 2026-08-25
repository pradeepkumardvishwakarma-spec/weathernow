class HiveBoxes {
  static const weatherCache = 'weather_cache_box';
  static const favorites = 'favorites_box';
  static const settings = 'settings_box';
}

class SettingsKeys {
  static const unit = 'temperature_unit'; // 'metric' (C) or 'imperial' (F)
  static const lastCity = 'last_searched_city';
}

class ApiEndpoints {
  static const currentWeather = '/data/2.5/weather';
  static const forecast = '/data/2.5/forecast';
}

class EnvKeys {
  static const apiKey = 'OPEN_WEATHER_API_KEY';
  static const baseUrl = 'OPEN_WEATHER_BASE_URL';
  static const fallbackBaseUrl = 'https://api.openweathermap.org';
  static const envFilePath = 'assets/env/.env';
}

class WeatherAssets {
  static const iconBaseUrl = 'https://openweathermap.org/img/wn';
}

/// Route paths - defined once here so app_router.dart, app_shell.dart, and
/// anywhere that navigates all reference the same strings instead of typing
/// path literals that can silently drift out of sync with each other.
class AppRoutes {
  static const home = '/';
  static const favorites = '/favorites';
  static const settings = '/settings';
  static const forecastDetail = '/forecast-detail';

  // GoRoute path pattern (with the param placeholder) vs. the built path
  // for actually navigating to one - two different strings, both needed.
  static const cityPattern = '/city/:cityName';
  static String city(String cityName) => '/city/$cityName';
}
