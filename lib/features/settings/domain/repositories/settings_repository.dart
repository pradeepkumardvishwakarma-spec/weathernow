import 'package:weathernow/features/settings/domain/entities/settings_entity.dart';

abstract class SettingsRepository {
  Future<SettingsEntity> getSettings();
  Future<void> setUnit(TemperatureUnit unit);

  // The Home screen's "last city you looked at" - stored alongside the
  // unit preference (same Hive box), but only ever set on a successful
  // search, never on a failed one.
  Future<String?> getLastCity();
  Future<void> setLastCity(String city);
}
