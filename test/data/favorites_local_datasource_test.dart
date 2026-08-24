import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:weathernow/core/utils/constants.dart';
import 'package:weathernow/features/favorites/data/datasources/favorites_local_datasource.dart';

// FavoritesLocalDataSource opens Hive.box(...) internally rather than
// receiving a Box via constructor injection, so it can't be tested against
// a mock the way WeatherRepositoryImpl is. Instead, point Hive at a real
// temporary directory for the duration of these tests - no extra package
// needed, just Hive.init(path) instead of Hive.initFlutter().
void main() {
  late Directory tempDir;
  late FavoritesLocalDataSource datasource;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('favorites_test');
    Hive.init(tempDir.path);
    await Hive.openBox(HiveBoxes.favorites);
    datasource = FavoritesLocalDataSource();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('a malformed entry is skipped instead of breaking the whole list', () async {
    final box = Hive.box(HiveBoxes.favorites);
    await box.put('london', {'cityName': 'London', 'addedAt': DateTime.now().toIso8601String()});
    // Simulates a corrupted/old-format entry - a raw string instead of the expected Map.
    await box.put('corrupted', 'not-a-map-anymore');

    final favorites = datasource.getFavorites();

    expect(favorites.length, 1);
    expect(favorites.first.cityName, 'London');
  });

  test('city keys are normalized to lowercase so casing does not create duplicates', () async {
    await datasource.addFavorite('London');
    await datasource.addFavorite('london'); // same city, different casing

    final favorites = datasource.getFavorites();

    expect(favorites.length, 1);
  });

  test('isFavorite is case-insensitive', () async {
    await datasource.addFavorite('Paris');

    expect(datasource.isFavorite('paris'), true);
    expect(datasource.isFavorite('PARIS'), true);
  });

  test('removeFavorite deletes regardless of casing used to add it', () async {
    await datasource.addFavorite('Tokyo');
    await datasource.removeFavorite('tokyo');

    expect(datasource.getFavorites(), isEmpty);
  });
}
