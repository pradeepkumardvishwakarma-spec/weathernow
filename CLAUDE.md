# CLAUDE.md — WeatherNow project rules

This file is read by Claude Code at the start of every session in this repo.
It exists so the AI's output stays consistent with the assignment's constraints
without me having to repeat them in every prompt.

## Non-negotiable constraints (from the Webol take-home brief)

- **Riverpod only** for state management. Never suggest Provider, Bloc, GetX, or setState-based
  state for anything beyond truly-local widget state (e.g. a TextField's own focus).
- **Clean architecture, 3 layers, strictly separated**: `data/` (datasources, models, repository impl),
  `domain/` (entities, abstract repositories, use cases), `presentation/` (providers, screens, widgets).
  - Domain layer must never import Flutter, Dio, or Hive.
  - Widgets must never call a datasource or Dio directly — always through a provider → use case → repository.
- **get_it** is the service locator. New dependencies get registered in `core/di/injection_container.dart`,
  not instantiated inline in widgets.
- **Dio** for networking, **Hive** for local persistence, **go_router** for navigation,
  **cached_network_image** for any remote image, **connectivity_plus** for online/offline detection.
- Every network-calling use case must accept and thread through a `CancelToken`.
- Search inputs must be debounced (600ms) — never fire a request per keystroke.
- **Never let the UI display a raw exception/error string.** Data layer throws `Exception`s;
  repositories catch them and return `Either<Failure, T>` (dartz) with a pre-written,
  user-friendly message. Only `Failure.message` reaches a widget.
- API key must never be hard-coded or committed. It's loaded via `flutter_dotenv` from a
  git-ignored `.env` asset. Don't suggest putting it in a constants file or a widget.

## Style

- Prefer composition over inheritance for widgets.
- Every new file gets a short doc comment explaining *why*, not just what, when the reasoning
  isn't obvious from the code itself (see existing files for the expected tone).
- Don't add a new package dependency without flagging it to me first — I need to justify every
  dependency choice in the README.

## What NOT to do

- Don't silently "fix" failing offline behavior by just showing an error screen — the brief
  requires showing last-known cached data with a staleness label instead.
- Don't add pagination/infinite-scroll logic to the 5-day forecast strip (only 5 items — no
  real pagination need); `ListView.builder` there is for lazy-build/consistency, not paging.
- Don't refactor the offline strategy to be identical between Home and Favorites — they're
  intentionally different (online-first vs cache-first) per the brief's wording. Flag it if
  you think this is wrong instead of "harmonizing" it silently.

## Working style for this session

- When you change or generate code, tell me explicitly if something in Flutter/Dart/a package's
  API doesn't work the way you assumed, and what you had to correct — I'm keeping a running log
  of this in docs/AI_ASSISTANCE_NOTES.md for the submission.
- Prefer smaller, reviewable diffs over one giant rewrite.
