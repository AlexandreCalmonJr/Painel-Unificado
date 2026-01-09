import 'package:equatable/equatable.dart';

/// Base class for all device-related events.
abstract class DeviceEvent extends Equatable {
  const DeviceEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all devices.
class LoadDevices extends DeviceEvent {
  const LoadDevices();
}

/// Event to refresh devices list.
class RefreshDevices extends DeviceEvent {
  const RefreshDevices();
}

/// Event to load a specific device by ID.
class LoadDeviceById extends DeviceEvent {

  const LoadDeviceById(this.deviceId);
  final String deviceId;

  @override
  List<Object?> get props => [deviceId];
}
