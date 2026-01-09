import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/exceptions.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/core/network/network_info.dart';
import 'package:painel_windowns/data/datasources/local/totem_local_datasource.dart';
import 'package:painel_windowns/data/datasources/remote/totem_remote_datasource.dart';
import 'package:painel_windowns/data/models/totem_model.dart';
import 'package:painel_windowns/domain/entities/totem_entity.dart';
import 'package:painel_windowns/domain/repositories/i_totem_repository.dart';
import 'package:painel_windowns/services/status_service.dart';

/// Implementação do repositório de totems
class TotemRepositoryImpl implements ITotemRepository {

  TotemRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.statusService,
  });
  final TotemRemoteDataSource remoteDataSource;
  final TotemLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final StatusService statusService;

  @override
  Future<Either<Failure, List<TotemEntity>>> getTotems(String token) async {
    if (await networkInfo.isConnected) {
      try {
        final totems = await remoteDataSource.getTotems(token);

        // Valida status usando StatusService
        final validatedTotems =
            totems.map((totem) {
              final totemId = totem.id ?? '';
              final validatedStatus = statusService.calculateStatus(
                totemId,
                totem.lastSeen.toIso8601String(),
                totem.status,
              );
              return totem.copyWith(status: validatedStatus);
            }).toList();

        await localDataSource.cacheTotems(validatedTotems);

        // Usar toEntity() do Totem model
        final entities =
            validatedTotems.map((totem) => totem.toEntity()).toList();

        return Right(entities);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on UnauthorizedException {
        return const Left(UnauthorizedFailure());
      } catch (e) {
        return Left(ServerFailure(message: 'Unexpected error: $e'));
      }
    } else {
      try {
        final cachedTotems = await localDataSource.getCachedTotems();
        // Usar toEntity() do Totem model
        final entities = cachedTotems.map((totem) => totem.toEntity()).toList();
        return Right(entities);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } catch (e) {
        return Left(CacheFailure(message: 'Unexpected cache error: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, TotemEntity>> getTotemById(
    String token,
    String totemId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final totem = await remoteDataSource.getTotemById(token, totemId);
        return Right(totem.toEntity());
      } on NotFoundException catch (e) {
        return Left(NotFoundFailure(message: e.message));
      } on UnauthorizedException {
        return const Left(UnauthorizedFailure());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: 'Unexpected error: $e'));
      }
    } else {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendCommand(
    String token,
    String totemId,
    String command,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      await remoteDataSource.sendCommand(token, totemId, command);
      return const Right(unit);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTotem(
    String token,
    TotemEntity totem,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      // Usar fromEntity() do Totem model
      final totemModel = Totem.fromEntity(totem);

      await remoteDataSource.updateTotem(token, totemModel);
      await localDataSource.clearCache();

      return const Right(unit);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TotemEntity>>> getTotemsByFilter(
    String token, {
    String? status,
    String? location,
    String? unit,
  }) async {
    final totemsResult = await getTotems(token);

    return totemsResult.fold((failure) => Left(failure), (totems) {
      var filtered = totems;

      if (status != null) {
        filtered = filtered.where((t) => t.status == status).toList();
      }
      if (location != null) {
        filtered = filtered.where((t) => t.location == location).toList();
      }
      if (unit != null) {
        filtered = filtered.where((t) => t.unit == unit).toList();
      }

      return Right(filtered);
    });
  }
}
