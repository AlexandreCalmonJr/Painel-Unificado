import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/domain/repositories/i_device_repository.dart';
import 'package:painel_windowns/domain/usecases/usecase.dart';

/// Parameters for sending a command to a device.
class SendCommandParams extends Equatable {
  final String deviceId;
  final String command;
  final Map<String, dynamic>? parameters;

  const SendCommandParams({
    required this.deviceId,
    required this.command,
    this.parameters,
  });

  @override
  List<Object?> get props => [deviceId, command, parameters];
}

/// Use case for sending a command to a device.
@lazySingleton
class SendCommandUseCase implements UseCase<bool, SendCommandParams> {
  final IDeviceRepository repository;

  SendCommandUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(SendCommandParams params) async {
    return await repository.sendCommand(
      params.deviceId,
      params.command,
      params.parameters,
    );
  }
}
