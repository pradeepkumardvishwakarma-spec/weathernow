import 'package:weathernow/features/weather/domain/entities/weather_entity.dart';

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

  // Same null-safe-with-fallback approach as fromJson above — a cached entry
  // can be malformed too (schema drift across app versions, corrupted data),
  // and a hard cast throwing here would otherwise escape uncaught.
  factory WeatherModel.fromHiveJson(Map<dynamic, dynamic> json) => WeatherModel(
        cityName: json['cityName'] as String? ?? '',
        temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
        description: json['description'] as String? ?? '',
        iconCode: json['iconCode'] as String? ?? '01d',
        humidity: (json['humidity'] as num?)?.toInt() ?? 0,
        windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 0.0,
        fetchedAt: DateTime.tryParse(json['fetchedAt'] as String? ?? '') ?? DateTime.now(),
        isFromCache: true,
      );
}
