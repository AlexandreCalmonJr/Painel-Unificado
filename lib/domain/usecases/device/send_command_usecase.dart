import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/domain/repositories/i_device_repository.dart';
import 'package:painel_windowns/domain/usecases/usecase.dart';

/// Parameters for sending a command to a device.
class SendCommandParams extends Equatable {

  const SendCommandParams({required this.deviceId, required this.command});
  final String deviceId;
  final String command;

  @override
  List<Object?> get props => [deviceId, command];
}

/// Use case for sending a command to a device.
@lazySingleton
class SendCommandUseCase implements UseCase<Unit, SendCommandParams> {

  SendCommandUseCase(this.repository);
  final IDeviceRepository repository;

  @override
  Future<Either<Failure, Unit>> call(SendCommandParams params) async {
    // TODO: Get token from auth service
    return repository.sendCommand('', params.deviceId, params.command);
  }
}
