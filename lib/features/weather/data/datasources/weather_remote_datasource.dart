import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
    final statusCode = e.response?.statusCode;
    if (statusCode == 404) {
      return CityNotFoundException();
    }
    // Dio's own e.message is a technical diagnostic string (and can echo
    // the request URL, including the API key query param) - never forward
    // it to a user-facing Failure. Log only the status code, dev-build only.
    if (kDebugMode) {
      debugPrint('Weather API request failed with status $statusCode');
    }
    if (statusCode == 401) {
      return ServerException("Couldn't connect to the weather service. Please try again later.");
    }
    return ServerException();
  }
}
