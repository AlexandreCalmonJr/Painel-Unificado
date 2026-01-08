import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/failures.dart';

/// Interface do repositório de backup
abstract class IBackupRepository {
  Future<Either<Failure, Map<String, dynamic>>> createBackup(
    String token, {
    String? description,
  });
  Future<Either<Failure, List<Map<String, dynamic>>>> getBackupList(
    String token,
  );
  Future<Either<Failure, Unit>> restoreBackup(String token, String backupId);
  Future<Either<Failure, Unit>> deleteBackup(String token, String backupId);
  Future<Either<Failure, String>> downloadBackup(String token, String backupId);
}
