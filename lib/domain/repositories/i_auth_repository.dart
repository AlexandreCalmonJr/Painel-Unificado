import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/domain/entities/user_entity.dart';

/// Interface do repositório de autenticação
abstract class IAuthRepository {
  /// Realiza login do usuário
  Future<Either<Failure, UserEntity>> login(String username, String password);

  /// Realiza logout do usuário
  Future<Either<Failure, Unit>> logout();

  /// Verifica se usuário está autenticado
  Future<Either<Failure, bool>> isAuthenticated();

  /// Busca usuário atual
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// Atualiza senha do usuário
  Future<Either<Failure, Unit>> changePassword(
    String currentPassword,
    String newPassword,
  );

  /// Busca token de autenticação
  Future<Either<Failure, String>> getAuthToken();

  /// Salva token de autenticação
  Future<Either<Failure, Unit>> saveAuthToken(String token);

  /// Remove token de autenticação
  Future<Either<Failure, Unit>> removeAuthToken();
}
