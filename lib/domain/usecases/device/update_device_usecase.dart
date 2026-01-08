import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/domain/entities/device_entity.dart';
import 'package:painel_windowns/domain/repositories/i_device_repository.dart';
import 'package:painel_windowns/domain/usecases/usecase.dart';

/// Parameters for updating a device.
class UpdateDeviceParams extends Equatable {
  final String deviceId;
  final Map<String, dynamic> updates;

  const UpdateDeviceParams({required this.deviceId, required this.updates});

  @override
  List<Object?> get props => [deviceId, updates];
}

/// Use case for updating a device.
@lazySingleton
class UpdateDeviceUseCase implements UseCase<DeviceEntity, UpdateDeviceParams> {
  final IDeviceRepository repository;

  UpdateDeviceUseCase(this.repository);

  @override
  Future<Either<Failure, DeviceEntity>> call(UpdateDeviceParams params) async {
    return await repository.updateDevice(params.deviceId, params.updates);
  }
}
