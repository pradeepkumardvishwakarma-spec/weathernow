# AI Prompts / Chat History Log

**Tool:** Claude Code

---

### 1. Initial architecture & scaffold


**Prompt:**
> i need to create app based on the file i have attached so requesting you to go
> through the file line by line and create the app in flutter following clean
> architecture sperating module as data, domain and presentation. in data there
> will be datasources, repositories and model. in domain there will be usecase,
> repositories(abstract or interface class), entities. in presentation there will
> be widgets/screens, riverpod as state management(there will be states as
> described in document), offline capability using connectivity plus(hive), use
> go_router for navigation, use listview.builder for pagination, use debounce for
> search, cachenetworkimage for image loading, use dependency injection... use
> orchestrator, agents, skills, and rules. should work in low network and security
> best practices should be there. split the widget tree into smaller widgets, use const where necessary.

---

### 2. Bottomnavigation

> Build bottomnavigationbar using shell routing that will contain Home, Favorite and Settings
> Highlight the icon when clicked


### 3. Home Screen integration

> Implement the Search/Home screen exactly against the assignment.
> It must support city search, loading, current temperature, description, humidity, wind, icon, 5-day forecast strip, retryable user-friendly errors, offline/cached indication and favorite action.
> Keep UI simple and interview-reviewable.

---

### 4. Search debounce/cancellation

**Prompt:**
> Developed and Review the current search flow. Add a small debounce for search input and
> ensure obsolete API requests are cancelled. The latest user search must
> win without race conditions. Explain why debounce and CancelToken solve
> different problems. Do not add unnecessary search infrastructure.

### 5. Forecast detail

**Prompt:**
> Implement Forecast Detail. Tapping a day from the forecast strip should
> open a detail view showing the available 3-hour readings in a readable
> morning/afternoon/evening-style breakdown. Going back must preserve the
> existing Home state and should not re-fetch everything unnecessarily.

### 6. Favorites

**Prompt:**
> Implement Favorites according to the assignment. Persist saved cities in
> Hive. Load cached previews first. If connected, refresh favorite weather
> in the background. If offline, retain the last known icon/temperature
> and updated time. Allow removal and navigation into a favorite's
> weather. Use ListView.builder for the dynamic list.

### 7. Settings

**Prompt:**
> Implement the °C/°F setting. Changing it must update every relevant
> screen immediately without another weather API call. Persist it so the
> choice survives restart. Keep persistence behind the
> repository/use-case boundary.


### 8. Image caching

**Prompt:**
> Developed and Review weather icon loading and use cached_network_image. Add loading
> and error fallbacks and make sure image loading does not cause
> unnecessary rebuilds or repeated downloads.


### 9. Fresh performance pass

**Prompt:**
> Develop and Review WeatherNow for Flutter performance. Check unnecessary rebuilds,
> provider scope, ListView.builder usage, image caching, async lifecycle,
> request cancellation and expensive work in build(). Tell me exactly
> what to measure in Flutter DevTools. Do not invent profiling numbers.

### 10. Raw 401 error text shown on the Search screen

**Prompt:**
> when i am searching mumbai in search bar then i am getting long error
> message showing 401 and all. normal user will not understand this, it should
> be user understandable

---

### 11. Restructuring `.claude/` into agents, skills, and rules

**Prompt:**
> now what i want is look at the existing .claude folder and restructure it with agents, skills and rules. 
> agents should use the relevant skills and always follow the project rules. keep the number of agents and skills limited and useful, don't create them just for the sake of it. 
> also make sure this setup can be used when a new developer adds a feature so the same architecture and coding standards are followed.

### 12. A junior-developer-usable "how to build a new feature" guide

**Prompt:**
> i want this prompts, or claude files or documents whatever is there if
> given to any junior then on the basis of this he can develop any new
> module follwing same architecture, security principles and many more like
> this

### 13. Senior code review

**Prompt:**
> Review the complete WeatherNow repository as a Senior Flutter Developer
> interviewer. Audit Clean Architecture, Riverpod, Dart/Flutter quality, API
> integration, cancellation, offline/cache, favorites, settings, navigation,
> debounce, image caching, error handling, testing, security, performance,
> DI and maintainability. For each issue provide severity, file, problem,
> why it matters and the smallest recommended fix. Also list likely
> interview questions about this implementation.

---

### 14. Domain layer wasn't actually independent

**Prompt:**
> right now for localdatasource domain layer is directly depend on data
> layer??
> see my take is domain layer should be independent of any other layer.
> also make a seperate injectable_container.dart class where all the
> injection should take place

---

### 15. Validate the existing orchestrator workflow

**Prompt:**
> now review the existing orchestrator and make sure it is actually using the agents, skills and rules correctly.
> based on the type of task it should select the appropriate agent and skills, and the code review agent should check the changes against the project rules. 
> don't add unnecessary agents or workflows, just fix anything missing in the current setup.

---

### 16. Meaningful tests, not exhaustive ones — 2026-08-24
**Tool:** Claude Code

**Prompt:**
> so do the meaningful test what is actual needed and all let me know how this
> has to be done becoz if interviewer ask me then i should also be able to do
> it

(after checking the brief's actual wording on testing — "a handful of tests
that actually matter beats 100% coverage on trivial stuff" — and narrowing a
long list of possible test gaps down to the two that genuinely mattered)

**Outcome:**
Added `getForecast()` test coverage to `weather_repository_impl_test.dart`
(online success + caching, offline fallback, offline-with-no-cache) — this
method had its own separate offline-branching logic that was completely
untested, unlike `getCurrentWeather`'s identical-shaped logic. Added a new
`test/data/favorites_local_datasource_test.dart` (4 tests) covering the
actual bug found earlier this session: a malformed cache entry no longer
breaks the whole favorites list, and city keys are case-insensitive. Used
two different testing techniques depending on how each class receives its
dependencies: `mocktail` for the repository (constructor-injected
interfaces), a real temporary-directory Hive instance for the datasource
(which calls `Hive.box(...)` internally, nothing to inject a mock into).

---

### 17. Tests that had never actually been run had real bugs — 2026-08-24
**Tool:** Claude Code

**Prompt:**
> [pasted real `flutter test` output, across several rounds]

**Outcome:**
Running the suite for the first time surfaced four genuine, pre-existing
bugs that had never been caught because these tests had never actually
been executed successfully before — none of them were introduced this
session:
1. `weather_repository_impl_test.dart` never called
   `registerFallbackValue()` for `WeatherModel`/`ForecastModel` — mocktail
   requires this for any custom type used with `any()`, and its absence
   also corrupted mocktail's internal matcher state enough to cause
   confusing, seemingly-unrelated failures in the next test.
2. `search_home_screen_test.dart` never initialized Hive, but
   `SearchHomeScreen.initState()` calls `Hive.box(...)` directly — the
   widget crashed on build with `Box not found`.
3. The same file's `FakeWeatherNotifier` passed `throw
   UnimplementedError()` directly as a constructor argument — Dart
   evaluates constructor arguments eagerly, so this threw immediately on
   construction, before the constructor body even ran. Replaced with
   harmless `mocktail` mock instances instead, since those fields are
   genuinely never invoked once `searchCity`/`retry` are overridden.
4. `search_home_screen.dart` reads `favoritesProvider` unconditionally at
   the top of `build()` (for the star-icon state), but the test never
   overrode it — it hit real, unregistered `GetIt` and threw. Added a
   `FakeFavoritesNotifier` override, same reasoning as #3.

Fixed all four, one round at a time, each verified by the user actually
re-running `flutter test` and pasting the real output back — not assumed
fixed from code review alone.

---
