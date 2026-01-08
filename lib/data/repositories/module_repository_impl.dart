import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/exceptions.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/core/network/network_info.dart';
import 'package:painel_windowns/data/datasources/remote/module_remote_datasource.dart';
import 'package:painel_windowns/domain/entities/module_entity.dart';
import 'package:painel_windowns/domain/repositories/i_module_repository.dart';

/// Implementação do repositório de módulos/ativos
class ModuleRepositoryImpl implements IModuleRepository {
  final ModuleRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ModuleRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<ModuleEntity>>> getModulesByType(
    String token,
    String type,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final modules = await remoteDataSource.getModulesByType(token, type);
      final entities =
          modules
              .map(
                (mod) => ModuleEntity(
                  id: mod['_id']?.toString() ?? mod['id']?.toString() ?? '',
                  assetTag: mod['assetTag']?.toString(),
                  serialNumber: mod['serialNumber']?.toString(),
                  model: mod['model']?.toString(),
                  manufacturer: mod['manufacturer']?.toString(),
                  type: mod['type']?.toString(),
                  status: mod['status']?.toString(),
                  location: mod['location']?.toString(),
                  sector: mod['sector']?.toString(),
                  floor: mod['floor']?.toString(),
                  unit: mod['unit']?.toString(),
                  ipAddress: mod['ipAddress']?.toString(),
                  macAddress: mod['macAddress']?.toString(),
                  isOnline: mod['isOnline'] as bool?,
                ),
              )
              .toList();

      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ModuleEntity>> getModuleById(
    String token,
    String moduleId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final mod = await remoteDataSource.getModuleById(token, moduleId);
      final entity = ModuleEntity(
        id: mod['_id']?.toString() ?? mod['id']?.toString() ?? '',
        assetTag: mod['assetTag']?.toString(),
        serialNumber: mod['serialNumber']?.toString(),
        model: mod['model']?.toString(),
        manufacturer: mod['manufacturer']?.toString(),
        type: mod['type']?.toString(),
        status: mod['status']?.toString(),
        location: mod['location']?.toString(),
        sector: mod['sector']?.toString(),
        floor: mod['floor']?.toString(),
        unit: mod['unit']?.toString(),
        ipAddress: mod['ipAddress']?.toString(),
        macAddress: mod['macAddress']?.toString(),
        isOnline: mod['isOnline'] as bool?,
      );

      return Right(entity);
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

  @override
  Future<Either<Failure, Unit>> sendCommand(
    String token,
    String moduleId,
    String command,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      await remoteDataSource.sendCommand(token, moduleId, command);
      return const Right(unit);
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

  @override
  Future<Either<Failure, Unit>> updateModule(
    String token,
    ModuleEntity module,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final moduleData = {
        'assetTag': module.assetTag,
        'status': module.status,
        'location': module.location,
        'sector': module.sector,
        'floor': module.floor,
        'unit': module.unit,
      };

      await remoteDataSource.updateModule(token, module.id, moduleData);
      return const Right(unit);
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

  @override
  Future<Either<Failure, List<ModuleEntity>>> getModulesByFilter(
    String token, {
    String? status,
    String? location,
    String? unit,
    String? type,
  }) async {
    final moduleType = type ?? 'all';
    final modulesResult = await getModulesByType(token, moduleType);

    return modulesResult.fold((failure) => Left(failure), (modules) {
      var filtered = modules;

      if (status != null) {
        filtered = filtered.where((m) => m.status == status).toList();
      }
      if (location != null) {
        filtered = filtered.where((m) => m.location == location).toList();
      }
      if (unit != null) {
        filtered = filtered.where((m) => m.unit == unit).toList();
      }

      return Right(filtered);
    });
  }
}
