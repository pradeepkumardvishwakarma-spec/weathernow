# Networking Rule

- Every network-calling use case accepts and passes through a `CancellationToken`
  (`core/usecase/cancellation_token.dart`) — see `get_current_weather.dart`/`get_forecast.dart`.
  `weather_provider.dart`'s `WeatherNotifier` cancels the previous in-flight token before
  starting a new search, so the latest search always wins, never a race.
- `DioClient` (`core/network/dio_client.dart`) sets both `connectTimeout` and `receiveTimeout` —
  a slow request must fail with a timeout, not hang the app indefinitely.
- Search input is debounced 600ms (`Debouncer` in `core/utils/debouncer.dart`, used by
  `city_search_bar.dart`) — never fire a request per keystroke. Also requires a minimum 2
  characters before firing, and ignores whitespace-only input.
- Raw `DioException`s never reach the repository/presentation layer un-translated —
  `weather_remote_datasource.dart`'s `_mapDioError()` is the one place that maps Dio failure
  types to this project's own `Exception`s (`ServerException`, `TimeoutException`,
  `CityNotFoundException`, `NetworkException`, `RequestCancelledException`), and never forwards
  `DioException.message` verbatim (it can echo the full request URL, including the API key —
  see `docs/ai/AI_REVIEW.md` real example 1).
