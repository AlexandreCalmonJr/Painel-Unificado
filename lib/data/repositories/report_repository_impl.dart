import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/exceptions.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/core/network/network_info.dart';
import 'package:painel_windowns/data/datasources/remote/report_remote_datasource.dart';
import 'package:painel_windowns/domain/repositories/i_report_repository.dart';

/// Implementação do repositório de relatórios
class ReportRepositoryImpl implements IReportRepository {
  final ReportRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ReportRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> generateDeviceReport(
    String token, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final report = await remoteDataSource.generateDeviceReport(
        token,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(report);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> generateMaintenanceReport(
    String token, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final report = await remoteDataSource.generateMaintenanceReport(
        token,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(report);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> generateUsageReport(
    String token, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final report = await remoteDataSource.generateUsageReport(
        token,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(report);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAvailableReports(
    String token,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final reports = await remoteDataSource.getAvailableReports(token);
      return Right(reports);
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> downloadReport(
    String token,
    String reportId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final reportData = await remoteDataSource.downloadReport(token, reportId);
      return Right(reportData);
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
