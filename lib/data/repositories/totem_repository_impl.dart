import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/exceptions.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/core/network/network_info.dart';
import 'package:painel_windowns/data/datasources/local/totem_local_datasource.dart';
import 'package:painel_windowns/data/datasources/remote/totem_remote_datasource.dart';
import 'package:painel_windowns/domain/entities/totem_entity.dart';
import 'package:painel_windowns/domain/repositories/i_totem_repository.dart';

/// Implementação do repositório de totems
class TotemRepositoryImpl implements ITotemRepository {
  final TotemRemoteDataSource remoteDataSource;
  final TotemLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  TotemRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<TotemEntity>>> getTotems(String token) async {
    if (await networkInfo.isConnected) {
      try {
        final totems = await remoteDataSource.getTotems(token);
        await localDataSource.cacheTotems(totems);

        // TODO: Add toEntity() to Totem model
        final entities =
            totems
                .map(
                  (totem) => TotemEntity(
                    id: totem.id ?? '',
                    name: totem.name,
                    status: totem.status,
                    location: totem.location,
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
    } else {
      try {
        final cachedTotems = await localDataSource.getCachedTotems();
        final entities =
            cachedTotems
                .map(
                  (totem) => TotemEntity(
                    id: totem.id ?? '',
                    name: totem.name,
                    status: totem.status,
                    location: totem.location,
                  ),
                )
                .toList();
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
        return Right(
          TotemEntity(
            id: totem.id ?? '',
            name: totem.name,
            status: totem.status,
            location: totem.location,
          ),
        );
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
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendCommand(
    String token,
    String totemId,
    String command,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      await remoteDataSource.sendCommand(token, totemId, command);
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
  Future<Either<Failure, Unit>> updateTotem(
    String token,
    TotemEntity totem,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      // TODO: Add fromEntity() to Totem model
      final totemModel = Totem(
        id: totem.id,
        name: totem.name,
        status: totem.status ?? '',
        location: totem.location,
      );

      await remoteDataSource.updateTotem(token, totemModel);
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
