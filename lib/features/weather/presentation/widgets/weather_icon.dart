import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:weathernow/core/theme/app_theme.dart';
import 'package:weathernow/core/utils/constants.dart';

/// Wraps OpenWeatherMap's icon CDN with disk+memory caching so we're
/// not re-downloading the same handful of icons on every rebuild/scroll
/// — directly addresses the "cache images" performance requirement.
class WeatherIcon extends StatelessWidget {
  final String iconCode;
  final double size;

  const WeatherIcon({super.key, required this.iconCode, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final url = '${WeatherAssets.iconBaseUrl}/$iconCode@2x.png';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // The glyphs are white/light-on-transparent, so on a white or
    // near-white card they'd otherwise disappear - a light sky blue
    // backdrop gives them contrast in light mode only. Dark mode's cards
    // are already dark enough for the glyph to show on their own, so the
    // backdrop would just be an unnecessary light patch there. The image
    // itself is sized a bit smaller than the backdrop so a ring of it
    // stays visible; the outer footprint still matches `size` exactly
    // either way, so this doesn't shift layout anywhere WeatherIcon is used.
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? Colors.transparent : AppTheme.iconBackdrop,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: CachedNetworkImage(
          imageUrl: url,
          width: size * 0.8,
          height: size * 0.8,
          fadeInDuration: const Duration(milliseconds: 150),
          placeholder: (context, url) => SizedBox(
            width: size * 0.8,
            height: size * 0.8,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          errorWidget: (context, url, error) => Icon(Icons.cloud_outlined, size: size * 0.8),
        ),
      ),
    );
  }
}
