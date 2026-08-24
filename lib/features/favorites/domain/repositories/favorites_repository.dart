import 'package:weathernow/features/favorites/domain/entities/favorite_city_entity.dart';

abstract class FavoritesRepository {
  Future<List<FavoriteCityEntity>> getFavorites();
  Future<void> addFavorite(String city);
  Future<void> removeFavorite(String city);
  Future<bool> isFavorite(String city);
}
