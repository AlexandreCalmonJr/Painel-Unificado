import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/failures.dart';

/// Interface do repositório de relatórios
abstract class IReportRepository {
  Future<Either<Failure, Map<String, dynamic>>> generateDeviceReport(
    String token, {
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, Map<String, dynamic>>> generateMaintenanceReport(
    String token, {
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, Map<String, dynamic>>> generateUsageReport(
    String token, {
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, List<Map<String, dynamic>>>> getAvailableReports(
    String token,
  );
  Future<Either<Failure, String>> downloadReport(String token, String reportId);
}
