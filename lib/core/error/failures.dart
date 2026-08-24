import 'package:equatable/equatable.dart';

/// Failures are what the domain/presentation layers deal with.
/// Data layer throws [Exception]s; repositories catch them and
/// convert to a [Failure] so UI never touches raw exceptions/strings.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong on the server. Please try again.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class CityNotFoundFailure extends Failure {
  const CityNotFoundFailure([super.message = "We couldn't find that city. Check the spelling and try again."]);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'The request timed out. Please try again.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'No cached data available for this city yet.']);
}

class RequestCancelledFailure extends Failure {
  const RequestCancelledFailure([super.message = 'Request was cancelled.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something unexpected happened.']);
}
