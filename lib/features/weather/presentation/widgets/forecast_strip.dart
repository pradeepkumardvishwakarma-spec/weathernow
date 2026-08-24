import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:go_router/go_router.dart';
import 'package:weathernow/features/weather/domain/entities/forecast_entity.dart';
import 'package:weathernow/features/weather/presentation/widgets/weather_icon.dart';

/// ListView.builder here means only the visible day-cards are built/laid
/// out at any time (lazy build), rather than inflating all 5 up front —
/// matters more once this is a longer list, and keeps the pattern
/// consistent with how Favorites (a longer, growing list) is built.
class ForecastStrip extends StatelessWidget {
  final ForecastEntity forecast;
  const ForecastStrip({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: forecast.dailyForecasts.length,
        itemBuilder: (context, index) {
          final day = forecast.dailyForecasts[index];
          return GestureDetector(
            onTap: () => context.push('/forecast-detail', extra: day),
            child: Container(
              width: 90,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(intl.DateFormat.E().format(day.date), style: const TextStyle(fontWeight: FontWeight.w600)),
                  WeatherIcon(iconCode: day.iconCode, size: 36),
                  Text('${day.avgTemperature.round()}°'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
