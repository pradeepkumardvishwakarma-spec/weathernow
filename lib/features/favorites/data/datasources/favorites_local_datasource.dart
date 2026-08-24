import 'package:hive/hive.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/favorite_city_entity.dart';

/// Favorites are stored as {cityNameLower: isoDateAdded} in a single
/// Hive box — simple, fast, and trivially serializable.
class FavoritesLocalDataSource {
  Box get _box => Hive.box(HiveBoxes.favorites);

  List<FavoriteCityEntity> getFavorites() {
    return _box.keys.map((key) {
      final addedAt = DateTime.parse(_box.get(key) as String);
      return FavoriteCityEntity(cityName: key as String, addedAt: addedAt);
    }).toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
  }

  Future<void> addFavorite(String city) async {
    await _box.put(city.trim(), DateTime.now().toIso8601String());
  }

  Future<void> removeFavorite(String city) async {
    await _box.delete(city.trim());
  }

  bool isFavorite(String city) => _box.containsKey(city.trim());
}
