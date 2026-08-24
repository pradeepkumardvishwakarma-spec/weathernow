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
