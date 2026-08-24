import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Every use case takes a single [Params] object and returns
/// Either a [Failure] or a [Type] on success. Keeps domain layer
/// framework-agnostic (no Dio/Hive/Riverpod imports here).
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// For use cases that need no parameters.
class NoParams {
  const NoParams();
}
