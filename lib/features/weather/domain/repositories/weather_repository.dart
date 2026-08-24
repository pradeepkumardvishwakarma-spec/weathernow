import 'package:dartz/dartz.dart';
import 'package:weathernow/core/error/failures.dart';
import 'package:weathernow/core/usecase/cancellation_token.dart';
import 'package:weathernow/features/weather/domain/entities/weather_entity.dart';
import 'package:weathernow/features/weather/domain/entities/forecast_entity.dart';

/// Domain-layer contract. The presentation layer (via use cases)
/// only ever talks to this interface — never to Dio or Hive directly.
/// This is what makes the layer swappable/testable (mock this in tests).
abstract class WeatherRepository {
  Future<Either<Failure, WeatherEntity>> getCurrentWeather(
    String city, {
    CancellationToken? cancelToken,
  });

  Future<Either<Failure, ForecastEntity>> getForecast(
    String city, {
    CancellationToken? cancelToken,
  });

  /// Cache-only read — never touches the network. Used by callers (e.g.
  /// Favorites' cache-first preview) that want the last known reading
  /// instantly without triggering an online fetch.
  Future<Either<Failure, WeatherEntity>> getCachedWeatherOnly(String city);
}
