import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/failures.dart';

/// Interface do repositório de logs
abstract class ILoggerRepository {
  Future<Either<Failure, Unit>> sendLog(
    String token,
    Map<String, dynamic> logData,
  );
  Future<Either<Failure, List<Map<String, dynamic>>>> getLogs(
    String token, {
    String? level,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Either<Failure, Unit>> clearLogs(String token);
}
