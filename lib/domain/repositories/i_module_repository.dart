import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/domain/entities/module_entity.dart';

/// Interface do repositório de módulos/ativos
abstract class IModuleRepository {
  /// Busca todos os módulos de um tipo específico
  Future<Either<Failure, List<ModuleEntity>>> getModulesByType(
    String token,
    String type,
  );

  /// Busca um módulo por ID
  Future<Either<Failure, ModuleEntity>> getModuleById(
    String token,
    String moduleId,
  );

  /// Envia comando para um módulo
  Future<Either<Failure, Unit>> sendCommand(
    String token,
    String moduleId,
    String command,
  );

  /// Atualiza informações de um módulo
  Future<Either<Failure, Unit>> updateModule(String token, ModuleEntity module);

  /// Busca módulos por filtro
  Future<Either<Failure, List<ModuleEntity>>> getModulesByFilter(
    String token, {
    String? status,
    String? location,
    String? unit,
    String? type,
  });
}
