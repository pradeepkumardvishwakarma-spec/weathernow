import 'package:equatable/equatable.dart';

enum TemperatureUnit { celsius, fahrenheit }

class SettingsEntity extends Equatable {
  final TemperatureUnit unit;
  const SettingsEntity({this.unit = TemperatureUnit.celsius});

  @override
  List<Object?> get props => [unit];
}
