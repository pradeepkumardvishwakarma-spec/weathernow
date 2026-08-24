# AI Assistance Notes

> The brief asks for a real account of where the AI got something wrong in Flutter/Dart,
> how you caught it, and what you changed. **This section needs your own genuine example**
> from working through this project in Claude Code/Cursor — reviewers are specifically
> assessing your judgment in catching AI mistakes, so this shouldn't be fabricated.
>
> What follows is a framework of categories where AI coding tools commonly get Flutter/Dart
> wrong, to help you recognize and document a real instance if/when you hit one — not a
> set of claims to copy in as if they were your own findings.

## Categories worth watching for while you build

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

## Template for your real entry

```
### What the AI suggested
[paste or describe]

### Why it was wrong
[the specific Flutter/Dart behavior it got wrong]

### How you caught it
[compile error / runtime crash / test failure / manual review]

### What you changed
[the actual fix, ideally with a before/after snippet]
```

*(Replace this whole section with your real example(s) before submitting.)*
