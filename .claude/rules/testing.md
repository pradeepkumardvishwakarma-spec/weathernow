# Testing Rule

A handful of tests that matter beats 100% coverage on trivial code. For this project, that means:

- Repository layer: online success, offline fallback, error mapping
  (`test/data/weather_repository_impl_test.dart`).
- Forecast day-grouping logic — 3-hour slots → daily buckets, capped at 5 days
  (`test/data/forecast_model_test.dart`).
- Local-datasource corruption handling — a malformed/unreadable Hive entry must be treated as
  "no cache" (`CacheException`), not let an unrelated exception escape uncaught
  (`test/data/favorites_local_datasource_test.dart`, and the same defensive-cast pattern in
  `weather_local_datasource.dart`).
- At least one widget test proving the error state never leaks a raw exception string
  (`test/presentation/search_home_screen_test.dart`).

Don't write tests for generated boilerplate, trivial getters, or framework code.
