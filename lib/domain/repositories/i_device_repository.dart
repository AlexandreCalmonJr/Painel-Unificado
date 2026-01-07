import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/domain/entities/device_entity.dart';

/// Interface do repositório de dispositivos
///
/// Define o contrato para acesso aos dados de dispositivos.
/// Implementações devem estar na camada de data.
abstract class IDeviceRepository {
  /// Busca todos os dispositivos
  Future<Either<Failure, List<DeviceEntity>>> getDevices(String token);

  /// Busca um dispositivo por ID
  Future<Either<Failure, DeviceEntity>> getDeviceById(
    String token,
    String deviceId,
  );

  /// Envia um comando para um dispositivo
  Future<Either<Failure, Unit>> sendCommand(
    String token,
    String deviceId,
    String command,
  );

  /// Atualiza informações de um dispositivo
  Future<Either<Failure, Unit>> updateDevice(String token, DeviceEntity device);

  /// Busca dispositivos por filtro
  Future<Either<Failure, List<DeviceEntity>>> getDevicesByFilter(
    String token, {
    String? status,
    String? location,
    String? unit,
  });
}
