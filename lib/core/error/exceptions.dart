/// Exceptions are thrown from datasources (remote/local).
/// Repositories are the ONLY place that should catch these
/// and translate them into [Failure]s for the rest of the app.
class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server error']);
}

class CityNotFoundException implements Exception {
  final String message;
  CityNotFoundException([this.message = 'City not found']);
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException([this.message = 'Request timed out']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'No internet connection']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'No cached data found']);
}

class RequestCancelledException implements Exception {
  final String message;
  RequestCancelledException([this.message = 'Request cancelled']);
}
