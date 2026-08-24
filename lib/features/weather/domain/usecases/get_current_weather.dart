import 'package:dartz/dartz.dart';
import 'package:weathernow/core/error/failures.dart';
import 'package:weathernow/core/usecase/usecase.dart';
import 'package:weathernow/core/usecase/cancellation_token.dart';
import 'package:weathernow/features/weather/domain/entities/weather_entity.dart';
import 'package:weathernow/features/weather/domain/repositories/weather_repository.dart';

class GetCurrentWeather implements UseCase<WeatherEntity, GetCurrentWeatherParams> {
  final WeatherRepository repository;
  GetCurrentWeather(this.repository);

  @override
  Future<Either<Failure, WeatherEntity>> call(GetCurrentWeatherParams params) {
    return repository.getCurrentWeather(params.city, cancelToken: params.cancelToken);
  }
}

class GetCurrentWeatherParams {
  final String city;
  final CancellationToken? cancelToken;
  const GetCurrentWeatherParams({required this.city, this.cancelToken});
}
