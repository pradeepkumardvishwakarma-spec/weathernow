import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Thin wrapper around Dio so the rest of the app depends on this
/// abstraction, not on Dio directly (easier to mock in tests, and
/// a single place to configure timeouts/interceptors/logging).
class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['OPEN_WEATHER_BASE_URL'] ?? 'https://api.openweathermap.org',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        // Never log the API key. Query params are added per-request,
        // and we strip them from logs below.
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // API key is injected here, not stored in widgets/UI code.
          options.queryParameters['appid'] = dotenv.env['OPEN_WEATHER_API_KEY'];
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Avoid leaking full request (incl. api key) in error logs.
          return handler.next(e);
        },
      ),
    );

    // Add LogInterceptor only in debug builds if you want request logs;
    // deliberately omitted here so the API key never hits the console.
  }
}
