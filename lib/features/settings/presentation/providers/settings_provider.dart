import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weathernow/core/di/injection_container.dart';
import 'package:weathernow/features/settings/domain/entities/settings_entity.dart';
import 'package:weathernow/features/settings/domain/repositories/settings_repository.dart';

/// Loaded eagerly at app start (see main.dart) so every screen can
/// `ref.watch(settingsProvider)` and rebuild instantly when the unit
/// toggle flips — no manual refresh required anywhere.
class SettingsNotifier extends StateNotifier<SettingsEntity> {
  final SettingsRepository repository;
  SettingsNotifier(this.repository) : super(const SettingsEntity());

  // Not part of SettingsEntity/state on purpose - it's read once by the
  // Search screen at startup, not watched reactively, so it shouldn't
  // trigger a rebuild of every settingsProvider listener when it changes.
  String? _lastCity;
  String? get lastCity => _lastCity;

  Future<void> load() async {
    state = await repository.getSettings();
    _lastCity = await repository.getLastCity();
  }

  Future<void> toggleUnit() async {
    final newUnit = state.unit == TemperatureUnit.celsius
        ? TemperatureUnit.fahrenheit
        : TemperatureUnit.celsius;
    await repository.setUnit(newUnit);
    state = SettingsEntity(unit: newUnit);
  }

  // Only ever call this after a search actually succeeds (fresh fetch or
  // a successful cache fallback) - never on a failed search, so a bad
  // query can't overwrite a perfectly good previous "last city."
  Future<void> saveLastCity(String city) async {
    _lastCity = city;
    await repository.setLastCity(city);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsEntity>((ref) {
  return SettingsNotifier(sl<SettingsRepository>());
});

/// Helper used by any widget displaying a temperature so the
/// Celsius<->Fahrenheit conversion lives in exactly one place.
double convertTemp(double celsius, TemperatureUnit unit) {
  if (unit == TemperatureUnit.fahrenheit) {
    return celsius * 9 / 5 + 32;
  }
  return celsius;
}

String unitSuffix(TemperatureUnit unit) => unit == TemperatureUnit.fahrenheit ? '°F' : '°C';
