import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weathernow/core/di/injection_container.dart';
import 'package:weathernow/features/favorites/domain/entities/favorite_city_entity.dart';
import 'package:weathernow/features/favorites/domain/usecases/manage_favorites.dart';

class FavoritesNotifier extends StateNotifier<List<FavoriteCityEntity>> {
  final GetFavorites getFavorites;
  final AddFavorite addFavoriteUseCase;
  final RemoveFavorite removeFavoriteUseCase;

  FavoritesNotifier({
    required this.getFavorites,
    required this.addFavoriteUseCase,
    required this.removeFavoriteUseCase,
  }) : super([]) {
    refresh();
  }

  Future<void> refresh() async {
    state = await getFavorites();
  }

  Future<void> add(String city) async {
    await addFavoriteUseCase(city);
    await refresh();
  }

  Future<void> remove(String city) async {
    await removeFavoriteUseCase(city);
    await refresh();
  }

  bool contains(String city) => state.any((f) => f.matchesCityName(city));
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<FavoriteCityEntity>>((ref) {
  return FavoritesNotifier(
    getFavorites: sl<GetFavorites>(),
    addFavoriteUseCase: sl<AddFavorite>(),
    removeFavoriteUseCase: sl<RemoveFavorite>(),
  );
});
