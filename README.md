# WeatherNow

A small weather app built on the OpenWeatherMap API which shows current weather details of searched location.

## What This App Covers

A plain checklist of what's actually built and working, in simple terms.

**Weather**
- Search any city and see the current temperature, weather description, humidity, wind, and an icon.
- See the next 5 days of forecast under the current weather.
- Tap a day in the forecast to see a Night/Morning/Afternoon/Evening breakdown for that day, in chronological order (00:00 through 21:00).
- Going back from that detail screen does not reload anything — it's instant.

**Favorites**
- Save a city as a favorite with one tap (the star icon).
- Favorites are saved on the device and are still there after closing and reopening the app.
- The Favorites list shows each city's weather right away from a saved copy, then quietly updates it in the background.
- Swipe a favorite to remove it.

**Offline behavior**
- If there's no internet, the app shows the last weather it saved for that city instead of an error, with a label like "Updated 2h ago" so it's clear the data isn't live.
- If there's no internet AND no saved data for that city yet, it shows a simple, friendly message with a Retry button — never a technical error.

**Units**
- A °C/°F switch in Settings.
- Flipping it updates every screen immediately, with no reloading.
- The choice is remembered after closing and reopening the app.

**Navigation**
- Three tabs: Search/Home, Favorites, Settings.
- On Home, pressing back asks "Are you sure you want to exit?" before closing the app.
- On Favorites/Settings, pressing back returns to Home instead of exiting.

**Behind the scenes (in simple terms)**
- The code is split into three clear layers (UI, business logic, data) so each piece can be tested and changed on its own — this is called Clean Architecture.
- Riverpod is used to manage what's shown on screen and when it updates.
- Typing in the search box waits half a second after you stop typing before searching, so it doesn't spam the server with a request for every letter.
- If you search a new city before the last search finished, the old, now-unwanted request is cancelled instead of racing the new one.
- The app talks to the internet through one central networking setup with timeouts, so a slow or broken connection can't freeze the app.
- The weather API key is kept out of the code entirely and loaded from a separate file that's never uploaded to GitHub.
- Error messages shown to the user are always short and friendly — the app never shows a raw technical error on screen.
- Weather icons are cached so they don't re-download every time you scroll.
- The app has been checked for common security issues (see "Security notes" below) and profiled for performance issues (see "Performance notes" below), not just assumed to be fine.
- Automated tests exist for the trickiest logic (online/offline switching, error handling, day-by-day forecast grouping) rather than trying to test everything.

## Setup

1. **Got an API key from**: sign up free at https://home.openweathermap.org/users/sign_up
2. **Added the key**: copy `assets/env/.env.example` (or edit `assets/env/.env` directly) and set:
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

- **State management**: Riverpod (`StateNotifierProvider`), per the brief. `weatherProvider` is `.autoDispose` so search state resets cleanly per session; `settingsProvider` and `favoritesProvider` are app-lifetime singletons since they represent persisted, cross-screen state. No `setState` anywhere in the app — even small local-widget concerns (the search bar's clear-button visibility) go through a scoped `.autoDispose` provider instead, so only the widget that actually needs to update does.
- **Domain logic actually lives in `domain/`**: a dedicated pass audited the codebase for business logic sitting in the wrong layer and relocated what it found — the Night/Morning/Afternoon/Evening time-of-day bucketing (now `DailyForecastEntity.sectionsByTimeOfDay`, unit-tested in `test/domain/forecast_entity_test.dart` — it had zero test coverage while it lived inside a widget's `build()`), °C/°F conversion (now alongside the `TemperatureUnit` enum in `settings_entity.dart`, not a presentation-layer provider), and case-insensitive favorite-city matching (now `FavoriteCityEntity.matchesCityName`, deduplicating two independent inline implementations of the same rule).
- **DI**: `get_it` service locator, registered in `core/di/injection_container.dart`. Repositories/use cases are the only things widgets and providers depend on — never the concrete Dio/Hive implementation — which is what makes the repository test in `test/data/weather_repository_impl_test.dart` possible without touching a real network or disk.
- **Offline strategy — two different patterns, intentionally**:
  - **Home/Search**: online-first. Try the network; only fall back to the last cached reading for that city if the request fails or there's no connection. Shows an "updated Xh ago · offline" badge when serving cached data.
  - **Favorites**: cache-first. Show the last known reading instantly (no spinner for a saved favorite), then silently refresh in the background per the brief's explicit wording ("read from local cache first, refresh in the background").
- **Cancellation**: every weather/forecast use case call carries a Dio `CancelToken`. `WeatherNotifier` cancels the previous in-flight request the moment a new search starts, so a fast typist never races two responses.
- **Search debounce**: 600ms via a small custom `Debouncer` (no need for a package) — search only fires after the user pauses typing, or on explicit submit. Input is also capped at 85 characters as a paste-guard — deliberately not a character/symbol filter, since real city names legitimately use apostrophes, hyphens, and non-Latin scripts.
- **"Last searched city" only persists on success**: originally written to Hive unconditionally on every search submission, including failed ones — a failed offline search could silently overwrite a genuinely successful previous city, so reopening the app would retry the failed one instead of showing the last city that actually worked. Fixed so it's only saved after `WeatherNotifier.searchCity()` reports the search actually succeeded (fresh fetch or cache fallback), never on failure.
- **Theming**: a specified palette (`AppTheme` in `core/theme/app_theme.dart`) rather than Material defaults — sky-blue primary, and semantic colors (`accentColor`/`warningColor`/`dangerColor`/`starColor`/`mutedColor`) reused consistently across the app instead of ad hoc `Colors.*` values (e.g. `warningColor` for the offline/stale badge, `dangerColor` for errors). Weather icons sit on a light sky-blue circular backdrop in light mode only — their glyphs are white-on-transparent, so on a white/near-white card they had no contrast; dark mode's cards are already dark enough that the backdrop isn't needed there.
- **Lazy list building** (not pagination — there's no "load more" here, just deferred widget build): `ListView.builder` is used for every list in the app (forecast strip, favorites, forecast detail, settings, search results), so only visible items are built — matters more as favorites grow; kept the pattern consistent everywhere.
- **Forecast detail without re-fetching**: the tapped day's already-fetched `DailyForecastEntity` (with all its raw 3-hour slots) is passed via `go_router`'s `extra` param. Going back never triggers a new network call.
- **Image caching**: `cached_network_image` wraps every weather icon (`WeatherIcon` widget) — avoids redundant downloads on scroll/rebuild.
- **Security**: API key lives only in a git-ignored `.env` asset, injected into requests via a Dio interceptor (never hard-coded, never logged). No secrets stored in Hive. See `docs/ai/AI_REVIEW.md` for security-adjacent things an AI suggestion got wrong that were caught during review.

## Performance notes

Profiled two things reported during development, both with real data rather than guesses:

- **Skipped-frames warning at cold start** (`Skipped 90+ frames!` from Choreographer, reproduced in both debug and `--profile` builds) — native app-init work (`Hive.initFlutter`, opening boxes, DI setup) running before `runApp()`, before Flutter schedules its first frame. Opening the three Hive boxes in `main.dart` was switched from three sequential `await`s to one `Future.wait`, a real reduction in that startup work.
- **Keyboard-open jank on the Search screen, found and fixed** — DevTools' Frame Analysis flagged "raster jank" on the frames right when tapping into the search field. Cause: `Scaffold`'s default `resizeToAvoidBottomInset: true` forces a full relayout + re-rasterize on every single frame of the keyboard's own show/hide animation. `SearchHomeScreen` doesn't need that — the search bar sits above where the keyboard covers, so nothing on screen actually needs to move. Set `resizeToAvoidBottomInset: false` on that screen's `Scaffold`; the keyboard now simply overlaps the lower results area instead of triggering a relayout race with its own animation.
- **APK size** — a plain `flutter build apk` (no `--split-per-abi`) came out to ~34MB, which looked high at first glance. Ran `flutter build apk --analyze-size --target-platform=android-arm64` to get a real breakdown instead of guessing: this app's own code (`package:weathernow`) is **77 KB** of the total — the rest is the Flutter engine/framework baseline (`package:flutter` alone is 3MB) that every Flutter app pays per architecture, and dependencies are all proportionate (hive 73KB, go_router 65KB, dio 51KB, riverpod 43KB). A single-ABI (arm64) release build is **17.7MB**; the "34MB" figure was simply the universal APK bundling three architectures' native code (arm64-v8a, armeabi-v7a, x86_64) into one file — not a regression. For real distribution, `flutter build apk --split-per-abi` or `flutter build appbundle` (what Google Play actually wants — it auto-delivers only the architecture each device needs) avoids shipping that multi-ABI bloat to every user.

## Security notes

The brief calls out security as something reviewers will specifically check, so beyond the one-line summary above, here's what was actually verified and fixed rather than just claimed:

- **Fixed**: the raw-401-error bug (see `docs/ai/AI_REVIEW.md`) wasn't just a UX problem — Dio's raw internal exception message can echo back the full request URL, including the API key query parameter. Forwarding that message to the UI meant the key could end up visible on screen or in a crash report. Fixed by never forwarding `e.message`; the debug-only console log now prints just the HTTP status code, never the full message.
- **Verified clean**:
  - The API key never touches source control — lives only in git-ignored `assets/env/.env`, loaded at runtime via `flutter_dotenv`.
  - No verbose request/response logging interceptor is active (`dio_client.dart` deliberately omits one) — nothing prints the API key to the console during normal operation.
  - `DioClient`'s `baseUrl` is HTTPS-only; no custom certificate-validation bypass anywhere in the networking code.
  - No `android:usesCleartextTraffic="true"` override in `AndroidManifest.xml` — Android's secure-by-default (HTTPS-only) behavior is untouched.
  - No secrets are stored in Hive — only weather cache, favorite city names, and the unit preference.
  - The UI never displays a raw exception/error string anywhere — only pre-written `Failure.message`s (see `test/presentation/search_home_screen_test.dart`, which explicitly asserts this).
- **Release build minification**: `android/app/build.gradle.kts` has `isMinifyEnabled`/`isShrinkResources` on for release builds (R8), with `android/app/proguard-rules.pro`. Shrinks the Android-native layer and makes it harder to casually read.
- **Root/jailbreak detection — evaluated, implemented, then removed**: this was actually built (`flutter_root_jailbreak_checker`, checked before anything else in `main.dart`, blocking the app on a positive result) because the brief asks for security to be "handled sensibly throughout" and it's a recognized standard practice worth demonstrating awareness of. It was then taken back out after testing showed the underlying detection library flags emulators as compromised — a well-known false-positive mode for this category of package, since emulators share signals (debuggable build tags, `su`-adjacent paths, etc.) with genuinely rooted devices. A hard block on that false positive would prevent the app from opening at all in an emulator, which is almost certainly how this submission gets reviewed. Given this app has no sensitive on-device data to protect in the first place, blocking a legitimate reviewer outweighs the defensive value here, so the code was removed rather than shipped in a state that could break the demo. (Package history — `flutter_jailbreak_detection` failing to build on current AGP, then the KGP-deprecation warning on the replacement package — is kept in `docs/ai/AI_REVIEW.md` as a real record of that investigation.) For a production release targeting real devices, this is a reasonable addition — ideally paired with a way to distinguish "known emulator" from "genuinely rooted device" before deciding to block.
- **Known gap, disclosed rather than hidden**: `.env` is bundled as a plain Flutter asset, so the API key is technically extractable from a compiled release APK by someone determined enough to unpack it — minification only touches the Android-native Java/Kotlin layer, not Dart code or bundled assets, so it doesn't close this gap, only makes the surrounding code harder to read. (An AES-encrypted-at-rest version of the key was tried and deliberately reverted — the decryption key would have had to ship in the app too, which only relocates the problem rather than solving it, for the cost of a new dependency.) This is a reasonable tradeoff for a take-home (the brief explicitly says "however you want to handle it" for the key) — a production app would instead proxy weather requests through its own backend so the key never ships to the client at all.

## What's stubbed / would do differently with more time

- Hive models here use plain `Map<String, dynamic>` storage rather than generated `TypeAdapter`s — simpler for a takehome (no codegen step required to run the project), but a generated adapter would be more type-safe for a larger app. `hive_generator`/`build_runner` (and `riverpod_generator`/`riverpod_annotation`, from an earlier code-gen approach that was never actually adopted) aren't in `pubspec.yaml` at all — audited for actual usage and removed rather than left as unused dead weight.
- No integration/golden tests — unit tests cover the repository layer (online/offline/error-mapping), forecast day-grouping, time-of-day sectioning, and local-datasource corruption handling, plus one widget test asserting the error state never leaks a raw exception string. With more time I'd add a widget test per screen and a golden test for `WeatherCard`.
- Favorites preview currently re-fetches fresh weather for every favorite on every visit to the Favorites tab; with more cities this should be batched/rate-limited.
- No retry/backoff strategy on transient network errors beyond the manual "Retry" button.
- Search is city-name based (matches the brief); a production version would probably add geocoding/autocomplete to reduce "city not found" cases from typos.

## Required submission items

Per the brief, alongside this repo:
- `docs/ai/PROMPTS.md` — chat history/prompts used with the AI coding tool
- `CLAUDE.md` (repo root) and `.claude/` (`agents/`, `skills/`, `rules/`) — project instructions and agent setup used with Claude Code
- `docs/ai/AI_REVIEW.md` — where the AI got Flutter/Dart wrong, how it was caught, what changed
- `docs/architecture.md` — architecture diagram
