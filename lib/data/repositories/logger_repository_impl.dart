import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/exceptions.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/core/network/network_info.dart';
import 'package:painel_windowns/data/datasources/remote/logger_remote_datasource.dart';
import 'package:painel_windowns/domain/repositories/i_logger_repository.dart';

/// Implementação do repositório de logs
class LoggerRepositoryImpl implements ILoggerRepository {
  final LoggerRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  LoggerRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Unit>> sendLog(
    String token,
    Map<String, dynamic> logData,
  ) async {
    // Logs podem ser enviados mesmo sem conexão (serão perdidos, mas não devem bloquear)
    if (!await networkInfo.isConnected) {
      print('Warning: No internet connection, log not sent');
      return const Right(unit);
    }

    try {
      await remoteDataSource.sendLog(token, logData);
      return const Right(unit);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      // Don't fail on log errors
      print('Warning: Failed to send log: $e');
      return const Right(unit);
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getLogs(
    String token, {
    String? level,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final logs = await remoteDataSource.getLogs(
        token,
        level: level,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(logs);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearLogs(String token) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      await remoteDataSource.clearLogs(token);
      return const Right(unit);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }
}
