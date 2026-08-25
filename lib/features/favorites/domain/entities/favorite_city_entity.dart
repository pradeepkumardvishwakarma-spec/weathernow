import 'package:equatable/equatable.dart';

class FavoriteCityEntity extends Equatable {
  final String cityName;
  final DateTime addedAt;
  const FavoriteCityEntity({required this.cityName, required this.addedAt});

  // City-name equality is case-insensitive throughout this app (e.g.
  // "London" and "london" are the same favorite) - centralized here so
  // every place that needs to check "is this city already a favorite"
  // uses the same rule instead of each re-implementing .toLowerCase().
  bool matchesCityName(String other) => cityName.toLowerCase() == other.toLowerCase();

  @override
  List<Object?> get props => [cityName, addedAt];
}
