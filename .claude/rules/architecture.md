# Architecture Rule

- `domain/` never imports `flutter`, `dio`, or `hive`.
- Widgets never call a datasource or repository directly — always provider → use case → repository.
- New dependencies register in `core/di/injection_container.dart`, never instantiated inline.
- Data-layer `Exception`s never reach presentation un-translated — repositories convert to `Failure`.
- No hardcoded structural string constants — Hive box names, settings keys, API endpoint paths,
  `.env` key names, the icon CDN base URL, and `go_router` route paths all live in
  `core/utils/constants.dart` (`HiveBoxes`, `SettingsKeys`, `ApiEndpoints`, `EnvKeys`,
  `WeatherAssets`, `AppRoutes`), referenced from there — never typed as a raw string literal a
  second time in a screen/widget/provider. This isn't about user-facing display text (button
  labels, titles) — only identifiers that must stay in sync across files.
- No hardcoded `Colors.*`/raw `Color(0x...)` values in `presentation/` — every color lives in
  `core/theme/app_theme.dart`'s `AppTheme` (`primaryColor`, `accentColor`, `warningColor`,
  `dangerColor`, `starColor`, `mutedColor`, `iconBackdrop`, `textColor`, `lightText`,
  `surfaceWhite`) and is
  referenced from there, or comes from `Theme.of(context).colorScheme.*` (which itself derives
  from `AppTheme.primaryColor`'s seed). Pick the semantically closest existing constant before
  adding a new one — `warningColor` for stale/cached-data indicators, `dangerColor` for errors,
  `accentColor` for "live"/positive states.
