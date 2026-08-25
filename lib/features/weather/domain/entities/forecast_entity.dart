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

  /// Groups [slots] into Night (00:00-04:59) / Morning (05:00-11:59) /
  /// Afternoon (12:00-16:59) / Evening (17:00-23:59), in that chronological
  /// order - so a full day reads 00:00 through 21:00 top to bottom. Only
  /// non-empty sections are included (e.g. a partial "today" fetched mid-
  /// afternoon won't show an empty Night/Morning header).
  List<TimeOfDaySection> get sectionsByTimeOfDay {
    final night = slots.where((s) => s.dateTime.hour < 5).toList();
    final morning = slots.where((s) => s.dateTime.hour >= 5 && s.dateTime.hour < 12).toList();
    final afternoon = slots.where((s) => s.dateTime.hour >= 12 && s.dateTime.hour < 17).toList();
    final evening = slots.where((s) => s.dateTime.hour >= 17).toList();

    return [
      if (night.isNotEmpty) TimeOfDaySection(label: 'Night', slots: night),
      if (morning.isNotEmpty) TimeOfDaySection(label: 'Morning', slots: morning),
      if (afternoon.isNotEmpty) TimeOfDaySection(label: 'Afternoon', slots: afternoon),
      if (evening.isNotEmpty) TimeOfDaySection(label: 'Evening', slots: evening),
    ];
  }

  @override
  List<Object?> get props => [date, avgTemperature, description, iconCode, slots];
}

/// One time-of-day group of slots, e.g. "Morning" with its 2-3 readings.
class TimeOfDaySection extends Equatable {
  final String label;
  final List<ForecastSlotEntity> slots;
  const TimeOfDaySection({required this.label, required this.slots});

  @override
  List<Object?> get props => [label, slots];
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
