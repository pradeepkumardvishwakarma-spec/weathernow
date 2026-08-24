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

### 2. [next entry — e.g. fixing `flutter pub get` / `flutter run` errors]
**Tool:**
**Prompt:**

**Outcome:**

---

*(continue adding entries here as you go — one per meaningful AI interaction,
added in the same commit as the resulting code change)*
