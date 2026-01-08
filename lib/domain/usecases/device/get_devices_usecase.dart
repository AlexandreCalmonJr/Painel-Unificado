import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/domain/entities/device_entity.dart';
import 'package:painel_windowns/domain/repositories/i_device_repository.dart';
import 'package:painel_windowns/domain/usecases/usecase.dart';

/// Use case for retrieving all devices.
///
/// This use case fetches all devices from the repository
/// and returns them as a list of [DeviceEntity].
@lazySingleton
class GetDevicesUseCase implements UseCase<List<DeviceEntity>, NoParams> {
  final IDeviceRepository repository;

  GetDevicesUseCase(this.repository);

  @override
  Future<Either<Failure, List<DeviceEntity>>> call(NoParams params) async {
    return await repository.getDevices();
  }
}
