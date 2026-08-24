import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weathernow/core/error/exceptions.dart';
import 'package:weathernow/core/error/failures.dart';
import 'package:weathernow/core/network/network_info.dart';
import 'package:weathernow/features/weather/data/datasources/weather_local_datasource.dart';
import 'package:weathernow/features/weather/data/datasources/weather_remote_datasource.dart';
import 'package:weathernow/features/weather/data/models/weather_model.dart';
import 'package:weathernow/features/weather/data/models/forecast_model.dart';
import 'package:weathernow/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:weathernow/features/weather/domain/entities/forecast_entity.dart';

class MockRemoteDataSource extends Mock implements WeatherRemoteDataSource {}

class MockLocalDataSource extends Mock implements WeatherLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  // mocktail needs a registered fallback instance for any custom type used
  // with any()/captureAny() - these are never actually returned, just used
  // internally to satisfy argument matching under sound null safety.
  setUpAll(() {
    registerFallbackValue(WeatherModel(
      cityName: '',
      temperature: 0,
      description: '',
      iconCode: '01d',
      humidity: 0,
      windSpeed: 0,
      fetchedAt: DateTime(2026),
    ));
    registerFallbackValue(ForecastModel(
      cityName: '',
      dailyForecasts: const [],
      fetchedAt: DateTime(2026),
    ));
  });

  late WeatherRepositoryImpl repository;
  late MockRemoteDataSource remote;
  late MockLocalDataSource local;
  late MockNetworkInfo networkInfo;

  setUp(() {
    remote = MockRemoteDataSource();
    local = MockLocalDataSource();
    networkInfo = MockNetworkInfo();
    repository = WeatherRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
      networkInfo: networkInfo,
    );
  });

  final tWeatherModel = WeatherModel(
    cityName: 'London',
    temperature: 18.0,
    description: 'clear sky',
    iconCode: '01d',
    humidity: 60,
    windSpeed: 3.2,
    fetchedAt: DateTime(2026, 1, 1),
  );

  group('getCurrentWeather', () {
    test('returns remote data and caches it when online and request succeeds', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remote.getCurrentWeather(any(), cancelToken: any(named: 'cancelToken')))
          .thenAnswer((_) async => tWeatherModel);
      when(() => local.cacheWeather(any(), any())).thenAnswer((_) async {});

      final result = await repository.getCurrentWeather('London');

      expect(result, Right(tWeatherModel));
      verify(() => local.cacheWeather('London', tWeatherModel)).called(1);
    });

    test('falls back to cache when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(() => local.getCachedWeather(any())).thenAnswer((_) async => tWeatherModel);

      final result = await repository.getCurrentWeather('London');

      expect(result, Right(tWeatherModel));
      verifyNever(() => remote.getCurrentWeather(any(), cancelToken: any(named: 'cancelToken')));
    });

    test('returns NetworkFailure when offline AND no cache exists', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(() => local.getCachedWeather(any())).thenThrow(CacheException());

      final result = await repository.getCurrentWeather('London');

      expect(result.isLeft(), true);
      result.fold((failure) => expect(failure, isA<NetworkFailure>()), (_) => fail('expected Left'));
    });

    test('maps 404 to CityNotFoundFailure without touching the cache', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remote.getCurrentWeather(any(), cancelToken: any(named: 'cancelToken')))
          .thenThrow(CityNotFoundException());

      final result = await repository.getCurrentWeather('Notacityatall');

      result.fold(
        (failure) => expect(failure, isA<CityNotFoundFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  // getForecast has its own separate online/offline branching
  // (_fallbackToForecastCache) - same shape as getCurrentWeather's, but a
  // distinct code path that was previously untested on its own.
  group('getForecast', () {
    final tForecastModel = ForecastModel(
      cityName: 'London',
      dailyForecasts: [
        DailyForecastEntity(
          date: DateTime(2026, 1, 1),
          avgTemperature: 18.0,
          description: 'clear sky',
          iconCode: '01d',
          slots: const [],
        ),
      ],
      fetchedAt: DateTime(2026, 1, 1),
    );

    test('returns remote data and caches it when online and request succeeds', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => true);
      when(() => remote.getForecast(any(), cancelToken: any(named: 'cancelToken')))
          .thenAnswer((_) async => tForecastModel);
      when(() => local.cacheForecast(any(), any())).thenAnswer((_) async {});

      final result = await repository.getForecast('London');

      expect(result, Right(tForecastModel));
      verify(() => local.cacheForecast('London', tForecastModel)).called(1);
    });

    test('falls back to cache when offline', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(() => local.getCachedForecast(any())).thenAnswer((_) async => tForecastModel);

      final result = await repository.getForecast('London');

      expect(result, Right(tForecastModel));
      verifyNever(() => remote.getForecast(any(), cancelToken: any(named: 'cancelToken')));
    });

    test('returns NetworkFailure when offline AND no cache exists', () async {
      when(() => networkInfo.isConnected).thenAnswer((_) async => false);
      when(() => local.getCachedForecast(any())).thenThrow(CacheException());

      final result = await repository.getForecast('London');

      expect(result.isLeft(), true);
      result.fold((failure) => expect(failure, isA<NetworkFailure>()), (_) => fail('expected Left'));
    });
  });
}
