import 'package:hive/hive.dart';
import 'package:weathernow/core/utils/constants.dart';
import 'package:weathernow/features/settings/domain/entities/settings_entity.dart';
import 'package:weathernow/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  Box get _box => Hive.box(HiveBoxes.settings);

  @override
  Future<SettingsEntity> getSettings() async {
    final raw = _box.get(SettingsKeys.unit, defaultValue: 'metric') as String;
    return SettingsEntity(
      unit: raw == 'imperial' ? TemperatureUnit.fahrenheit : TemperatureUnit.celsius,
    );
  }

  @override
  Future<void> setUnit(TemperatureUnit unit) async {
    await _box.put(SettingsKeys.unit, unit == TemperatureUnit.fahrenheit ? 'imperial' : 'metric');
  }

  @override
  Future<String?> getLastCity() async => _box.get(SettingsKeys.lastCity) as String?;

  @override
  Future<void> setLastCity(String city) async {
    await _box.put(SettingsKeys.lastCity, city);
  }
}
