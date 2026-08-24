import 'package:hive/hive.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';

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
}
