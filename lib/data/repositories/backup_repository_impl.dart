import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/exceptions.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/core/network/network_info.dart';
import 'package:painel_windowns/data/datasources/remote/backup_remote_datasource.dart';
import 'package:painel_windowns/domain/repositories/i_backup_repository.dart';

/// Implementação do repositório de backup
class BackupRepositoryImpl implements IBackupRepository {
  final BackupRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  BackupRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> createBackup(
    String token, {
    String? description,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final backup = await remoteDataSource.createBackup(
        token,
        description: description,
      );
      return Right(backup);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getBackupList(
    String token,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final backups = await remoteDataSource.getBackupList(token);
      return Right(backups);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> restoreBackup(
    String token,
    String backupId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      await remoteDataSource.restoreBackup(token, backupId);
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
  Future<Either<Failure, Unit>> deleteBackup(
    String token,
    String backupId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      await remoteDataSource.deleteBackup(token, backupId);
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
  Future<Either<Failure, String>> downloadBackup(
    String token,
    String backupId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final backupData = await remoteDataSource.downloadBackup(token, backupId);
      return Right(backupData);
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
