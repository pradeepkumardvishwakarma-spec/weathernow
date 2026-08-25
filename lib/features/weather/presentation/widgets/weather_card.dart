import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weathernow/core/theme/app_theme.dart';
import 'package:weathernow/features/weather/domain/entities/weather_entity.dart';
import 'package:weathernow/features/settings/presentation/providers/settings_provider.dart';
import 'package:weathernow/features/weather/presentation/widgets/weather_icon.dart';
import 'package:weathernow/core/utils/time_ago.dart';

class WeatherCard extends ConsumerWidget {
  final WeatherEntity weather;
  const WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final temp = convertTemp(weather.temperature, settings.unit);
    final suffix = unitSuffix(settings.unit);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (weather.isFromCache)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off, size: 16, color: AppTheme.warningColor),
                    const SizedBox(width: 6),
                    Text(
                      'Updated ${timeAgo(weather.fetchedAt)} · offline',
                      style: const TextStyle(color: AppTheme.warningColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(weather.cityName, style: Theme.of(context).textTheme.headlineSmall),
                    Text(
                      '${temp.round()}$suffix',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    Text(weather.description),
                  ],
                ),
                WeatherIcon(iconCode: weather.iconCode, size: 64),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.water_drop_outlined, size: 18, color: AppTheme.mutedColor),
                const SizedBox(width: 4),
                Text('${weather.humidity}%'),
                const SizedBox(width: 20),
                const Icon(Icons.air, size: 18, color: AppTheme.mutedColor),
                const SizedBox(width: 4),
                Text('${weather.windSpeed.toStringAsFixed(1)} m/s'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
