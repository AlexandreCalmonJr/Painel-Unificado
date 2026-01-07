import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/exceptions.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/core/network/network_info.dart';
import 'package:painel_windowns/data/datasources/local/device_local_datasource.dart';
import 'package:painel_windowns/data/datasources/remote/device_remote_datasource.dart';
import 'package:painel_windowns/domain/entities/device_entity.dart';
import 'package:painel_windowns/domain/repositories/i_device_repository.dart';

/// Implementação do repositório de dispositivos
///
/// Orquestra data sources remote e local seguindo Clean Architecture.
/// Usa Either<Failure, Success> para tratamento de erros funcional.
class DeviceRepositoryImpl implements IDeviceRepository {
  final DeviceRemoteDataSource remoteDataSource;
  final DeviceLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  DeviceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<DeviceEntity>>> getDevices(String token) async {
    // Verifica conectividade
    if (await networkInfo.isConnected) {
      try {
        // Busca da API
        final devices = await remoteDataSource.getDevices(token);

        // Salva no cache
        await localDataSource.cacheDevices(devices);

        // Converte para entities
        final entities = devices.map((device) => device.toEntity()).toList();

        return Right(entities);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on UnauthorizedException {
        return Left(UnauthorizedFailure());
      } catch (e) {
        return Left(ServerFailure(message: 'Unexpected error: $e'));
      }
    } else {
      // Sem internet, tenta buscar do cache
      try {
        final cachedDevices = await localDataSource.getCachedDevices();
        final entities =
            cachedDevices.map((device) => device.toEntity()).toList();
        return Right(entities);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } catch (e) {
        return Left(CacheFailure(message: 'Unexpected cache error: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, DeviceEntity>> getDeviceById(
    String token,
    String deviceId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final device = await remoteDataSource.getDeviceById(token, deviceId);
        return Right(device.toEntity());
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(message: e.message));
      } on UnauthorizedException {
        return Left(UnauthorizedFailure());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: 'Unexpected error: $e'));
      }
    } else {
      // Sem internet, tenta buscar do cache
      try {
        final device = await localDataSource.getCachedDeviceById(deviceId);
        if (device != null) {
          return Right(device.toEntity());
        } else {
          return Left(NotFoundFailure(message: 'Device not found in cache'));
        }
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } catch (e) {
        return Left(CacheFailure(message: 'Unexpected cache error: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, Unit>> sendCommand(
    String token,
    String deviceId,
    String command,
  ) async {
    // Comando requer internet
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      await remoteDataSource.sendCommand(token, deviceId, command);
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
  Future<Either<Failure, Unit>> updateDevice(
    String token,
    DeviceEntity device,
  ) async {
    // Update requer internet
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      // Converte entity para model
      final deviceModel = Device.fromEntity(device);

      await remoteDataSource.updateDevice(token, deviceModel);

      // Invalida cache para forçar refresh
      await localDataSource.clearCache();

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
  Future<Either<Failure, List<DeviceEntity>>> getDevicesByFilter(
    String token, {
    String? status,
    String? location,
    String? unit,
  }) async {
    // Busca todos e filtra localmente (pode ser otimizado com endpoint específico)
    final devicesResult = await getDevices(token);

    return devicesResult.fold((failure) => Left(failure), (devices) {
      var filtered = devices;

      if (status != null) {
        filtered = filtered.where((d) => d.status == status).toList();
      }
      if (location != null) {
        filtered = filtered.where((d) => d.location == location).toList();
      }
      if (unit != null) {
        filtered = filtered.where((d) => d.unit == unit).toList();
      }

      return Right(filtered);
    });
  }
}
