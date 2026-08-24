import '../entities/favorite_city_entity.dart';
import '../repositories/favorites_repository.dart';

class GetFavorites {
  final FavoritesRepository repository;
  GetFavorites(this.repository);
  Future<List<FavoriteCityEntity>> call() => repository.getFavorites();
}

class AddFavorite {
  final FavoritesRepository repository;
  AddFavorite(this.repository);
  Future<void> call(String city) => repository.addFavorite(city);
}

class RemoveFavorite {
  final FavoritesRepository repository;
  RemoveFavorite(this.repository);
  Future<void> call(String city) => repository.removeFavorite(city);
}

class IsFavorite {
  final FavoritesRepository repository;
  IsFavorite(this.repository);
  Future<bool> call(String city) => repository.isFavorite(city);
}
