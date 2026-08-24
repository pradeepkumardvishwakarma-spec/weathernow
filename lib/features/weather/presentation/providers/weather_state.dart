import 'package:equatable/equatable.dart';
import 'package:weathernow/features/weather/domain/entities/weather_entity.dart';
import 'package:weathernow/features/weather/domain/entities/forecast_entity.dart';

enum WeatherStatus { initial, loading, success, error }

class WeatherState extends Equatable {
  final WeatherStatus status;
  final WeatherEntity? weather;
  final ForecastEntity? forecast;
  final String? errorMessage;
  final String? lastQueriedCity;

  const WeatherState({
    this.status = WeatherStatus.initial,
    this.weather,
    this.forecast,
    this.errorMessage,
    this.lastQueriedCity,
  });

  WeatherState copyWith({
    WeatherStatus? status,
    WeatherEntity? weather,
    ForecastEntity? forecast,
    String? errorMessage,
    String? lastQueriedCity,
  }) {
    return WeatherState(
      status: status ?? this.status,
      weather: weather ?? this.weather,
      forecast: forecast ?? this.forecast,
      errorMessage: errorMessage,
      lastQueriedCity: lastQueriedCity ?? this.lastQueriedCity,
    );
  }

  @override
  List<Object?> get props =>
      [status, weather, forecast, errorMessage, lastQueriedCity];
}
