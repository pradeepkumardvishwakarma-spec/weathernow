import '../../domain/entities/weather_entity.dart';

/// Data model = Entity + JSON (de)serialization.
/// Keeping this out of domain keeps domain framework-agnostic.
///
/// Persistence choice: rather than a generated Hive TypeAdapter
/// (which needs build_runner), we store a plain Map<String, dynamic>
/// in a Hive box keyed by city name. Simpler, no codegen step, and
/// easy to reason about/test. See WeatherLocalDataSource.
class WeatherModel extends WeatherEntity {
  const WeatherModel({
    required super.cityName,
    required super.temperature,
    required super.description,
    required super.iconCode,
    required super.humidity,
    required super.windSpeed,
    required super.fetchedAt,
    super.isFromCache,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json, {bool isFromCache = false}) {
    return WeatherModel(
      cityName: json['name'] as String? ?? '',
      // API returns Kelvin unless units param is set; we always request
      // metric (Celsius) from the API and convert to F only at display time.
      temperature: (json['main']?['temp'] as num?)?.toDouble() ?? 0.0,
      description: (json['weather'] as List?)?.isNotEmpty == true
          ? (json['weather'][0]['description'] as String? ?? '')
          : '',
      iconCode: (json['weather'] as List?)?.isNotEmpty == true
          ? (json['weather'][0]['icon'] as String? ?? '01d')
          : '01d',
      humidity: (json['main']?['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind']?['speed'] as num?)?.toDouble() ?? 0.0,
      fetchedAt: DateTime.now(),
      isFromCache: isFromCache,
    );
  }

  Map<String, dynamic> toHiveJson() => {
        'cityName': cityName,
        'temperature': temperature,
        'description': description,
        'iconCode': iconCode,
        'humidity': humidity,
        'windSpeed': windSpeed,
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  factory WeatherModel.fromHiveJson(Map<dynamic, dynamic> json) => WeatherModel(
        cityName: json['cityName'] as String,
        temperature: json['temperature'] as double,
        description: json['description'] as String,
        iconCode: json['iconCode'] as String,
        humidity: json['humidity'] as int,
        windSpeed: json['windSpeed'] as double,
        fetchedAt: DateTime.parse(json['fetchedAt'] as String),
        isFromCache: true,
      );
}
