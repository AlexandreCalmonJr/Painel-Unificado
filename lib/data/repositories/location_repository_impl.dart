import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/exceptions.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/core/network/network_info.dart';
import 'package:painel_windowns/data/datasources/remote/location_remote_datasource.dart';
import 'package:painel_windowns/domain/entities/location_entity.dart';
import 'package:painel_windowns/domain/repositories/i_location_repository.dart';

/// Implementação do repositório de localizações
class LocationRepositoryImpl implements ILocationRepository {

  LocationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  final LocationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<LocationEntity>>> getLocations(
    String token,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final locations = await remoteDataSource.getLocations(token);
      final entities =
          locations
              .map(
                (loc) => LocationEntity(
                  id: loc['_id']?.toString() ?? loc['id']?.toString() ?? '',
                  name: loc['name']?.toString() ?? '',
                  description: loc['description']?.toString(),
                  address: loc['address']?.toString(),
                  city: loc['city']?.toString(),
                  state: loc['state']?.toString(),
                  country: loc['country']?.toString(),
                  isActive: loc['isActive'] as bool? ?? true,
                ),
              )
              .toList();

      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, LocationEntity>> getLocationById(
    String token,
    String locationId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final loc = await remoteDataSource.getLocationById(token, locationId);
      final entity = LocationEntity(
        id: loc['_id']?.toString() ?? loc['id']?.toString() ?? '',
        name: loc['name']?.toString() ?? '',
        description: loc['description']?.toString(),
        address: loc['address']?.toString(),
        city: loc['city']?.toString(),
        state: loc['state']?.toString(),
        country: loc['country']?.toString(),
        isActive: loc['isActive'] as bool? ?? true,
      );

      return Right(entity);
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
  Future<Either<Failure, LocationEntity>> createLocation(
    String token,
    LocationEntity location,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final locationData = {
        'name': location.name,
        'description': location.description,
        'address': location.address,
        'city': location.city,
        'state': location.state,
        'country': location.country,
        'isActive': location.isActive,
      };

      final result = await remoteDataSource.createLocation(token, locationData);
      final entity = LocationEntity(
        id: result['_id']?.toString() ?? result['id']?.toString() ?? '',
        name: result['name']?.toString() ?? location.name,
        description: result['description']?.toString(),
        address: result['address']?.toString(),
        city: result['city']?.toString(),
        state: result['state']?.toString(),
        country: result['country']?.toString(),
        isActive: result['isActive'] as bool? ?? true,
      );

      return Right(entity);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateLocation(
    String token,
    LocationEntity location,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      final locationData = {
        'name': location.name,
        'description': location.description,
        'address': location.address,
        'city': location.city,
        'state': location.state,
        'country': location.country,
        'isActive': location.isActive,
      };

      await remoteDataSource.updateLocation(token, location.id, locationData);
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
  Future<Either<Failure, Unit>> deleteLocation(
    String token,
    String locationId,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'No internet connection'));
    }

    try {
      await remoteDataSource.deleteLocation(token, locationId);
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
}
