# Offline Strategy Skill

This app has two different offline patterns, on purpose — never merge them into one.

**Home/Search — online-first** (`WeatherNotifier` in `weather_provider.dart`)
Try the network first via `GetCurrentWeather`/`GetForecast`. On failure, `WeatherRepositoryImpl`
falls back to the last cached reading for that city. Show an "updated Xh ago · offline" badge
(`WeatherCard`'s `isFromCache` branch) when serving cached data.

**Favorites — cache-first** (`FavoritePreviewNotifier` in `favorite_preview_provider.dart`)
`_loadCacheThenRefresh()` calls `GetCachedWeather` first and shows it instantly (no spinner),
then calls `GetCurrentWeather` in the background and silently replaces the state if it succeeds.
If the background refresh fails and cached data is already on screen, keep showing it rather
than surfacing the error — never block the UI on a fresh fetch for a saved favorite.

If a change makes these two behave identically, that's a bug — flag it to the user instead of "cleaning it up."
