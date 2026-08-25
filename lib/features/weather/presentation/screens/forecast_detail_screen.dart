import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:weathernow/features/weather/domain/entities/forecast_entity.dart';
import 'package:weathernow/features/settings/presentation/providers/settings_provider.dart';
import 'package:weathernow/features/weather/presentation/widgets/weather_icon.dart';

/// Receives the already-fetched [DailyForecastEntity] via GoRouter's
/// `extra` — per the spec, going back to Home should NOT re-fetch
/// everything from scratch, so this screen never calls a use case.
class ForecastDetailScreen extends ConsumerWidget {
  final DailyForecastEntity day;
  const ForecastDetailScreen({super.key, required this.day});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final unit = settings.unit;

    // Bucket the 3-hour slots into morning / afternoon / evening.
    final morning = day.slots.where((s) => s.dateTime.hour >= 5 && s.dateTime.hour < 12).toList();
    final afternoon = day.slots.where((s) => s.dateTime.hour >= 12 && s.dateTime.hour < 17).toList();
    final evening = day.slots.where((s) => s.dateTime.hour >= 17 || s.dateTime.hour < 5).toList();

    // Flattened into one row list so ListView.builder can lazily build
    // only what's visible, instead of every ListTile (and its weather
    // icon fetch) all at once - matches the ListView.builder pattern
    // already used everywhere else in this app (forecast strip,
    // favorites list). One header row per non-empty section, followed
    // by that section's slot rows.
    final rows = <_ForecastRow>[
      if (morning.isNotEmpty) _ForecastRow.header('Morning'),
      ...morning.map(_ForecastRow.slot),
      if (afternoon.isNotEmpty) _ForecastRow.header('Afternoon'),
      ...afternoon.map(_ForecastRow.slot),
      if (evening.isNotEmpty) _ForecastRow.header('Evening'),
      ...evening.map(_ForecastRow.slot),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(intl.DateFormat.yMMMEd().format(day.date))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rows.length,
        itemBuilder: (context, index) {
          final row = rows[index];
          if (row.isHeader) {
            return Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Text(row.header!, style: Theme.of(context).textTheme.titleMedium),
            );
          }
          final s = row.slot!;
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: WeatherIcon(iconCode: s.iconCode, size: 44),
            title: Text(intl.DateFormat.Hm().format(s.dateTime)),
            subtitle: Text(s.description),
            trailing: Text('${convertTemp(s.temperature, unit).round()}${unitSuffix(unit)}'),
          );
        },
      ),
    );
  }
}

/// A single row in the flattened list - either a section header or one
/// forecast slot. Kept private/small since it only exists to let
/// ListView.builder address rows by index.
class _ForecastRow {
  final String? header;
  final ForecastSlotEntity? slot;
  const _ForecastRow._({this.header, this.slot});

  factory _ForecastRow.header(String title) => _ForecastRow._(header: title);
  factory _ForecastRow.slot(ForecastSlotEntity slot) => _ForecastRow._(slot: slot);

  bool get isHeader => header != null;
}
