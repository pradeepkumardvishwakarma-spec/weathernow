import 'package:dartz/dartz.dart';
import 'package:weathernow/core/error/failures.dart';
import 'package:weathernow/core/usecase/usecase.dart';
import 'package:weathernow/core/usecase/cancellation_token.dart';
import 'package:weathernow/features/weather/domain/entities/forecast_entity.dart';
import 'package:weathernow/features/weather/domain/repositories/weather_repository.dart';

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
  final CancellationToken? cancelToken;
  const GetForecastParams({required this.city, this.cancelToken});
}
