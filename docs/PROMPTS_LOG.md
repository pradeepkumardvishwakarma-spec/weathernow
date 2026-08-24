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
> in which i am searching mumbai in search bar then i am getting long error
> message showing 401 and all. normal user will not understand this, it should
> be user understandable

**Outcome:**
See `docs/AI_ASSISTANCE_NOTES.md` for the full writeup — this is the real AI
mistake the brief asks for. Root cause: `weather_remote_datasource.dart` forwarded
Dio's raw internal exception message straight into the `ServerFailure` shown on
screen, for any HTTP error status it didn't explicitly handle (which included 401 —
an invalid/inactivated OpenWeatherMap key). Fixed by mapping every Dio failure to a
curated, friendly message and never forwarding `e.message` to the UI layer.

---

*(continue adding entries here as you go — one per meaningful AI interaction,
added in the same commit as the resulting code change)*
