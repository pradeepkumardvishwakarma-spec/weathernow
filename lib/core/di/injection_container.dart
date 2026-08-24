import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';

import '../network/dio_client.dart';
import '../network/network_info.dart';

import '../../features/weather/data/datasources/weather_remote_datasource.dart';
import '../../features/weather/data/datasources/weather_local_datasource.dart';
import '../../features/weather/data/repositories/weather_repository_impl.dart';
import '../../features/weather/domain/repositories/weather_repository.dart';
import '../../features/weather/domain/usecases/get_current_weather.dart';
import '../../features/weather/domain/usecases/get_forecast.dart';

import '../../features/favorites/data/datasources/favorites_local_datasource.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorites_repository.dart';
import '../../features/favorites/domain/usecases/manage_favorites.dart';

import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';

/// Service locator (get_it). This is what gives us loose coupling:
/// - Widgets/providers depend on abstract repositories/use cases, never
///   on DioClient/Hive/ConnectivityPlus directly.
/// - Tests register fakes/mocks here instead of the real implementations.
final sl = GetIt.instance;

Future<void> initDependencyInjection() async {
  // --- Core ---
  sl.registerLazySingleton(() => DioClient().dio);
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // --- Weather feature ---
  sl.registerLazySingleton<WeatherRemoteDataSource>(() => WeatherRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<WeatherLocalDataSource>(() => WeatherLocalDataSourceImpl());
  sl.registerLazySingleton<WeatherRepository>(() => WeatherRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        networkInfo: sl(),
      ));
  sl.registerFactory(() => GetCurrentWeather(sl()));
  sl.registerFactory(() => GetForecast(sl()));

  // --- Favorites feature ---
  sl.registerLazySingleton(() => FavoritesLocalDataSource());
  sl.registerLazySingleton<FavoritesRepository>(() => FavoritesRepositoryImpl(sl()));
  sl.registerFactory(() => GetFavorites(sl()));
  sl.registerFactory(() => AddFavorite(sl()));
  sl.registerFactory(() => RemoveFavorite(sl()));
  sl.registerFactory(() => IsFavorite(sl()));

  // --- Settings feature ---
  sl.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl());
}
