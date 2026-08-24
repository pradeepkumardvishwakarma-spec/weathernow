# WeatherNow

A small weather app built on the OpenWeatherMap API — take-home challenge submission for Webol's Senior Flutter Developer role.

## Setup

1. **Get an API key**: sign up free at https://home.openweathermap.org/users/sign_up (note: free-tier keys can take up to ~2 hours to activate after signup).
2. **Add the key**: copy `assets/env/.env.example` (or edit `assets/env/.env` directly) and set:
   ```
   OPEN_WEATHER_API_KEY=your_real_key_here
   OPEN_WEATHER_BASE_URL=https://api.openweathermap.org
   ```
   `assets/env/.env` is git-ignored — it is never committed. This is the "however you want to handle it" choice for keeping the key out of source control; `flutter_dotenv` loads it at runtime from a bundled asset that isn't checked into git.
3. **Install dependencies**:
   ```
   flutter pub get
   ```
4. **Run**:
   ```
   flutter run
   ```
5. **Run tests**:
   ```
   flutter test
   ```

## Architecture

Clean Architecture, three layers per feature (`weather`, `favorites`, `settings`):

```
lib/
  core/                     # shared, framework-level concerns
    error/                  # Exception (data layer) <-> Failure (domain layer) split
    network/                # DioClient, NetworkInfo (connectivity_plus wrapper)
    usecase/                # base UseCase<Type, Params> contract
    utils/                  # Debouncer, constants, time_ago
    di/                     # get_it service locator
    router/                 # go_router config + bottom-nav shell
    theme/
  features/
    weather/
      data/                 # datasources (remote: Dio, local: Hive), models, repository impl
      domain/                # entities, abstract repository, use cases
      presentation/          # Riverpod providers/state, screens, widgets
    favorites/
      data/ domain/ presentation/   (same shape)
    settings/
      data/ domain/ presentation/   (same shape)
```

**Why this shape**: UI never imports Dio/Hive directly — only the data layer does. Domain layer (entities, use cases, repository interfaces) has zero Flutter/Dio/Hive imports, so it's trivially unit-testable and the data source could be swapped (e.g. a different weather API) without touching a single widget.

### Key decisions

- **State management**: Riverpod (`StateNotifierProvider`), per the brief. `weatherProvider` is `.autoDispose` so search state resets cleanly per session; `settingsProvider` and `favoritesProvider` are app-lifetime singletons since they represent persisted, cross-screen state.
- **DI**: `get_it` service locator, registered in `core/di/injection_container.dart`. Repositories/use cases are the only things widgets and providers depend on — never the concrete Dio/Hive implementation — which is what makes the repository test in `test/data/weather_repository_impl_test.dart` possible without touching a real network or disk.
- **Offline strategy — two different patterns, intentionally**:
  - **Home/Search**: online-first. Try the network; only fall back to the last cached reading for that city if the request fails or there's no connection. Shows an "updated Xh ago · offline" badge when serving cached data.
  - **Favorites**: cache-first. Show the last known reading instantly (no spinner for a saved favorite), then silently refresh in the background per the brief's explicit wording ("read from local cache first, refresh in the background").
- **Cancellation**: every weather/forecast use case call carries a Dio `CancelToken`. `WeatherNotifier` cancels the previous in-flight request the moment a new search starts, so a fast typist never races two responses.
- **Search debounce**: 600ms via a small custom `Debouncer` (no need for a package) — search only fires after the user pauses typing, or on explicit submit.
- **Pagination**: `ListView.builder` is used for both the forecast strip and the favorites list, so only visible items are built — matters more as favorites grow; kept the pattern consistent across both lists per the brief's ask.
- **Forecast detail without re-fetching**: the tapped day's already-fetched `DailyForecastEntity` (with all its raw 3-hour slots) is passed via `go_router`'s `extra` param. Going back never triggers a new network call.
- **Image caching**: `cached_network_image` wraps every weather icon (`WeatherIcon` widget) — avoids redundant downloads on scroll/rebuild.
- **Security**: API key lives only in a git-ignored `.env` asset, injected into requests via a Dio interceptor (never hard-coded, never logged). No secrets stored in Hive. See `docs/ai/AI_REVIEW.md` for security-adjacent things an AI suggestion got wrong that were caught during review.

## Performance notes

Profiled two things reported during development, both with real data rather than guesses:

- **Skipped-frames warning at cold start** (`Skipped 90 frames!` from Choreographer, reproduced in both debug and `--profile` builds). Traced to Flutter's well-known first-frame shader-compilation cost — the GPU compiling shaders the first time it hits a new draw operation (Material elevation/shadows, gradients, text) — plus native app-init work (`Hive.initFlutter`, opening boxes, DI setup) that runs before `runApp()`, all before Flutter schedules its first frame. Opening the three Hive boxes in `main.dart` was switched from three sequential `await`s to one `Future.wait` (a real, if small, win on that part of cold start), but the bulk of the delay is shader compilation, which needs an SkSL warm-up step (`--cache-sksl` on a real device, bundled at build time) to fully address — not attempted here, flagged instead as a known follow-up.
- **APK size** — a plain `flutter build apk` (no `--split-per-abi`) came out to ~34MB, which looked high at first glance. Ran `flutter build apk --analyze-size --target-platform=android-arm64` to get a real breakdown instead of guessing: this app's own code (`package:weathernow`) is **77 KB** of the total — the rest is the Flutter engine/framework baseline (`package:flutter` alone is 3MB) that every Flutter app pays per architecture, and dependencies are all proportionate (hive 73KB, go_router 65KB, dio 51KB, riverpod 43KB). A single-ABI (arm64) release build is **17.7MB**; the "34MB" figure was simply the universal APK bundling three architectures' native code (arm64-v8a, armeabi-v7a, x86_64) into one file — not a regression. For real distribution, `flutter build apk --split-per-abi` or `flutter build appbundle` (what Google Play actually wants — it auto-delivers only the architecture each device needs) avoids shipping that multi-ABI bloat to every user.

## What's stubbed / would do differently with more time

- Hive models here use plain `Map<String, dynamic>` storage rather than generated `TypeAdapter`s (via `hive_generator`/`build_runner`) — simpler for a takehome (no codegen step required to run the project), but a generated adapter would be more type-safe for a larger app.
- No integration/golden tests — only unit tests on the repository (online/offline/error-mapping) and the forecast day-grouping logic, plus one widget test asserting the error state never leaks a raw exception string. With more time I'd add a widget test per screen and a golden test for `WeatherCard`.
- Favorites preview currently re-fetches fresh weather for every favorite on every visit to the Favorites tab; with more cities this should be batched/rate-limited.
- No retry/backoff strategy on transient network errors beyond the manual "Retry" button.
- Search is city-name based (matches the brief); a production version would probably add geocoding/autocomplete to reduce "city not found" cases from typos.

## Required submission items

Per the brief, alongside this repo:
- `docs/ai/PROMPTS.md` — chat history/prompts used with the AI coding tool
- `CLAUDE.md` (repo root) and `.claude/` (`agents/`, `skills/`, `rules/`) — project instructions and agent setup used with Claude Code
- `docs/ai/AI_REVIEW.md` — where the AI got Flutter/Dart wrong, how it was caught, what changed
- `docs/architecture.md` — architecture diagram
