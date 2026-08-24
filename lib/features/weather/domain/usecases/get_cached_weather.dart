import 'package:dartz/dartz.dart';
import 'package:weathernow/core/error/failures.dart';
import 'package:weathernow/core/usecase/usecase.dart';
import 'package:weathernow/features/weather/domain/entities/weather_entity.dart';
import 'package:weathernow/features/weather/domain/repositories/weather_repository.dart';

/// Cache-only read, never touches the network — lets a caller (e.g.
/// Favorites' preview) show the last known reading instantly through the
/// repository, instead of reaching into a datasource directly.
class GetCachedWeather implements UseCase<WeatherEntity, String> {
  final WeatherRepository repository;
  GetCachedWeather(this.repository);

  @override
  Future<Either<Failure, WeatherEntity>> call(String city) {
    return repository.getCachedWeatherOnly(city);
  }
}
