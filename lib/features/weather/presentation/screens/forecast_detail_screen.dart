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

    return Scaffold(
      appBar: AppBar(title: Text(intl.DateFormat.yMMMEd().format(day.date))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(context, 'Morning', morning, unit),
          _buildSection(context, 'Afternoon', afternoon, unit),
          _buildSection(context, 'Evening', evening, unit),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List slots, unit) {
    if (slots.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...slots.map((s) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: WeatherIcon(iconCode: s.iconCode, size: 32),
                title: Text(intl.DateFormat.Hm().format(s.dateTime)),
                subtitle: Text(s.description),
                trailing: Text('${convertTemp(s.temperature, unit).round()}${unitSuffix(unit)}'),
              )),
        ],
      ),
    );
  }
}
