# Weather Feature Skill

Adding or changing anything in the `weather` feature, in order:

1. Define/verify the domain contract (entity, abstract repository method, use case).
2. Implement the data source + model mapping (remote: Dio/JSON, local: Hive).
3. Implement repository behavior and failure mapping (`Exception` → `Failure`).
4. Wire the use case through `injection_container.dart` and expose it via a Riverpod provider.
5. Implement presentation state + UI.
6. Test success, failure, and offline behavior — not just the happy path.
