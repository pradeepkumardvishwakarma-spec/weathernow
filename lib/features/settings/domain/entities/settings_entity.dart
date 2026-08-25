import 'package:equatable/equatable.dart';

enum TemperatureUnit { celsius, fahrenheit }

class SettingsEntity extends Equatable {
  final TemperatureUnit unit;
  const SettingsEntity({this.unit = TemperatureUnit.celsius});

  @override
  List<Object?> get props => [unit];
}

// Pure conversion rules for TemperatureUnit - no Flutter/UI dependency, so
// they belong alongside the enum they operate on, not in a presentation
// provider. Used by any widget displaying a temperature so the
// Celsius<->Fahrenheit conversion lives in exactly one place.
double convertTemp(double celsius, TemperatureUnit unit) {
  if (unit == TemperatureUnit.fahrenheit) {
    return celsius * 9 / 5 + 32;
  }
  return celsius;
}

String unitSuffix(TemperatureUnit unit) => unit == TemperatureUnit.fahrenheit ? '°F' : '°C';
