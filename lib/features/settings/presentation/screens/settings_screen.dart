import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weathernow/features/settings/domain/entities/settings_entity.dart';
import 'package:weathernow/features/settings/presentation/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isFahrenheit = settings.unit == TemperatureUnit.fahrenheit;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Use Fahrenheit'),
            subtitle: Text(isFahrenheit ? 'Showing °F' : 'Showing °C'),
            value: isFahrenheit,
            onChanged: (_) => ref.read(settingsProvider.notifier).toggleUnit(),
          ),
        ],
      ),
    );
  }
}
