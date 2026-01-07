import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/domain/entities/totem_entity.dart';

/// Interface do repositório de totems
abstract class ITotemRepository {
  /// Busca todos os totems
  Future<Either<Failure, List<TotemEntity>>> getTotems(String token);

  /// Busca um totem por ID
  Future<Either<Failure, TotemEntity>> getTotemById(
    String token,
    String totemId,
  );

  /// Envia comando para um totem
  Future<Either<Failure, Unit>> sendCommand(
    String token,
    String totemId,
    String command,
  );

  /// Atualiza informações de um totem
  Future<Either<Failure, Unit>> updateTotem(String token, TotemEntity totem);

  /// Busca totems por filtro
  Future<Either<Failure, List<TotemEntity>>> getTotemsByFilter(
    String token, {
    String? status,
    String? location,
    String? unit,
  });
}
