# Add a New Feature — Step-by-Step

A playbook for building a new feature module in this codebase, so it comes out looking
like it was written by the same person who built `weather`/`favorites`/`settings` — same
layer boundaries, same security posture, same testing bar. Follow it in order.

## Step 0 — pick your complexity tier

This codebase already has three real examples at three different complexity levels.
Find the one closest to what you're building and copy *that* file shape, not a
theoretical "ideal" one.

| Tier | Copy this feature | Use when |
|---|---|---|
| **Simple** — local-only, can't meaningfully fail | `settings` | A single preference/flag stored in Hive. No explicit use-case class needed; the provider calls the repository directly. |
| **Medium** — local-only, several operations | `favorites` | CRUD-ish operations on local data. Explicit use-case classes (one per operation), but no `Either<Failure, T>` — local Hive ops here are treated as non-failing. |
| **Full** — hits the network | `weather` | Anything calling an external API. Explicit `UseCase<Type, Params>` (see `core/usecase/usecase.dart`), `Either<Failure, T>` return type, a `CancelToken` param, and a remote+local datasource split with online/offline fallback. |

If you're not sure which tier, ask: *"can this operation fail in a way the user needs a
friendly message for?"* — no → Simple/Medium. Yes → Full.

## Step 1 — scaffold the folders

Replace `<feature>` with your feature name (lowercase, e.g. `alerts`):

```
lib/features/<feature>/
  data/
    datasources/     # only if Full tier — remote_datasource.dart, local_datasource.dart
    models/           # only if Full tier — *_model.dart (extends the domain entity, adds fromJson/toJson)
    repositories/     # <feature>_repository_impl.dart
  domain/
    entities/         # <feature>_entity.dart — plain Dart, zero Flutter/Dio/Hive imports
    repositories/      # <feature>_repository.dart — abstract class
    usecases/          # only if Medium/Full — one class per operation
  presentation/
    providers/        # <feature>_provider.dart (Riverpod StateNotifier + provider)
    screens/           # only if this feature needs its own screen
    widgets/           # only if it needs feature-specific widgets
```

## Step 2 — domain first

Write `entities/<feature>_entity.dart` before anything else. It's the contract everything
else builds against. Rules (see `rules/architecture.md`):
- `extends Equatable`, all fields `final`, `const` constructor.
- Zero imports from `flutter`, `dio`, or `hive`.

Then `repositories/<feature>_repository.dart` — an abstract class listing the methods
presentation will need. Full tier: methods return `Future<Either<Failure, T>>` and accept
a `CancelToken?`. Simple/Medium tier: plain `Future<T>` is fine (see `settings_repository.dart`
for the smallest real example).

## Step 3 — data layer

- **Full tier only**: `datasources/<feature>_remote_datasource.dart` (Dio calls, throws
  typed `Exception`s from `core/error/exceptions.dart` — never lets a raw `DioException`
  escape) and `<feature>_local_datasource.dart` (Hive reads/writes, throws `CacheException`
  on miss/corruption — see `weather_local_datasource.dart` for the defensive-cast pattern
  on cache reads, since cached data can't be assumed well-formed the way a fresh API
  response can).
- `repositories/<feature>_repository_impl.dart` implements the domain interface. This is
  the **only** place that translates data-layer `Exception`s into domain `Failure`s
  (Full tier) — see `weather_repository_impl.dart` for the online/offline branching
  pattern if this feature needs offline support. Read `skills/offline-strategy.md` before
  deciding which of the two existing patterns (online-first vs cache-first) fits — don't
  invent a third one without a reason.

## Step 4 — use cases (Medium/Full tier)

One small class per operation, in `domain/usecases/`. Full tier implements
`UseCase<Type, Params>` from `core/usecase/usecase.dart`; Medium tier (see
`manage_favorites.dart`) can skip that base class since there's no `Failure` to return.

## Step 5 — wire dependency injection

Add to `core/di/injection_container.dart`, in this exact order — datasource(s) →
repository → use cases — following the existing feature blocks as the template:

```dart
sl.registerLazySingleton<YourFeatureRepository>(() => YourFeatureRepositoryImpl(sl()));
sl.registerFactory(() => YourUseCase(sl()));
```

Never instantiate a repository/datasource inline inside a widget or provider — that's the
#1 violation `flutter-architect` checks for.

## Step 6 — presentation

- `StateNotifier` + provider in `presentation/providers/`. Decide `.autoDispose` vs
  persistent per `riverpod-specialist`'s rule: transient/per-session state is
  `.autoDispose`; anything that must survive navigating away is not.
- If it needs a screen, add the route in `core/router/app_router.dart`, and if it needs a
  bottom-nav tab, add a `NavigationDestination` in `core/router/app_shell.dart`.
- Widgets never import Dio/Hive or call a repository/datasource directly — only
  `ref.watch`/`ref.read` on the provider.

## Step 7 — security check

Before moving on, confirm against `rules/security.md`:
- Nothing in this feature hard-codes a secret or logs a full request.
- No raw exception string can reach a widget — only `Failure.message` (Full tier) or a
  value the UI already knows how to render (Simple/Medium tier).

## Step 8 — test what can actually break

Per `rules/testing.md` — not everything needs a test. Worth covering:
- Repository logic with a real branch (online/offline, or any conditional) — mock the
  datasource(s), assert the right `Failure`/value comes out.
- Any non-trivial data transformation (e.g. the forecast day-grouping logic).
- Skip tests for trivial getters, generated code, and pure pass-through methods.

## Step 9 — verify

Run `skills/verification.md`'s checklist before calling it done. Then run `qa-reviewer`
against the actual behavior the feature is supposed to have, not just "it compiles."
