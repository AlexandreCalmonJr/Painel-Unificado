import 'package:equatable/equatable.dart';
import 'package:painel_windowns/domain/entities/device_entity.dart';

/// Base class for all device-related states.
abstract class DeviceState extends Equatable {
  const DeviceState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the device bloc is first created.
class DeviceInitial extends DeviceState {
  const DeviceInitial();
}

/// State when devices are being loaded.
class DeviceLoading extends DeviceState {
  const DeviceLoading();
}

/// State when devices have been successfully loaded.
class DeviceLoaded extends DeviceState {
  final List<DeviceEntity> devices;

  const DeviceLoaded(this.devices);

  @override
  List<Object?> get props => [devices];
}

/// State when an error occurs while loading devices.
class DeviceError extends DeviceState {
  final String message;

  const DeviceError(this.message);

  @override
  List<Object?> get props => [message];
}
