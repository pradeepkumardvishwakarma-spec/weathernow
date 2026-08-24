import '../../domain/entities/forecast_entity.dart';

class ForecastSlotModel extends ForecastSlotEntity {
  const ForecastSlotModel({
    required super.dateTime,
    required super.temperature,
    required super.description,
    required super.iconCode,
  });

  factory ForecastSlotModel.fromJson(Map<String, dynamic> json) => ForecastSlotModel(
        dateTime: DateTime.parse(json['dt_txt'] as String),
        temperature: (json['main']?['temp'] as num?)?.toDouble() ?? 0.0,
        description: (json['weather'] as List?)?.isNotEmpty == true
            ? (json['weather'][0]['description'] as String? ?? '')
            : '',
        iconCode: (json['weather'] as List?)?.isNotEmpty == true
            ? (json['weather'][0]['icon'] as String? ?? '01d')
            : '01d',
      );

  Map<String, dynamic> toHiveJson() => {
        'dateTime': dateTime.toIso8601String(),
        'temperature': temperature,
        'description': description,
        'iconCode': iconCode,
      };

  factory ForecastSlotModel.fromHiveJson(Map<dynamic, dynamic> json) => ForecastSlotModel(
        dateTime: DateTime.parse(json['dateTime'] as String),
        temperature: json['temperature'] as double,
        description: json['description'] as String,
        iconCode: json['iconCode'] as String,
      );
}

class ForecastModel extends ForecastEntity {
  const ForecastModel({
    required super.cityName,
    required super.dailyForecasts,
    required super.fetchedAt,
    super.isFromCache,
  });

  /// The OpenWeatherMap /forecast endpoint returns 3-hour slots for 5 days
  /// (40 entries). We group them by calendar date, pick the reading closest
  /// to midday as the "representative" reading for the forecast strip,
  /// and keep all slots for that day for the detail breakdown screen.
  factory ForecastModel.fromJson(Map<String, dynamic> json, {bool isFromCache = false}) {
    final cityName = json['city']?['name'] as String? ?? '';
    final list = (json['list'] as List?) ?? [];
    final slots = list.map((e) => ForecastSlotModel.fromJson(e as Map<String, dynamic>)).toList();

    final Map<String, List<ForecastSlotEntity>> byDate = {};
    for (final slot in slots) {
      final key = '${slot.dateTime.year}-${slot.dateTime.month}-${slot.dateTime.day}';
      byDate.putIfAbsent(key, () => []).add(slot);
    }

    final dailyForecasts = byDate.entries.take(5).map((entry) {
      final daySlots = entry.value;
      // Pick slot nearest to 12:00 as representative for the strip.
      final representative = daySlots.reduce(
        (a, b) => (a.dateTime.hour - 12).abs() <= (b.dateTime.hour - 12).abs() ? a : b,
      );
      final avgTemp = daySlots.map((s) => s.temperature).reduce((a, b) => a + b) / daySlots.length;
      return DailyForecastEntity(
        date: DateTime(daySlots.first.dateTime.year, daySlots.first.dateTime.month, daySlots.first.dateTime.day),
        avgTemperature: avgTemp,
        description: representative.description,
        iconCode: representative.iconCode,
        slots: daySlots,
      );
    }).toList();

    return ForecastModel(
      cityName: cityName,
      dailyForecasts: dailyForecasts,
      fetchedAt: DateTime.now(),
      isFromCache: isFromCache,
    );
  }

  Map<String, dynamic> toHiveJson() => {
        'cityName': cityName,
        'fetchedAt': fetchedAt.toIso8601String(),
        'dailyForecasts': dailyForecasts
            .map((d) => {
                  'date': d.date.toIso8601String(),
                  'avgTemperature': d.avgTemperature,
                  'description': d.description,
                  'iconCode': d.iconCode,
                  'slots': d.slots
                      .map((s) => ForecastSlotModel(
                            dateTime: s.dateTime,
                            temperature: s.temperature,
                            description: s.description,
                            iconCode: s.iconCode,
                          ).toHiveJson())
                      .toList(),
                })
            .toList(),
      };

  factory ForecastModel.fromHiveJson(Map<dynamic, dynamic> json) {
    final daily = (json['dailyForecasts'] as List).map((d) {
      final slots = (d['slots'] as List)
          .map((s) => ForecastSlotModel.fromHiveJson(s as Map<dynamic, dynamic>))
          .toList();
      return DailyForecastEntity(
        date: DateTime.parse(d['date'] as String),
        avgTemperature: d['avgTemperature'] as double,
        description: d['description'] as String,
        iconCode: d['iconCode'] as String,
        slots: slots,
      );
    }).toList();

    return ForecastModel(
      cityName: json['cityName'] as String,
      dailyForecasts: daily,
      fetchedAt: DateTime.parse(json['fetchedAt'] as String),
      isFromCache: true,
    );
  }
}
