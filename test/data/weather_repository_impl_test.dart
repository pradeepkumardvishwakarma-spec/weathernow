import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weathernow/core/error/exceptions.dart';
import 'package:weathernow/core/error/failures.dart';
import 'package:weathernow/core/network/network_info.dart';
import 'package:weathernow/features/weather/data/datasources/weather_local_datasource.dart';
import 'package:weathernow/features/weather/data/datasources/weather_remote_datasource.dart';
import 'package:weathernow/features/weather/data/models/weather_model.dart';
import 'package:weathernow/features/weather/data/repositories/weather_repository_impl.dart';

class MockRemoteDataSource extends Mock implements WeatherRemoteDataSource {}

class MockLocalDataSource extends Mock implements WeatherLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
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
}
