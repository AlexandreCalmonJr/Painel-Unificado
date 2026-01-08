import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/failures.dart';

/// Interface do repositório de analytics
abstract class IAnalyticsRepository {
  Future<Either<Failure, Map<String, dynamic>>> getDashboardMetrics(
    String token,
  );
  Future<Either<Failure, Map<String, dynamic>>> getDeviceMetrics(
    String token,
    String deviceId,
  );
  Future<Either<Failure, List<Map<String, dynamic>>>> getUsageStatistics(
    String token, {
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Either<Failure, Map<String, dynamic>>> getSystemHealth(String token);
}
