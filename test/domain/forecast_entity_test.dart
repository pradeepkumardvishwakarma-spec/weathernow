import 'package:flutter_test/flutter_test.dart';
import 'package:weathernow/features/weather/domain/entities/forecast_entity.dart';

ForecastSlotEntity _slotAt(int hour) => ForecastSlotEntity(
      dateTime: DateTime(2026, 1, 15, hour),
      temperature: 20,
      description: 'clear sky',
      iconCode: '01d',
    );

void main() {
  group('DailyForecastEntity.sectionsByTimeOfDay', () {
    test('groups a full day into Night, Morning, Afternoon, Evening in that order', () {
      final day = DailyForecastEntity(
        date: DateTime(2026, 1, 15),
        avgTemperature: 20,
        description: 'clear sky',
        iconCode: '01d',
        slots: [0, 3, 6, 9, 12, 15, 18, 21].map(_slotAt).toList(),
      );

      final sections = day.sectionsByTimeOfDay;

      expect(sections.map((s) => s.label).toList(), ['Night', 'Morning', 'Afternoon', 'Evening']);
      expect(sections[0].slots.map((s) => s.dateTime.hour), [0, 3]);
      expect(sections[1].slots.map((s) => s.dateTime.hour), [6, 9]);
      expect(sections[2].slots.map((s) => s.dateTime.hour), [12, 15]);
      expect(sections[3].slots.map((s) => s.dateTime.hour), [18, 21]);
    });

    test('respects the exact hour boundaries between sections', () {
      final day = DailyForecastEntity(
        date: DateTime(2026, 1, 15),
        avgTemperature: 20,
        description: 'clear sky',
        iconCode: '01d',
        slots: [4, 5, 11, 12, 16, 17].map(_slotAt).toList(),
      );

      final sections = day.sectionsByTimeOfDay;

      expect(sections[0].label, 'Night');
      expect(sections[0].slots.single.dateTime.hour, 4); // 04:xx is still Night
      expect(sections[1].label, 'Morning');
      expect(sections[1].slots.map((s) => s.dateTime.hour), [5, 11]); // 05:00 and 11:xx are Morning
      expect(sections[2].label, 'Afternoon');
      expect(sections[2].slots.map((s) => s.dateTime.hour), [12, 16]); // 12:00 and 16:xx are Afternoon
      expect(sections[3].label, 'Evening');
      expect(sections[3].slots.single.dateTime.hour, 17); // 17:00 is Evening
    });

    test('omits a section entirely when it has no slots (a partial day)', () {
      // e.g. "today", fetched mid-afternoon - no Night/Morning slots exist yet.
      final day = DailyForecastEntity(
        date: DateTime(2026, 1, 15),
        avgTemperature: 20,
        description: 'clear sky',
        iconCode: '01d',
        slots: [12, 15, 18, 21].map(_slotAt).toList(),
      );

      final sections = day.sectionsByTimeOfDay;

      expect(sections.map((s) => s.label).toList(), ['Afternoon', 'Evening']);
    });
  });
}
