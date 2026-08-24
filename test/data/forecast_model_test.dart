import 'package:flutter_test/flutter_test.dart';
import 'package:weathernow/features/weather/data/models/forecast_model.dart';

void main() {
  test('groups 3-hour slots into daily buckets, capped at 5 days', () {
    // Build a fake API response: 2 days worth of 3-hour slots (8 slots/day).
    final list = <Map<String, dynamic>>[];
    for (var day = 1; day <= 2; day++) {
      for (var hour = 0; hour < 24; hour += 3) {
        list.add({
          'dt_txt': '2026-01-0${day.toString()} ${hour.toString().padLeft(2, '0')}:00:00',
          'main': {'temp': 15.0 + hour},
          'weather': [
            {'description': 'clear sky', 'icon': '01d'}
          ],
        });
      }
    }

    final json = {
      'city': {'name': 'London'},
      'list': list,
    };

    final model = ForecastModel.fromJson(json);

    expect(model.cityName, 'London');
    expect(model.dailyForecasts.length, 2);
    // Each day should carry all its 3-hour slots for the detail breakdown.
    expect(model.dailyForecasts.first.slots.length, 8);
    // Representative reading should be the one closest to noon (12:00).
    expect(model.dailyForecasts.first.slots.any((s) => s.dateTime.hour == 12), true);
  });

  test('caps output at 5 days even if API returns more', () {
    final list = <Map<String, dynamic>>[];
    for (var day = 1; day <= 7; day++) {
      list.add({
        'dt_txt': '2026-01-0${day.toString()} 12:00:00',
        'main': {'temp': 20.0},
        'weather': [
          {'description': 'clear sky', 'icon': '01d'}
        ],
      });
    }
    final model = ForecastModel.fromJson({
      'city': {'name': 'Paris'},
      'list': list,
    });

    expect(model.dailyForecasts.length, 5);
  });
}
