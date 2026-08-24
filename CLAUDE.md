CLAUDE.md

WeatherNow project rules

This file is read by Claude Code at the start of every session in this repo.

It exists so the AI output stays consistent with the assignment constraints without me having to repeat them in every prompt.

NON NEGOTIABLE CONSTRAINTS

- Keep UI, business logic, and data separate
- Riverpod only for state management.
- Never suggest Provider, Bloc, GetX, or setState based state for anything beyond truly local widget state such as a TextField focus.

CLEAN ARCHITECTURE

- Follow Clean Architecture with three strictly separated layers.
- Data contains datasources, models and repository implementations.
- Domain contains entities, abstract repositories and use cases.
- Presentation contains providers, screens and widgets.
- The domain layer must never import Flutter, Dio or Hive.
- Widgets must never call a datasource or Dio directly.
- Communication must always happen through the provider, use case and repository layers.

DEPENDENCY INJECTION

- get_it is the service locator.
- New dependencies must be registered in core/di/injection_container.dart.
- Dependencies must not be instantiated directly inside widgets.
- The dependency setup should keep the application loosely coupled and testable.

NETWORKING

- Dio must be used for networking.
- Every network calling use case must accept and pass through a CancelToken.
- Configure appropriate connection and receive timeouts.
- Handle network exceptions inside the data layer.
- Never expose raw Dio exceptions or backend error messages to the UI.

LOCAL PERSISTENCE

- Hive must be used for local persistence and caching.
- connectivity_plus must be used for online and offline detection.
- The presentation layer must not access Hive directly.
- Repository implementations should control whether data comes from the remote datasource or local datasource.

NAVIGATION

- go_router must be used for application navigation.
- Navigation logic should remain separate from business logic.

IMAGE LOADING

- cached_network_image must be used for remote weather images.
- Provide appropriate loading and error handling for remote images.

SEARCH

- Search input must use a 600 millisecond debounce.
- Never fire an API request for every keystroke.
- Use CancelToken to cancel obsolete search requests where appropriate.
- Handle empty search input and API failures properly.

ERROR HANDLING

- Never allow the UI to display a raw exception or error string.
- The data layer can throw Exceptions.
- Repositories must catch those Exceptions.
- Repositories that call the network (weather) must return Either<Failure, T> using dartz, so real failure modes (timeout, no connection, server error, city not found) map to predefined, user friendly messages. Only Failure.message should reach the presentation layer.
- Repositories that are purely local (favorites, settings) may return plain values instead of Either<Failure, T> — their only failure mode is corrupted local storage, which should be handled defensively inside the repository (skip or ignore the bad entry) rather than modeled as a Failure type with nothing meaningful to say.

API SECURITY

- The API key must never be hard coded.
- The API key must never be committed to Git.
- Load the API key through flutter_dotenv.
- Store the API key in a git ignored .env file.
- Never put the API key inside a constants file or widget.

STYLE

- Prefer composition over inheritance for widgets.
- Keep widgets focused on presentation.
- Keep business logic outside widgets.
- Every new file should have a short documentation comment explaining why the file exists when the reasoning is not obvious.
- Do not add a new package dependency without informing me first.
- Every dependency choice should be justifiable in the README.

WHAT NOT TO DO

- Do not silently fix failing offline behavior by showing only an error screen.
- The brief requires showing the last known cached data with a staleness label.
- Do not add pagination or infinite scroll logic to the five day forecast strip.
- There are only five forecast items.
- ListView.builder is used for lazy building and consistency, not pagination.
- Do not refactor the offline strategy to make Home and Favorites identical.
- Home intentionally uses an online first strategy.
- Favorites intentionally uses a cache first strategy.
- If you believe this behavior is incorrect, flag it instead of changing it silently.

WORKING STYLE

- When changing or generating code, explicitly tell me if something in Flutter, Dart or a package API does not work as originally assumed.
- Explain what was corrected and why.
- Maintain a running record of such corrections in docs/ai/AI_REVIEW.md.
- Prefer smaller and reviewable changes instead of one large rewrite.
- Do not make unrelated changes while implementing a requested feature.