# Weather Feature Skill

Adding or changing anything in the `weather` feature, in order:

1. Define/verify the domain contract — `weather_entity.dart`/`forecast_entity.dart`,
   `weather_repository.dart` (abstract), the relevant use case in `domain/usecases/`
   (`get_current_weather.dart`, `get_forecast.dart`, `get_cached_weather.dart`).
2. Implement the data source + model mapping — `weather_remote_datasource.dart` (Dio/JSON),
   `weather_local_datasource.dart` (Hive, defensive-cast on cache reads), `weather_model.dart`/
   `forecast_model.dart` for the `fromJson`/Hive mapping.
3. Implement repository behavior and failure mapping in `weather_repository_impl.dart`
   (`Exception` → `Failure`, online-first/offline-fallback branching per
   `skills/offline-strategy.md`).
4. Wire the use case through `core/di/injection_container.dart`'s "Weather feature" block and
   expose it via `weather_provider.dart` (`WeatherNotifier`) or `favorite_preview_provider.dart`
   for the cache-first path.
5. Implement presentation state + UI — `weather_state.dart`, the relevant screen/widget under
   `presentation/screens/` or `presentation/widgets/`.
6. Test success, failure, and offline behavior — not just the happy path. See
   `rules/testing.md` for what this feature specifically needs covered.
