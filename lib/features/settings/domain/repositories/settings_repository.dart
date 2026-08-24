import '../entities/settings_entity.dart';

abstract class SettingsRepository {
  Future<SettingsEntity> getSettings();
  Future<void> setUnit(TemperatureUnit unit);
}
