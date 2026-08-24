# AI Assistance Notes

## Real example: raw Dio exception text leaking into the UI on a 401

**What the AI suggested**

In `lib/features/weather/data/datasources/weather_remote_datasource.dart`,
`_mapDioError()` explicitly mapped a few known Dio failure types (cancellation,
timeout, connection error, 404) to their own exceptions, but for everything else —
including a 401 — it fell through to:

```dart
return ServerException(e.message ?? 'Unknown server error');
```

**Why it was wrong**

`DioException.message` is a technical diagnostic string meant for developers, not
end users — for an HTTP error response it typically describes the status code and
Dio's `validateStatus` configuration, and can echo back the full request URL
including query parameters (in this app, that includes the OpenWeatherMap API key).
`WeatherRepositoryImpl` catches `ServerException` and forwards its `message`
straight into `ServerFailure`, which the Search screen displays verbatim in a
`Text()` widget. So that raw string reached the UI unfiltered — a direct violation
of this project's own CLAUDE.md rule ("Never let the UI display a raw
exception/error string"), and one the type system didn't catch, because the code
still satisfied the `Either<Failure, T>` shape; the problem was in the *content* of
the message, not its type.

**How I caught it**

Not a compile error or a test failure — manual testing. Searched "Mumbai" with the
`.env` API key still set to the placeholder value, got a 401 from OpenWeatherMap,
and the error screen showed a long technical string instead of a simple message a
non-technical user could read.

**What I changed**

`_mapDioError()` no longer forwards `e.message` under any circumstance. Added an
explicit branch for 401 with a short, curated message, a generic friendly fallback
for any other unmapped status code, and a `kDebugMode`-gated `debugPrint` of just
the status code (not the raw message) so the real cause is still visible in the
dev console without ever reaching the UI or risking the API key ending up in logs.

Before:
```dart
return ServerException(e.message ?? 'Unknown server error');
```

After:
```dart
final statusCode = e.response?.statusCode;
if (statusCode == 404) {
  return CityNotFoundException();
}
if (kDebugMode) {
  debugPrint('Weather API request failed with status $statusCode');
}
if (statusCode == 401) {
  return ServerException("Couldn't connect to the weather service. Please try again later.");
}
return ServerException();
```

---

## Categories worth watching for while you build

(Kept as a general reference — useful if you hit a second example before submitting.)

1. **Riverpod API drift** — AI suggestions frequently mix syntax from `StateNotifierProvider`
   (Riverpod 1.x/2.x classic) with the newer code-generation `@riverpod` annotation style, or
   suggest `ref.watch` inside a place that should use `ref.read` (e.g. inside a callback),
   causing rebuild loops or "used ref after dispose" errors.
2. **Dio exception typing** — AI often assumes `catch (e)` gives you a typed `DioException`
   without checking `e.type` first, or forgets that a cancelled request also throws a
   `DioException` (type `cancel`) that needs its own branch — easy to accidentally treat a
   cancellation as a real error.
3. **Hive type limitations** — Hive can't store arbitrary Dart objects without a generated
   `TypeAdapter`; AI suggestions sometimes try to `box.put()` a custom class directly and
   only surface the problem at runtime, not compile time.
4. **`const` constructor suggestions that don't compile** — AI sometimes marks a widget
   constructor `const` when one of its fields (e.g. a `DateTime.now()` default, or a closure)
   isn't actually a compile-time constant.
5. **go_router `extra` and hot-reload/deep-linking** — passing objects via `extra` (as this
   project does for `DailyForecastEntity`) breaks deep-linking/state-restoration, which AI
   suggestions often don't flag unless directly asked.
6. **Null-safety on JSON parsing** — AI-generated `fromJson` factories sometimes assume a key
   is always present in OpenWeatherMap's response (e.g. `wind`, `weather[0]`) and throw on a
   city/response shape that omits it.
