import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Wraps OpenWeatherMap's icon CDN with disk+memory caching so we're
/// not re-downloading the same handful of icons on every rebuild/scroll
/// — directly addresses the "cache images" performance requirement.
class WeatherIcon extends StatelessWidget {
  final String iconCode;
  final double size;

  const WeatherIcon({super.key, required this.iconCode, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final url = 'https://openweathermap.org/img/wn/$iconCode@2x.png';
    return CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: (context, url) => SizedBox(
        width: size,
        height: size,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => Icon(Icons.cloud_outlined, size: size),
    );
  }
}
