import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart' show CancelToken;
import '../../../../core/error/failures.dart';
import '../entities/weather_entity.dart';
import '../entities/forecast_entity.dart';

/// Domain-layer contract. The presentation layer (via use cases)
/// only ever talks to this interface — never to Dio or Hive directly.
/// This is what makes the layer swappable/testable (mock this in tests).
abstract class WeatherRepository {
  Future<Either<Failure, WeatherEntity>> getCurrentWeather(
    String city, {
    CancelToken? cancelToken,
  });

  Future<Either<Failure, ForecastEntity>> getForecast(
    String city, {
    CancelToken? cancelToken,
  });
}
