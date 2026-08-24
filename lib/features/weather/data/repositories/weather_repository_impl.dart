import 'package:dartz/dartz.dart';
import 'package:weathernow/core/error/exceptions.dart';
import 'package:weathernow/core/usecase/cancellation_token.dart';
import 'package:weathernow/core/error/failures.dart';
import 'package:weathernow/core/network/network_info.dart';
import 'package:weathernow/features/weather/domain/entities/weather_entity.dart';
import 'package:weathernow/features/weather/domain/entities/forecast_entity.dart';
import 'package:weathernow/features/weather/domain/repositories/weather_repository.dart';
import 'package:weathernow/features/weather/data/datasources/weather_remote_datasource.dart';
import 'package:weathernow/features/weather/data/datasources/weather_local_datasource.dart';

/// This is the single place that decides "online vs offline" and
/// translates data-layer Exceptions into domain-layer Failures.
/// Nothing above this layer (use cases, providers, widgets) ever
/// sees a DioException or a Hive error directly.
class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;
  final WeatherLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  WeatherRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, WeatherEntity>> getCurrentWeather(
    String city, {
    CancellationToken? cancelToken,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remote = await remoteDataSource.getCurrentWeather(city, cancelToken: cancelToken);
        await localDataSource.cacheWeather(city, remote);
        return Right(remote);
      } on RequestCancelledException {
        return const Left(RequestCancelledFailure());
      } on CityNotFoundException catch (e) {
        return Left(CityNotFoundFailure(e.message));
      } on TimeoutException catch (e) {
        return Left(TimeoutFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (_) {
        // Network dropped mid-request: fall back to cache instead of erroring.
        return _fallbackToWeatherCache(city);
      }
    } else {
      return _fallbackToWeatherCache(city);
    }
  }

  Future<Either<Failure, WeatherEntity>> _fallbackToWeatherCache(String city) async {
    try {
      final cached = await localDataSource.getCachedWeather(city);
      return Right(cached); // isFromCache=true already set by fromHiveJson
    } on CacheException {
      return const Left(NetworkFailure(
        'No internet connection, and no saved weather for this city yet.',
      ));
    }
  }

  @override
  Future<Either<Failure, WeatherEntity>> getCachedWeatherOnly(String city) async {
    try {
      final cached = await localDataSource.getCachedWeather(city);
      return Right(cached);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, ForecastEntity>> getForecast(
    String city, {
    CancellationToken? cancelToken,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remote = await remoteDataSource.getForecast(city, cancelToken: cancelToken);
        await localDataSource.cacheForecast(city, remote);
        return Right(remote);
      } on RequestCancelledException {
        return const Left(RequestCancelledFailure());
      } on CityNotFoundException catch (e) {
        return Left(CityNotFoundFailure(e.message));
      } on TimeoutException catch (e) {
        return Left(TimeoutFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (_) {
        return _fallbackToForecastCache(city);
      }
    } else {
      return _fallbackToForecastCache(city);
    }
  }

  Future<Either<Failure, ForecastEntity>> _fallbackToForecastCache(String city) async {
    try {
      final cached = await localDataSource.getCachedForecast(city);
      return Right(cached);
    } on CacheException {
      return const Left(NetworkFailure(
        'No internet connection, and no saved forecast for this city yet.',
      ));
    }
  }
}
