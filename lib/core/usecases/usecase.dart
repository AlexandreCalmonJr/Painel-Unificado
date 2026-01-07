import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/failures.dart';

/// Base class for all use cases in the application
///
/// [Type] is the return type of the use case
/// [Params] is the parameter type for the use case
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case that doesn't require any parameters
class NoParams {
  const NoParams();
}
