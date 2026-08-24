# WeatherNow Architecture

```text
Presentation
  Riverpod Notifiers / Widgets / Screens
          |
        UseCases
          |
Domain Repository Interfaces
          |
Data Repository Implementations
      /           \
Remote Data     Local Data
   |               |
  Dio             Hive
```

Connectivity determines whether network retrieval is attempted.
Successful network weather is cached with a timestamp.
Presentation receives domain entities and application state, not API models.
