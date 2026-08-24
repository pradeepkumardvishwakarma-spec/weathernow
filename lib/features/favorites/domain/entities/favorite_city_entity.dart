import 'package:equatable/equatable.dart';

class FavoriteCityEntity extends Equatable {
  final String cityName;
  final DateTime addedAt;
  const FavoriteCityEntity({required this.cityName, required this.addedAt});

  @override
  List<Object?> get props => [cityName, addedAt];
}
