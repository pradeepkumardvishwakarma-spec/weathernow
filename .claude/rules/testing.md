# Testing Rule

A handful of tests that matter beats 100% coverage on trivial code. For this project, that means:

- Repository layer: online success, offline fallback, error mapping.
- Forecast day-grouping logic (3-hour slots → daily buckets).
- At least one widget test proving the error state never leaks a raw exception string.

Don't write tests for generated boilerplate, trivial getters, or framework code.
