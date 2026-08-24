# Architecture Rule

- `domain/` never imports `flutter`, `dio`, or `hive`.
- Widgets never call a datasource or repository directly — always provider → use case → repository.
- New dependencies register in `core/di/injection_container.dart`, never instantiated inline.
- Data-layer `Exception`s never reach presentation un-translated — repositories convert to `Failure`.
