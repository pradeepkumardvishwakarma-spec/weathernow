import 'package:dio/dio.dart' show CancelToken;
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/weather_entity.dart';
import '../repositories/weather_repository.dart';

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
  final CancelToken? cancelToken;
  const GetCurrentWeatherParams({required this.city, this.cancelToken});
}
