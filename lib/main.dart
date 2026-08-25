import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:weathernow/core/di/injection_container.dart';
import 'package:weathernow/core/router/app_router.dart';
import 'package:weathernow/core/theme/app_theme.dart';
import 'package:weathernow/core/utils/constants.dart' show EnvKeys, HiveBoxes;
import 'package:weathernow/features/settings/presentation/providers/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load API key from assets/env/.env (never committed — see .gitignore).
  // Falls back gracefully so a missing .env doesn't crash the app at boot;
  // the user just sees a friendly "no connection"/server error instead.
  try {
    await dotenv.load(fileName: EnvKeys.envFilePath);
  } catch (_) {
    // Missing .env in a fresh checkout — surfaced clearly in README instead
    // of letting Flutter's default red-screen crash confuse a reviewer.
  }

  try {
    await Hive.initFlutter();
    // Independent boxes — open them concurrently instead of one after another.
    await Future.wait([
      Hive.openBox(HiveBoxes.weatherCache),
      Hive.openBox(HiveBoxes.favorites),
      Hive.openBox(HiveBoxes.settings),
    ]);
  } catch (_) {
    // If local storage can't be set up at all, the app can't function —
    // but it should say so instead of silently hanging on the splash screen.
    runApp(const _StartupErrorApp());
    return;
  }

  await initDependencyInjection();

  final container = ProviderContainer();
  // Load persisted unit preference before first frame so there's no
  // flash of the default unit before the real one loads.
  await container.read(settingsProvider.notifier).load();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const WeatherNowApp(),
    ),
  );
}

/// Shown only if local storage fails to initialize at all — never a raw
/// exception string, per this project's own error-handling rule.
class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              "WeatherNow couldn't start. Please close and reopen the app.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      ),
    );
  }
}

class WeatherNowApp extends StatelessWidget {
  const WeatherNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'WeatherNow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
