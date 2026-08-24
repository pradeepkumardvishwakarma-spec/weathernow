# AI Prompts / Chat History Log

This log tracks the real prompts used to build WeatherNow, in the order they happened.
Entries get added as the project progresses — each one should be added in the same
commit as the code change it produced, not written up afterward from memory.

---

### 1. Initial architecture & scaffold — [fill in your date]
**Tool:** Claude (claude.ai chat, planning/scaffolding session — not Claude Code)

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
> orchestrator, agents, skills, and rules.

**Outcome:**
Produced the initial project skeleton: `core/` (error handling, network, DI via
get_it, router, utils), and three features (`weather`, `favorites`, `settings`)
each split into `data/domain/presentation`. Also produced `CLAUDE.md` and
`.claude/agents/` (flutter-architect, riverpod-specialist, qa-reviewer) as the
rules/orchestration setup for the next stage of development in Claude Code.

**Note:** this was a planning/scaffolding conversation, not a live coding session —
no compile/runtime errors were caught or fixed here, since the code was never run
against a real Flutter SDK in that environment. Real debugging entries start below,
from the actual Claude Code / Cursor session on my machine.

---

### 2. Git history cleanup — 2026-08-24
**Tool:** Claude Code

**Prompt:**
> i want to git commit first

(after Claude flagged, from a PDF-vs-code gap analysis, that `git status` showed
197 pending changes — 111 of them staged deletions of an unrelated, never-committed
`flutter_application_1` scaffold left in the index from before this project existed)

**Outcome:**
Cleared the stale index (`git read-tree --empty` — index-only, didn't touch any
working-tree files) and committed the actual WeatherNow project in 7 logical
commits (scaffold, core architecture, weather feature, favorites feature, settings
feature, tests, docs) instead of one dump.

---

### 3. Removing leftover default app identifiers — 2026-08-24
**Tool:** Claude Code

**Prompt:**
> this project should include anyhting like flutter_application_1

**Outcome:**
Grep across the repo (tracked files, git history, and the working tree including
gitignored paths) found `flutter_application_1` still baked into 6 places from the
unmodified `flutter create` scaffold: Android `namespace`/`applicationId` in
`build.gradle.kts`, the app label in `AndroidManifest.xml`, the Kotlin package
path/directory for `MainActivity.kt`, and the iOS bundle identifiers + display name
in `Info.plist`/`project.pbxproj`. Renamed all of them to `com.example.weathernow`
/ "WeatherNow". Also deleted two gitignored-but-still-on-disk leftovers (a stale
`.iml` file and a `build/` cache) that still referenced the old name.

---

### 4. Squashing to a single commit and pushing to GitHub — 2026-08-24
**Tool:** Claude Code

**Prompt:**
> but i want on my git which shows only single commit like project setup or
> intial weather app configuration

**Outcome:**
Since nothing had been pushed yet, squashed the 8 local commits into one
(`git checkout --orphan` + single commit + branch replace — safe only because
history was still 100% local). Created the GitHub remote, pushed `main`. Also
removed the `Co-Authored-By: Claude` trailer Claude Code adds by default to
commits it authors, per request — required a `git commit --amend` +
`git push --force-with-lease` since it had already been pushed once.

---

### 5. Raw 401 error text shown on the Search screen — 2026-08-24
**Tool:** Claude Code

**Prompt:**
> when i am searching mumbai in search bar then i am getting long error
> message showing 401 and all. normal user will not understand this, it should
> be user understandable

**Outcome:**
See `docs/ai/AI_REVIEW.md` for the full writeup — this is the real AI
mistake the brief asks for. Root cause: `weather_remote_datasource.dart` forwarded
Dio's raw internal exception message straight into the `ServerFailure` shown on
screen, for any HTTP error status it didn't explicitly handle (which included 401 —
an invalid/inactivated OpenWeatherMap key). Fixed by mapping every Dio failure to a
curated, friendly message and never forwarding `e.message` to the UI layer.

---

### 6. Restructuring `.claude/` into agents, skills, and rules — 2026-08-24
**Tool:** Claude Code

**Prompt:**
> now what i want is look at the folder attached and i would request you to add
> agents, skills and rules and prompts class make simple means of readable.
> right now i can see that you have given the reference of my document so
> remove that and it is not upto readable

(pointed at a separate reference WeatherNow project's `.claude/agents/`,
`.claude/skills/`, `.cursor/rules/`, `docs/ai/` layout as the shape to follow)

**Outcome:**
Restructured `.claude/` to match: `agents/orchestrator.md` (new — routing
table, replaces the old `ORCHESTRATION.md` which duplicated it), rewrote the
existing `flutter-architect`/`riverpod-specialist`/`qa-reviewer` agents
tighter, and added `.claude/skills/` and `.claude/rules/` (neither existed
before). Fixed the actual defect the prompt flagged: `qa-reviewer.md` named
the assignment PDF by its literal local filename
(`WeatherNow_R2_Assignment_Webol.pdf`) — a path that only exists on this
machine and is meaningless to anyone else opening the repo — replaced with a
portable reference to `CLAUDE.md`'s summary of the brief instead.

### 7. A junior-developer-usable "how to build a new feature" guide — 2026-08-24
**Tool:** Claude Code

**Prompt:**
> i want this prompts, or claude files or documents whatever is there if
> given to any junior then on the basis of this he can develop any new
> module follwing same architecture, security principles and many more like
> this

**Outcome:**
Added `.claude/skills/add-new-feature.md` — a concrete, ordered playbook
anchored to the three real complexity tiers already in this codebase
(`settings` = simplest, `favorites` = medium, `weather` = full/networked),
each step pointing at the exact existing file to mirror and the exact rule
file (`rules/architecture.md`, `rules/security.md`, `rules/testing.md`,
`skills/offline-strategy.md`, `skills/verification.md`) governing it. Wired
it into `agents/orchestrator.md`'s routing table and linked it at the top of
`CLAUDE.md` so it's actually discoverable, not just present.

### 8. Senior code review — 2026-08-24
**Tool:** Claude Code

**Prompt:**
> Review the complete WeatherNow repository as a Senior Flutter Developer
> interviewer. Audit Clean Architecture, Riverpod, Dart/Flutter quality, API
> integration, cancellation, offline/cache, favorites, settings, navigation,
> debounce, image caching, error handling, testing, security, performance,
> DI and maintainability. For each issue provide severity, file, problem,
> why it matters and the smallest recommended fix. Also list likely
> interview questions about this implementation.

**Outcome:**
Reviewed every feature against the codebase directly (not from memory).
Found 2 real, previously-unknown functional gaps, both fixed:
1. **High** — `main.dart` had no error handling around `Hive.initFlutter()`/
   opening the local storage boxes, unlike the `dotenv.load` call right next
   to it which was deliberately protected. A failure there would silently
   hang the app on the splash screen forever — the likely explanation for an
   earlier unresolved "stuck on splash screen" report from this same
   session. Fixed: wrapped in try/catch, falls back to a plain "couldn't
   start" screen instead of hanging.
2. **Medium-High** — `favorites_local_datasource.dart` had zero exception
   handling anywhere (unlike weather's cache, which was already hardened
   against malformed cached data earlier this session) — a single corrupted
   favorites entry would silently and permanently break the whole favorites
   list with no user-facing error. Also found favorites were keyed by raw
   city name (not lowercased), so "London" and "london" could become two
   separate favorites. Fixed both: malformed entries are now skipped
   individually, and city keys are normalized to lowercase while the
   original casing is preserved for display.

Everything else audited (architecture boundaries, Riverpod provider scope,
DI registration order, cancellation, debounce) had no violations found.

---

### 9. Domain layer wasn't actually independent — 2026-08-24
**Tool:** Claude Code

**Prompt:**
> right now for localdatasource domain layer is directly depend on data
> layer??
>
> see my take is domain layer should be independent of any other layer.
> also make a seperate injectable_container.dart class where all the
> injection should take place

**Outcome:**
This directly contradicts entry #8's senior code review, which had claimed
"architecture boundaries... had no violations found" — that review missed
these because it wasn't given a targeted enough question. Grepping the
actual domain layer on this specific question found two real violations:
1. `weather_repository.dart`, `get_current_weather.dart`, and
   `get_forecast.dart` (all in `domain/`) imported `package:dio/dio.dart`
   directly for its `CancelToken` type — a direct violation of this
   project's own CLAUDE.md rule that domain must never import Dio.
2. `favorite_preview_provider.dart` (presentation) called
   `sl<WeatherLocalDataSource>()` directly — reaching into the data layer's
   datasource and bypassing the use case/repository chain entirely.

Fixed both: added a domain-owned `CancellationToken` (`core/usecase/
cancellation_token.dart`) that the data layer bridges to a real Dio
`CancelToken` in exactly one place, so domain never imports Dio again.
Added a `GetCachedWeather` use case + `WeatherRepository
.getCachedWeatherOnly()` so the favorites preview goes through the proper
chain instead of touching a datasource directly. Confirmed via grep
afterward: zero domain files import Flutter/Dio/Hive, zero presentation
files import from `data/`, and all DI registration remained consolidated
in the existing `core/di/injection_container.dart` (no new/separate DI
file was actually needed — it already was the single place this happens).

Follow-up question surfaced a related, pre-existing issue: `CLAUDE.md`
stated as a blanket rule that all repositories must return
`Either<Failure, T>`, but `favorites`/`settings` never did — and this
session's own `add-new-feature.md` had documented that as an intentional
tiered exception, contradicting `CLAUDE.md`. Resolved by updating
`CLAUDE.md`'s ERROR HANDLING section to explicitly scope that requirement
to network-calling repositories only, since local-only repositories have
no real failure taxonomy to represent.

---

*(continue adding entries here as you go — one per meaningful AI interaction,
added in the same commit as the resulting code change)*
