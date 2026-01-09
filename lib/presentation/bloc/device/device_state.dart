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

  const DeviceLoaded(this.devices);
  final List<DeviceEntity> devices;

  @override
  List<Object?> get props => [devices];
}

/// State when an error occurs while loading devices.
class DeviceError extends DeviceState {

  const DeviceError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
