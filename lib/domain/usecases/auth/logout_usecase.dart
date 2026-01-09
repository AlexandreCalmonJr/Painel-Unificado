import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/domain/repositories/i_auth_repository.dart';
import 'package:painel_windowns/domain/usecases/usecase.dart';

/// Use case for logging out the current user.
///
/// This use case handles user logout by clearing
/// authentication tokens and session data.
@lazySingleton
class LogoutUseCase implements UseCase<Unit, NoParams> {

  LogoutUseCase(this.repository);
  final IAuthRepository repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    return repository.logout();
  }
}
