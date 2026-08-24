import 'package:hive/hive.dart';
import 'package:weathernow/core/utils/constants.dart';
import 'package:weathernow/features/favorites/domain/entities/favorite_city_entity.dart';

/// Favorites are stored as {lowercasedCityKey: {cityName, addedAt}} in a
/// single Hive box. The key is normalized so "London" and "london" don't
/// end up as two separate favorites; the original casing is kept in the
/// stored value for display, same pattern as WeatherLocalDataSource.
class FavoritesLocalDataSource {
  Box get _box => Hive.box(HiveBoxes.favorites);

  String _key(String city) => city.toLowerCase().trim();

  List<FavoriteCityEntity> getFavorites() {
    final entities = <FavoriteCityEntity>[];
    for (final key in _box.keys) {
      try {
        final raw = Map<dynamic, dynamic>.from(_box.get(key) as Map);
        entities.add(FavoriteCityEntity(
          cityName: raw['cityName'] as String,
          addedAt: DateTime.parse(raw['addedAt'] as String),
        ));
      } catch (_) {
        // A malformed entry shouldn't break the whole list — skip it.
      }
    }
    entities.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return entities;
  }

  Future<void> addFavorite(String city) async {
    await _box.put(_key(city), {
      'cityName': city.trim(),
      'addedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeFavorite(String city) async {
    await _box.delete(_key(city));
  }

  bool isFavorite(String city) => _box.containsKey(_key(city));
}
