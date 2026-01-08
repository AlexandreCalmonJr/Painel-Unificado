import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/failures.dart';

/// Interface do repositório de comandos
abstract class ICommandRepository {
  Future<Either<Failure, Unit>> sendCommand(
    String token,
    String deviceId,
    String command, {
    Map<String, dynamic>? params,
  });

  Future<Either<Failure, List<Map<String, dynamic>>>> getCommandHistory(
    String token,
    String deviceId,
  );

  Future<Either<Failure, Map<String, dynamic>>> getCommandStatus(
    String token,
    String commandId,
  );
}
