import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/failures.dart';

/// Interface do repositório de manutenção
abstract class IMaintenanceRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getMaintenanceRecords(
    String token,
    String assetId,
  );

  Future<Either<Failure, Map<String, dynamic>>> createMaintenanceRecord(
    String token,
    Map<String, dynamic> record,
  );

  Future<Either<Failure, Unit>> updateMaintenanceRecord(
    String token,
    String recordId,
    Map<String, dynamic> record,
  );

  Future<Either<Failure, List<Map<String, dynamic>>>> getScheduledMaintenance(
    String token,
  );
}
