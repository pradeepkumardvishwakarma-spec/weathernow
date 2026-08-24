import 'package:hive/hive.dart';
import 'package:weathernow/core/error/exceptions.dart';
import 'package:weathernow/core/utils/constants.dart';
import 'package:weathernow/features/weather/data/models/weather_model.dart';
import 'package:weathernow/features/weather/data/models/forecast_model.dart';

abstract class WeatherLocalDataSource {
  Future<WeatherModel> getCachedWeather(String city);
  Future<void> cacheWeather(String city, WeatherModel model);

  Future<ForecastModel> getCachedForecast(String city);
  Future<void> cacheForecast(String city, ForecastModel model);
}

class WeatherLocalDataSourceImpl implements WeatherLocalDataSource {
  Box get _box => Hive.box(HiveBoxes.weatherCache);

  String _weatherKey(String city) => 'weather_${city.toLowerCase().trim()}';
  String _forecastKey(String city) => 'forecast_${city.toLowerCase().trim()}';

  @override
  Future<WeatherModel> getCachedWeather(String city) async {
    final raw = _box.get(_weatherKey(city));
    if (raw == null) throw CacheException();
    try {
      return WeatherModel.fromHiveJson(Map<dynamic, dynamic>.from(raw as Map));
    } catch (_) {
      // A malformed/corrupted cache entry should be treated exactly like "no
      // cache" so the repository's existing CacheException handling applies,
      // instead of an unrelated exception type escaping uncaught.
      throw CacheException();
    }
  }

  @override
  Future<void> cacheWeather(String city, WeatherModel model) async {
    await _box.put(_weatherKey(city), model.toHiveJson());
  }

  @override
  Future<ForecastModel> getCachedForecast(String city) async {
    final raw = _box.get(_forecastKey(city));
    if (raw == null) throw CacheException();
    try {
      return ForecastModel.fromHiveJson(Map<dynamic, dynamic>.from(raw as Map));
    } catch (_) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheForecast(String city, ForecastModel model) async {
    await _box.put(_forecastKey(city), model.toHiveJson());
  }
}
