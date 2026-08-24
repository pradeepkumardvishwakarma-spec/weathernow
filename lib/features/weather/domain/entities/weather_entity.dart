import 'package:equatable/equatable.dart';

class WeatherEntity extends Equatable {
  final String cityName;
  final double temperature; // stored in Celsius internally; UI converts for display
  final String description;
  final String iconCode;
  final int humidity;
  final double windSpeed;
  final DateTime fetchedAt; // used to compute "updated Xh ago" for offline mode
  final bool isFromCache;

  const WeatherEntity({
    required this.cityName,
    required this.temperature,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.fetchedAt,
    this.isFromCache = false,
  });

  @override
  List<Object?> get props =>
      [cityName, temperature, description, iconCode, humidity, windSpeed, fetchedAt, isFromCache];
}
