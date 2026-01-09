import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/domain/entities/user_entity.dart';
import 'package:painel_windowns/domain/repositories/i_auth_repository.dart';
import 'package:painel_windowns/domain/usecases/usecase.dart';

/// Parameters for the login use case.
class LoginParams extends Equatable {

  const LoginParams({required this.username, required this.password});
  final String username;
  final String password;

  @override
  List<Object?> get props => [username, password];
}

/// Use case for user authentication.
///
/// This use case handles user login by validating credentials
/// and returning a [UserEntity] on success.
@lazySingleton
class LoginUseCase implements UseCase<UserEntity, LoginParams> {

  LoginUseCase(this.repository);
  final IAuthRepository repository;

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) async {
    return repository.login(params.username, params.password);
  }
}
