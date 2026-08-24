import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/constants.dart';
import 'features/settings/presentation/providers/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load API key from assets/env/.env (never committed — see .gitignore).
  // Falls back gracefully so a missing .env doesn't crash the app at boot;
  // the user just sees a friendly "no connection"/server error instead.
  try {
    await dotenv.load(fileName: 'assets/env/.env');
  } catch (_) {
    // Missing .env in a fresh checkout — surfaced clearly in README instead
    // of letting Flutter's default red-screen crash confuse a reviewer.
  }

  await Hive.initFlutter();
  // Independent boxes — open them concurrently instead of one after another.
  await Future.wait([
    Hive.openBox(HiveBoxes.weatherCache),
    Hive.openBox(HiveBoxes.favorites),
    Hive.openBox(HiveBoxes.settings),
  ]);

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
