import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:weathernow/core/theme/app_theme.dart';
import 'package:weathernow/core/utils/constants.dart';
import 'package:weathernow/features/weather/presentation/widgets/weather_icon.dart';
import 'package:weathernow/features/settings/presentation/providers/settings_provider.dart';
import 'package:weathernow/core/utils/time_ago.dart';
import 'package:weathernow/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:weathernow/features/favorites/presentation/providers/favorite_preview_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    if (favorites.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Favorites')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'No favorites yet. Star a city from the Home screen.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      // ListView.builder: only builds visible rows — matters as the
      // favorites list grows, keeps scrolling smooth per the brief.
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final fav = favorites[index];
          return Dismissible(
            key: ValueKey(fav.cityName),
            direction: DismissDirection.endToStart,
            background: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.dangerColor,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: AppTheme.surfaceWhite),
            ),
            onDismissed: (_) => ref.read(favoritesProvider.notifier).remove(fav.cityName),
            child: _FavoriteTile(cityName: fav.cityName),
          );
        },
      ),
    );
  }
}

class _FavoriteTile extends ConsumerWidget {
  final String cityName;
  const _FavoriteTile({required this.cityName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preview = ref.watch(favoritePreviewProvider(cityName));
    final settings = ref.watch(settingsProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(cityName),
        subtitle: preview.maybeWhen(
          data: (w) => w.isFromCache
              ? Text('Updated ${timeAgo(w.fetchedAt)}', style: const TextStyle(color: AppTheme.warningColor))
              : Text('Live', style: const TextStyle(color: AppTheme.accentColor)),
          orElse: () => null,
        ),
        leading: preview.maybeWhen(
          data: (w) => WeatherIcon(iconCode: w.iconCode, size: 44),
          orElse: () => const SizedBox(width: 44, height: 44, child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        trailing: preview.maybeWhen(
          data: (w) => Text('${convertTemp(w.temperature, settings.unit).round()}${unitSuffix(settings.unit)}'),
          orElse: () => null,
        ),
        onTap: () => context.push(AppRoutes.city(cityName)),
      ),
    );
  }
}
