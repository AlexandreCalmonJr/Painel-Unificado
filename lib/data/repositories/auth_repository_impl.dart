import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/exceptions.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/data/datasources/local/auth_local_datasource.dart';
import 'package:painel_windowns/data/datasources/remote/auth_remote_datasource.dart';
import 'package:painel_windowns/domain/entities/user_entity.dart';
import 'package:painel_windowns/domain/repositories/i_auth_repository.dart';

/// Implementação do repositório de autenticação
class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await remoteDataSource.login(username, password);

      // Salva token
      final token = response['token'] as String?;
      if (token != null) {
        await localDataSource.saveAuthToken(token);
      }

      // Converte para UserEntity
      final user = response['user'] as Map<String, dynamic>? ?? response;
      final userEntity = UserEntity(
        id: user['id']?.toString() ?? '',
        username: user['username']?.toString() ?? username,
        email: user['email']?.toString() ?? '',
        fullName: user['fullName']?.toString(),
        role: user['role']?.toString() ?? 'user',
        isActive: user['isActive'] as bool? ?? true,
      );

      await localDataSource.saveUserData(user);

      return Right(userEntity);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await localDataSource.clearAuthData();
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final token = await localDataSource.getAuthToken();
      if (token == null) {
        return const Right(false);
      }

      // Valida token com servidor
      final isValid = await remoteDataSource.validateToken(token);
      return Right(isValid);
    } catch (e) {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final token = await localDataSource.getAuthToken();
      if (token == null) {
        return Left(UnauthorizedFailure(message: 'No token found'));
      }

      final userData = await remoteDataSource.getCurrentUser(token);

      final userEntity = UserEntity(
        id: userData['id']?.toString() ?? '',
        username: userData['username']?.toString() ?? '',
        email: userData['email']?.toString() ?? '',
        fullName: userData['fullName']?.toString(),
        role: userData['role']?.toString() ?? 'user',
        isActive: userData['isActive'] as bool? ?? true,
      );

      return Right(userEntity);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    // TODO: Implementar quando houver endpoint
    return Left(ServerFailure(message: 'Not implemented'));
  }

  @override
  Future<Either<Failure, String>> getAuthToken() async {
    try {
      final token = await localDataSource.getAuthToken();
      if (token != null) {
        return Right(token);
      } else {
        return Left(CacheFailure(message: 'No token found'));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveAuthToken(String token) async {
    try {
      await localDataSource.saveAuthToken(token);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeAuthToken() async {
    try {
      await localDataSource.removeAuthToken();
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }
}
