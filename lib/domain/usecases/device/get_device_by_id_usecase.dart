import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/domain/entities/device_entity.dart';
import 'package:painel_windowns/domain/repositories/i_device_repository.dart';
import 'package:painel_windowns/domain/usecases/usecase.dart';

/// Parameters for getting a device by ID.
class GetDeviceByIdParams extends Equatable {
  final String deviceId;

  const GetDeviceByIdParams({required this.deviceId});

  @override
  List<Object?> get props => [deviceId];
}

/// Use case for retrieving a specific device by ID.
@lazySingleton
class GetDeviceByIdUseCase
    implements UseCase<DeviceEntity, GetDeviceByIdParams> {
  final IDeviceRepository repository;

  GetDeviceByIdUseCase(this.repository);

  @override
  Future<Either<Failure, DeviceEntity>> call(GetDeviceByIdParams params) async {
    // TODO: Get token from auth service
    return await repository.getDeviceById('', params.deviceId);
  }
}
