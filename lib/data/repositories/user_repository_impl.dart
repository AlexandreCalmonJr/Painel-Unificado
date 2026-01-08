import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/exceptions.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/core/network/network_info.dart';
import 'package:painel_windowns/data/datasources/remote/user_remote_datasource.dart';
import 'package:painel_windowns/domain/entities/user_entity.dart';
import 'package:painel_windowns/domain/repositories/i_user_repository.dart';

/// Implementação do repositório de usuários
class UserRepositoryImpl implements IUserRepository {
  final UserRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<UserEntity>>> getUsers(String token) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final users = await remoteDataSource.getUsers(token);
      // TODO: Add toEntity() to User model
      final entities =
          users
              .map(
                (user) => UserEntity(
                  id: user.id ?? '',
                  username: user.username ?? '',
                  email: user.email,
                  role: user.role ?? 'user',
                  isActive: user.isActive ?? true,
                ),
              )
              .toList();

      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserById(
    String token,
    String userId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final user = await remoteDataSource.getUserById(token, userId);
      final entity = UserEntity(
        id: user.id ?? '',
        username: user.username ?? '',
        email: user.email,
        role: user.role ?? 'user',
        isActive: user.isActive ?? true,
      );

      return Right(entity);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> createUser(
    String token,
    UserEntity user,
    String password,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      // TODO: Add fromEntity() to User model
      final userModel = User(
        username: user.username,
        email: user.email,
        password: password,
        role: user.role,
        isActive: user.isActive,
      );

      final result = await remoteDataSource.createUser(token, userModel);
      final entity = UserEntity(
        id: result.id ?? '',
        username: result.username ?? '',
        email: result.email,
        role: result.role ?? 'user',
        isActive: result.isActive ?? true,
      );

      return Right(entity);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateUser(
    String token,
    UserEntity user,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final userModel = User(
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role,
        isActive: user.isActive,
      );

      await remoteDataSource.updateUser(token, userModel);
      return const Right(unit);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteUser(String token, String userId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      await remoteDataSource.deleteUser(token, userId);
      return const Right(unit);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> changePassword(
    String token,
    String userId,
    String newPassword,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      await remoteDataSource.changePassword(token, userId, newPassword);
      return const Right(unit);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }
}
