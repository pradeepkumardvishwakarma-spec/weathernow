import 'package:equatable/equatable.dart';

/// A single 3-hour reading from the /forecast endpoint.
class ForecastSlotEntity extends Equatable {
  final DateTime dateTime;
  final double temperature;
  final String description;
  final String iconCode;

  const ForecastSlotEntity({
    required this.dateTime,
    required this.temperature,
    required this.description,
    required this.iconCode,
  });

  @override
  List<Object?> get props => [dateTime, temperature, description, iconCode];
}

/// One day of forecast: a representative "daily" reading (for the strip)
/// plus all the raw 3-hour slots that fall on that day (for the detail
/// screen's morning/afternoon/evening breakdown).
class DailyForecastEntity extends Equatable {
  final DateTime date;
  final double avgTemperature;
  final String description;
  final String iconCode;
  final List<ForecastSlotEntity> slots;

  const DailyForecastEntity({
    required this.date,
    required this.avgTemperature,
    required this.description,
    required this.iconCode,
    required this.slots,
  });

  @override
  List<Object?> get props => [date, avgTemperature, description, iconCode, slots];
}

class ForecastEntity extends Equatable {
  final String cityName;
  final List<DailyForecastEntity> dailyForecasts; // next 5 days
  final DateTime fetchedAt;
  final bool isFromCache;

  const ForecastEntity({
    required this.cityName,
    required this.dailyForecasts,
    required this.fetchedAt,
    this.isFromCache = false,
  });

  @override
  List<Object?> get props => [cityName, dailyForecasts, fetchedAt, isFromCache];
}
