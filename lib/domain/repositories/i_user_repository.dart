import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/domain/entities/user_entity.dart';

/// Interface do repositório de usuários
abstract class IUserRepository {
  Future<Either<Failure, List<UserEntity>>> getUsers(String token);
  Future<Either<Failure, UserEntity>> getUserById(String token, String userId);
  Future<Either<Failure, UserEntity>> createUser(
    String token,
    UserEntity user,
    String password,
  );
  Future<Either<Failure, Unit>> updateUser(String token, UserEntity user);
  Future<Either<Failure, Unit>> deleteUser(String token, String userId);
  Future<Either<Failure, Unit>> changePassword(
    String token,
    String userId,
    String newPassword,
  );
}
