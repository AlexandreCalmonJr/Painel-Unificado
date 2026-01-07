import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/domain/entities/location_entity.dart';

/// Interface do repositório de localizações
abstract class ILocationRepository {
  /// Busca todas as localizações
  Future<Either<Failure, List<LocationEntity>>> getLocations(String token);

  /// Busca uma localização por ID
  Future<Either<Failure, LocationEntity>> getLocationById(
    String token,
    String locationId,
  );

  /// Cria uma nova localização
  Future<Either<Failure, LocationEntity>> createLocation(
    String token,
    LocationEntity location,
  );

  /// Atualiza uma localização
  Future<Either<Failure, Unit>> updateLocation(
    String token,
    LocationEntity location,
  );

  /// Remove uma localização
  Future<Either<Failure, Unit>> deleteLocation(String token, String locationId);
}
