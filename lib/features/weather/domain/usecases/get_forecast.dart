import 'package:dio/dio.dart' show CancelToken;
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/forecast_entity.dart';
import '../repositories/weather_repository.dart';

class GetForecast implements UseCase<ForecastEntity, GetForecastParams> {
  final WeatherRepository repository;
  GetForecast(this.repository);

  @override
  Future<Either<Failure, ForecastEntity>> call(GetForecastParams params) {
    return repository.getForecast(params.city, cancelToken: params.cancelToken);
  }
}

class GetForecastParams {
  final String city;
  final CancelToken? cancelToken;
  const GetForecastParams({required this.city, this.cancelToken});
}
