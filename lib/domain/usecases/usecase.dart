import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/failures.dart';

/// Base class for all use cases in the application.
///
/// A use case represents a single business logic operation.
/// It takes parameters of type [Params] and returns an [Either]
/// containing either a [Failure] or a result of type [Type].
///
/// Example:
/// ```dart
/// class GetDevicesUseCase implements UseCase<List<DeviceEntity>, NoParams> {
///   final IDeviceRepository repository;
///
///   GetDevicesUseCase(this.repository);
///
///   @override
///   Future<Either<Failure, List<DeviceEntity>>> call(NoParams params) {
///     return repository.getDevices();
///   ///}
/// }
/// ```
abstract class UseCase<Type, Params> {
  /// Executes the use case with the given [params].
  Future<Either<Failure, Type>> call(Params params);
}

/// Represents the absence of parameters for a use case.
///
/// Use this class when a use case doesn't require any parameters.
///
/// Example:
/// ```dart
/// final result = await getDevicesUseCase(NoParams());
/// ```
class NoParams {
  const NoParams();
}
