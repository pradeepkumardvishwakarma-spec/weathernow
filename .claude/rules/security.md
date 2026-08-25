# Security Rule

- API key: never hard-coded, never committed. Lives only in git-ignored `assets/env/.env`, loaded via `flutter_dotenv`. The `.env` key *names* (`OPEN_WEATHER_API_KEY`, `OPEN_WEATHER_BASE_URL`) and file path live in `core/utils/constants.dart`'s `EnvKeys` — one source of truth so a typo in a key name can't silently fail in two different places.
- Never log a full request/response that could contain the API key.
- The UI never shows a raw exception/error string — only a pre-written `Failure.message`.
- No secrets stored in Hive.
- Root/jailbreak detection was evaluated and implemented, then removed — the detection libraries flagged emulators as compromised (a well-known false-positive mode for this category of package), which would block the app from opening at all in an emulator review environment. Not re-added without a device-vs-emulator-safe detection method. See README's Security notes for the full reasoning.
