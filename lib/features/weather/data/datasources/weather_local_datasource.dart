import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

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
    return WeatherModel.fromHiveJson(Map<dynamic, dynamic>.from(raw as Map));
  }

  @override
  Future<void> cacheWeather(String city, WeatherModel model) async {
    await _box.put(_weatherKey(city), model.toHiveJson());
  }

  @override
  Future<ForecastModel> getCachedForecast(String city) async {
    final raw = _box.get(_forecastKey(city));
    if (raw == null) throw CacheException();
    return ForecastModel.fromHiveJson(Map<dynamic, dynamic>.from(raw as Map));
  }

  @override
  Future<void> cacheForecast(String city, ForecastModel model) async {
    await _box.put(_forecastKey(city), model.toHiveJson());
  }
}
