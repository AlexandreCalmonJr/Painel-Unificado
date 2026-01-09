import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/domain/entities/device_entity.dart';
import 'package:painel_windowns/domain/repositories/i_device_repository.dart';
import 'package:painel_windowns/domain/usecases/usecase.dart';
import 'package:painel_windowns/services/token_service.dart';

/// Use case for retrieving all devices.
///
/// This use case fetches all devices from the repository
/// and returns them as a list of [DeviceEntity].
@lazySingleton
class GetDevicesUseCase implements UseCase<List<DeviceEntity>, NoParams> {

  GetDevicesUseCase(this.repository, this.tokenService);
  final IDeviceRepository repository;
  final TokenService tokenService;

  @override
  Future<Either<Failure, List<DeviceEntity>>> call(NoParams params) async {
    final token = tokenService.getToken();

    if (token == null) {
      return const Left(UnauthorizedFailure());
    }

    return repository.getDevices(token);
  }
}
