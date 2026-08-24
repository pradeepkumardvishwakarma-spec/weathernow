import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/constants.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getCurrentWeather(String city, {CancelToken? cancelToken});
  Future<ForecastModel> getForecast(String city, {CancelToken? cancelToken});
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final Dio dio;
  WeatherRemoteDataSourceImpl(this.dio);

  @override
  Future<WeatherModel> getCurrentWeather(String city, {CancelToken? cancelToken}) async {
    try {
      final response = await dio.get(
        ApiEndpoints.currentWeather,
        queryParameters: {'q': city, 'units': 'metric'},
        cancelToken: cancelToken,
      );
      return WeatherModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<ForecastModel> getForecast(String city, {CancelToken? cancelToken}) async {
    try {
      final response = await dio.get(
        ApiEndpoints.forecast,
        queryParameters: {'q': city, 'units': 'metric'},
        cancelToken: cancelToken,
      );
      return ForecastModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Exception _mapDioError(DioException e) {
    if (e.type == DioExceptionType.cancel) {
      return RequestCancelledException();
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return TimeoutException();
    }
    if (e.type == DioExceptionType.connectionError) {
      return NetworkException();
    }
    if (e.response?.statusCode == 404) {
      return CityNotFoundException();
    }
    return ServerException(e.message ?? 'Unknown server error');
  }
}
