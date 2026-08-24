import 'package:weathernow/features/favorites/domain/entities/favorite_city_entity.dart';
import 'package:weathernow/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:weathernow/features/favorites/data/datasources/favorites_local_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource localDataSource;
  FavoritesRepositoryImpl(this.localDataSource);

  @override
  Future<List<FavoriteCityEntity>> getFavorites() async => localDataSource.getFavorites();

  @override
  Future<void> addFavorite(String city) => localDataSource.addFavorite(city);

  @override
  Future<void> removeFavorite(String city) => localDataSource.removeFavorite(city);

  @override
  Future<bool> isFavorite(String city) async => localDataSource.isFavorite(city);
}
