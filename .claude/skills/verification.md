# Verification Skill

Before calling any change done:

1. `dart format .`
2. `flutter analyze`
3. `flutter test`
4. Manually exercise the actual flow changed — a passing analyzer/test run is not the same as "the feature works."
5. Re-check against the relevant numbered behavior in the brief, not just "it compiles."

Never report a step as done without actually running it.
