# Security Rule

- API key: never hard-coded, never committed. Lives only in git-ignored `assets/env/.env`, loaded via `flutter_dotenv`.
- Never log a full request/response that could contain the API key.
- The UI never shows a raw exception/error string — only a pre-written `Failure.message`.
- No secrets stored in Hive.
