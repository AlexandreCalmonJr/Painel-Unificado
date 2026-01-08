import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/domain/entities/device_entity.dart';
import 'package:painel_windowns/domain/repositories/i_device_repository.dart';
import 'package:painel_windowns/domain/usecases/usecase.dart';

/// Parameters for updating a device.
class UpdateDeviceParams extends Equatable {
  final DeviceEntity device;

  const UpdateDeviceParams({required this.device});

  @override
  List<Object?> get props => [device];
}

/// Use case for updating a device.
@lazySingleton
class UpdateDeviceUseCase implements UseCase<Unit, UpdateDeviceParams> {
  final IDeviceRepository repository;

  UpdateDeviceUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(UpdateDeviceParams params) async {
    // TODO: Get token from auth service
    return await repository.updateDevice('', params.device);
  }
}
