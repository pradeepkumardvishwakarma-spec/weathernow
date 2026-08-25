# AI Assistance Notes
# These are the issues where AI got wrong and I caught it up and solved it by giving below prompts

## Real example 1: raw Dio exception text leaking into the UI on a 401

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

## Real example 2: missing INTERNET permission only broke the release build

**What the AI suggested**

The original `flutter create` scaffold's `android/app/src/main/AndroidManifest.xml`
never declared `<uses-permission android:name="android.permission.INTERNET" />`.
This went unnoticed through the entire build — every network feature (search,
forecast, favorites refresh) worked fine in `flutter run` and `flutter run
--profile`.

**Why it was wrong**

Flutter's own tooling automatically injects the `INTERNET` permission for debug
and profile builds — because `flutter run`/hot-reload need it for the Dart VM
service connection — but it does **not** do this for release builds. So a
project can build and run perfectly in debug/profile for the entire development
cycle while genuinely missing a permission it needs, and this only surfaces the
first time an actual `flutter build apk --release` gets installed and tested.
This isn't something I'd assumed was safe to skip verifying — I hadn't
considered that "works in `flutter run`" and "works installed as a release APK"
could differ for a reason this fundamental.

**How I caught it**

Building and installing a real `--release` APK on a physical device (prompted by
investigating a separate Choreographer frame-skip question) and searching a
city produced: *"No internet connection, and no saved weather for this city
yet."* — even though the device had a working connection. Traced it through:
`connectivity_plus`'s own connectivity check still reported "connected" (it
checks the WiFi/mobile radio state, not the app's own permissions), so the
repository attempted the real request, which failed at the OS level due to the
missing permission — a failure type not explicitly named in the repository's
catch list, so it fell through to the generic cache-fallback path and produced
a technically-accurate-but-misleading "offline" message.

**What you changed**

Added the single missing line to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

---

## Real example 3: domain layer wasn't actually independent of Dio

**What the AI suggested**

The original scaffold's domain layer — `weather_repository.dart`,
`get_current_weather.dart`, and `get_forecast.dart` (all under `domain/`) —
imported `package:dio/dio.dart` directly, just to use its `CancelToken`
type as a method parameter. Separately, `favorite_preview_provider.dart`
(presentation) called `sl<WeatherLocalDataSource>()` directly — reaching
into the data layer's datasource instead of going through a use case and
repository like every other screen does.

**Why it was wrong**

This project's own `CLAUDE.md` states plainly: "the domain layer must never
import Flutter, Dio, or Hive" and "widgets must never call a datasource or
Dio directly." Both were violated from early on, and — worth being honest
about — an earlier "senior code review" prompt in this same session (see
`docs/ai/PROMPTS.md` entry #13) explicitly claimed "architecture
boundaries... had no violations found." That was wrong; the review just
wasn't asked a targeted enough question to catch it. A broad "review
everything" prompt missed what a specific "does X depend on Y?" question
found immediately.

**How I caught it**

Asked directly whether the domain layer was actually independent, then
grepped the domain layer's own imports for `dio`/`flutter`/`hive` and
presentation's imports for anything under `data/`. Both violations showed
up immediately once asked precisely, despite the earlier broad review
claiming a clean bill of health.

**What I changed**

Added a domain-owned `CancellationToken` (`core/usecase/
cancellation_token.dart`) — domain and use cases now depend on this instead
of Dio. The data layer (`weather_remote_datasource.dart`) bridges it to a
real Dio `CancelToken` in exactly one place, right before the actual
network call, so nothing above the data layer ever needs to know Dio's
cancellation API exists. Added a new domain use case `GetCachedWeather`
and a `WeatherRepository.getCachedWeatherOnly()` method so the favorites
preview provider reads cached weather through the proper use case →
repository chain instead of calling a datasource directly.

---

## Real example 4: AI made unapproved changes from a vague bug report

This one is different from the other three — not a Flutter/Dart technical
mistake, but a process mistake worth documenting for the same reason the
brief asks for this section: catching the AI doing the wrong thing and
correcting it is exactly the judgment being assessed.

**What the AI suggested**

Given the report "the application is not working on 3G it should work in
low latency as well" — a symptom, not a named change — Claude Code
directly edited two files (parallelized the weather/forecast fetch in
`weather_provider.dart`, bumped `dio_client.dart`'s `receiveTimeout` to
60s) without proposing the change first or asking for confirmation.

**Why it was wrong**

A vague report doesn't specify which fix is correct, and applying a
plausible-sounding fix without validating it against the actual symptom
risks shipping an unverified change — which is exactly what happened:
the change didn't resolve the issue, and had to be reverted.

**How I caught it**

Immediately, in the same turn: "what you did. also you are directly doing
the changes and not letting me know. first ask me then add any solution."

**What I changed**

Reverted both files to their prior committed state. Established a
standing rule for the rest of the session (and recorded in this project's
AI memory for future sessions): propose the diagnosis and fix in chat for
any ambiguous bug/symptom report, and wait for explicit confirmation
before editing files — only act immediately when a prompt names the exact
change to make (e.g. "add 30 sec for request timeout" is specific enough
to act on directly; "make it work better on 3G" is not).

---

## Real example 5: tests that had never actually been run had real bugs

**What the AI suggested**

`test/data/weather_repository_impl_test.dart` and
`test/presentation/search_home_screen_test.dart` looked, on inspection,
like correct, working tests — reasonable mock setups, sensible
assertions, a widget test asserting the no-raw-error-string guarantee.

**Why it was wrong**

Running them for the first time (`flutter test`) immediately failed 5 of
14, none of them for reasons a code review would have caught:
1. Mocktail's `any()` matcher requires `registerFallbackValue()` for any
   custom type (`WeatherModel`, `ForecastModel`) — missing entirely, and
   its absence corrupted mocktail's internal state enough to make the
   *next* test's failure message look unrelated to the real cause.
2. The widget test never initialized Hive, but the screen under test
   calls `Hive.box(...)` directly in `initState()` — instant crash on
   build.
3. A fake notifier passed `throw UnimplementedError()` directly as a
   constructor argument, intending it as "this will never be touched" —
   but Dart evaluates constructor arguments eagerly, so it threw on
   construction, unconditionally, regardless of whether the field was
   ever read.
4. The same screen reads a second provider (`favoritesProvider`)
   unconditionally in `build()`, which the test never overrode — it hit
   real, unregistered dependency injection and threw.

None of this was visible from reading the test files — every one of
these only surfaces by actually executing the suite.

**How I caught it**

Not by me — by the user running `flutter test` and pasting the real
terminal output back, across four separate rounds as each fix surfaced
the next failure underneath it.

**What I changed**

Fixed all four, one at a time, each confirmed against real output rather
than assumed correct from re-reading the code:
- Added `setUpAll(() { registerFallbackValue(...); })` for both model types.
- Added real temporary-directory Hive setup/teardown to the widget test.
- Replaced the eager `throw` with harmless `mocktail` mock instances.
- Added a `FakeFavoritesNotifier` override alongside the existing
  `FakeWeatherNotifier` one.

The broader lesson, worth being able to say plainly: a test that has
never been run isn't verified — it's just code shaped like a test.

---

## Real example 6: recommended an outdated, incompatible package

**What the AI suggested**

For root/jailbreak detection, recommended and added `flutter_jailbreak_detection` — a well-known, commonly-referenced package for this exact purpose. Never checked whether it was still compatible with current Android tooling before adding it.

**Why it was wrong**

The package's Android `build.gradle` predates Android Gradle Plugin's `namespace` requirement (introduced in AGP 7.3+, and a hard build failure on AGP 8+). The package hasn't been updated to add one. This isn't visible from the package's Dart API or its pub.dev description — it only surfaces when Gradle actually tries to configure the Android build.

**How I caught it**

Not by me — the user ran the app on a real emulator and got a build failure: `Namespace not specified. Specify a namespace in the module's build file: ...flutter_jailbreak_detection-1.10.0\android\build.gradle`.

**What I changed**

Rather than guessing at a replacement package (and risking the exact same failure again), used web search to check which alternatives were actually recently maintained, then verified the most promising-looking "drop-in successor" candidate (`flutter_jailbreak_detection_plus`) before committing to it — its own pub.dev scoring report flagged the same "legacy Kotlin/Gradle configuration" warning, meaning it likely had the identical problem. Switched instead to `flutter_root_jailbreak_checker` (most recently updated of the options found), which uses a different, slightly more involved API (`checkOfflineIntegrity()` returning a result object, instead of a plain boolean) but comes from active maintenance rather than a name that merely sounded current.

The lesson: a package's name, popularity, or having a plausible-sounding "_plus"/successor name doesn't confirm it's actually maintained or compatible with current tooling — worth checking recency/compatibility signals before adding a dependency, not just after it fails to build.

**Postscript**: `flutter_root_jailbreak_checker` itself then printed a different, non-fatal warning (Kotlin Gradle Plugin/KGP deprecation). The instinct was to swap packages again — but checking further showed this exact warning currently affects `package_info_plus` and `share_plus` too, two of the most heavily-used plugins in the entire Flutter ecosystem. It's Flutter's own transitional migration to "Built-in Kotlin" (Flutter 3.44-3.47) affecting nearly every native-Android plugin right now, not a sign of this specific package being poorly chosen. Correctly recognizing "this is an ecosystem-wide, temporary, non-blocking condition" versus "this package is bad, try another" avoided a third unnecessary swap.

---

## Real example 7: weather icons had no contrast handling against their background

**What the AI suggested**

`WeatherIcon` rendered OpenWeatherMap's icon CDN image directly via `CachedNetworkImage`, with
no background/contrast handling — just the raw PNG at whatever size was requested.

**Why it was wrong**

OpenWeatherMap's weather icons are white/light line-art on a transparent background. On this
project's white (or near-white, `#F5F6FA`) card backgrounds in light mode, a white cloud icon on
a white card has effectively zero contrast — the icon was rendering, just invisible. This isn't
something a code review catches, since the widget code itself is correct Flutter — it only shows
up by actually looking at the rendered UI.

**How I caught it**

Not by me — the user looked at the app in light mode on a real device: "in white theme clouds
are not visible since background cards are also white or similar to that."

**What I changed**

Added a light sky-blue circular backdrop (`AppTheme.iconBackdrop`) behind the icon glyph, applied
once inside `WeatherIcon` itself so every screen that uses it (`WeatherCard`, `ForecastStrip`,
Favorites, Forecast Detail) picks it up automatically. Made it light-mode-only — dark mode's
cards are already dark enough for the white glyph to read on their own, so forcing the same
backdrop there would just be an unnecessary light patch (caught by the user immediately: "in
case of dark theme this sky blue background will not be there").

---

## Real example 8: Favorites' empty state was missing its own AppBar

**What the AI suggested**

`FavoritesScreen`'s empty-favorites branch returned `Scaffold(body: Center(child: Text(...)))`
with no `appBar` at all, while the populated-list branch a few lines below correctly had one.

**Why it was wrong**

Anyone who hadn't favorited a city yet — which is the actual first-run experience for this
screen — saw a bare screen with no title, no consistent chrome with the rest of the app. It also
had no horizontal padding around the message text, so on a narrow screen the sentence could run
close to the edges. Both were easy to miss by only glancing at the "happy path" (populated list)
branch during review.

**How I caught it**

The user flagged it directly during a UI pass: "favorites text is not given right and left margin
appbar is also not there." Confirmed by reading the actual file rather than assuming from memory
— the missing `appBar` was exactly where described.

**What I changed**

Added the same `AppBar(title: const Text('Favorites'))` to the empty-state `Scaffold`, and wrapped
the message in `Padding` with horizontal margin and centered text alignment.

---

## Real example 9: pubspec.yaml carried dependencies for a code-gen approach that was never adopted

**What the AI suggested**

`pubspec.yaml` had `riverpod_annotation` and `riverpod_generator` (Riverpod's `@riverpod`
code-generation style) and `hive_generator` + `build_runner` (generated Hive `TypeAdapter`s)
sitting alongside `flutter_lints`/`mocktail` as if they were in active use.

**Why it was wrong**

None of them were. Every provider in this codebase is a hand-written `StateNotifierProvider` —
zero `@riverpod` annotations, zero `.g.dart` files anywhere. Hive persistence uses plain
`Map<String, dynamic>` serialization (`toHiveJson()`/`fromHiveJson()`), a deliberate, already-
documented choice — not generated `TypeAdapter`s. With neither approach actually used,
`build_runner` (a genuinely heavy dev dependency — it noticeably slows down `pub get`/CI) had
nothing to generate. `cupertino_icons` (the default `flutter create` scaffold dependency) was
also dead weight — the app uses `Icons.*` (Material) everywhere, never `CupertinoIcons.*`.

**How I caught it**

Not from reading feature code — a direct, targeted audit: grepped the entire `lib/` tree for
`@riverpod`, any `.g.dart` file, `HiveType`/`TypeAdapter`/`HiveField` usage, and `CupertinoIcons`.
Zero real matches for any of them confirmed they were safe to remove, rather than assuming from
the dependency names alone.

**What I changed**

Removed all 5 from `pubspec.yaml`. Verified afterward that `flutter analyze` and `flutter test`
still passed clean with them gone.

---

## Real example 10: Forecast Detail's "Evening" section showed hours out of order

**What the AI suggested**

`evening = day.slots.where((s) => s.dateTime.hour >= 17 || s.dateTime.hour < 5).toList();` — a
single `.where()` filter over the day's slot list, which is stored in raw chronological order
starting from 00:00.

**Why it was wrong**

`.where()` preserves the original iteration order — it doesn't reorder by the condition. Since
the day's slots start at 00:00, filtering for "hour ≥ 17 OR hour < 5" picks up that day's own
00:00/03:00 slots *first* (they appear earlier in the source list) and 18:00/21:00 *last*,
rendering the section as `00:00, 03:00, 18:00, 21:00` instead of the natural evening-forward
order `18:00, 21:00, 00:00, 03:00`. The bucketing logic itself (which hours count as "evening")
was correct; only the display order within that bucket was wrong.

**How I caught it**

Not by me — the user noticed it directly while looking at real data: "but in afternoon after
showing 15:00 it should show 18:00, then 21:00, then 00:00 and then 03:00."

**What I changed**

Rebuilt `evening` as two chronological halves concatenated — everything from 17:00 onward, then
everything before 5:00 — instead of a single unordered filter:
```dart
final evening = [
  ...day.slots.where((s) => s.dateTime.hour >= 17),
  ...day.slots.where((s) => s.dateTime.hour < 5),
];
```

---

## Real example 11: "Last searched city" was saved even when the search failed, bypassing the repository layer to do it

**What the AI suggested**

`SearchHomeScreen._search()` wrote `lastCity` to Hive unconditionally, at the moment of
submission — before knowing whether the search would actually succeed. It also read/wrote this
directly via `Hive.box(HiveBoxes.settings)` inside the widget itself, bypassing the
provider → use case → repository chain this project's own architecture rule requires.

**Why it was wrong**

A failed search (e.g. searching a city with no cache while offline) would overwrite whatever the
previous, genuinely successful "last city" was. So reopening the app afterward would try to
reload the *failed* city instead of the last one that actually worked — showing an error where
the user expected to see their real last-known weather. Separately, the direct Hive access in
the widget violated this project's own rule that presentation must never touch Hive directly —
a violation that had gone unnoticed since it predated this session's architecture work.

**How I caught it**

Not by me — the user reported the exact symptom: "i have added surat in my favorite then after
killing and reopening the app surat should be able to see right now new delhi is there in
textfield and saying no internet connection... which is incorrect." Traced it to the
unconditional `Hive.box(...).put()` call in `_search()`.

**What I changed**

Added `getLastCity()`/`setLastCity()` to `SettingsRepository`/`SettingsRepositoryImpl` (same
pattern as the existing `getSettings()`/`setUnit()`), exposed `lastCity` and `saveLastCity()` on
`SettingsNotifier`, changed `WeatherNotifier.searchCity()` to return `Future<bool>` reflecting
actual success, and updated `SearchHomeScreen` to only call `saveLastCity()` after confirming the
search succeeded — never on failure.

---

## Categories worth watching for while you build

(Kept as a general reference — useful if you hit a further example before submitting.)

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
