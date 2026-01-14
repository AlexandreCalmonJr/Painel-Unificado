import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:painel_windowns/domain/usecases/device/get_devices_usecase.dart';
import 'package:painel_windowns/domain/usecases/usecase.dart';
import 'package:painel_windowns/presentation/bloc/device/device_event.dart';
import 'package:painel_windowns/presentation/bloc/device/device_state.dart';
import 'package:painel_windowns/services/websocket_service.dart';

/// BLoC for managing device-related state and business logic.
///
/// This BLoC handles device operations such as loading devices,
/// refreshing the device list, and loading individual devices.
@injectable
class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {

  DeviceBloc({
    required this.getDevicesUseCase,
    required WebSocketService websocketService,
  }) : _websocketService = websocketService,
       super(const DeviceInitial()) {
    on<LoadDevices>(_onLoadDevices);
    on<RefreshDevices>(_onRefreshDevices);
    on<DeviceUpdatedFromWebSocket>(_onDeviceUpdatedFromWebSocket);
    
    // Subscribe to WebSocket device updates
    _websocketSubscription = _websocketService.deviceUpdates.listen(
      (updateData) {
        add(DeviceUpdatedFromWebSocket(updateData));
      },
    );
  }
  
  final GetDevicesUseCase getDevicesUseCase;
  final WebSocketService _websocketService;
  StreamSubscription<Map<String, dynamic>>? _websocketSubscription;

  /// Handles the LoadDevices event.
  Future<void> _onLoadDevices(
    LoadDevices event,
    Emitter<DeviceState> emit,
  ) async {
    emit(const DeviceLoading());

    final result = await getDevicesUseCase(const NoParams());

    result.fold(
      (failure) => emit(DeviceError(failure.message)),
      (devices) => emit(DeviceLoaded(devices)),
    );
  }

  /// Handles the RefreshDevices event.
  Future<void> _onRefreshDevices(
    RefreshDevices event,
    Emitter<DeviceState> emit,
  ) async {
    // Keep current state while refreshing
    final currentState = state;

    final result = await getDevicesUseCase(const NoParams());

    result.fold((failure) {
      // If refresh fails, keep the current state
      if (currentState is DeviceLoaded) {
        emit(currentState);
      } else {
        emit(DeviceError(failure.message));
      }
    }, (devices) => emit(DeviceLoaded(devices)));
  }

  /// Handles WebSocket device updates
  Future<void> _onDeviceUpdatedFromWebSocket(
    DeviceUpdatedFromWebSocket event,
    Emitter<DeviceState> emit,
  ) async {
    final currentState = state;
    
    // Only update if we have devices loaded
    if (currentState is! DeviceLoaded) return;

    final updateData = event.updateData;
    final type = updateData['type'] as String?;
    final deviceId = updateData['deviceId'] as String?;

    if (deviceId == null) return;

    final devices = List.of(currentState.devices);
    final deviceIndex = devices.indexWhere((d) => d.id == deviceId);

    if (deviceIndex == -1) {
      // Device not in list, refresh to get it
      add(const RefreshDevices());
      return;
    }

    // Update device status based on WebSocket message
    final device = devices[deviceIndex];
    final updatedDevice = device.copyWith(
      status: type == 'device_online' ? 'online' : 'offline',
      lastSeen: updateData['timestamp'] as String?,
    );

    devices[deviceIndex] = updatedDevice;
    emit(DeviceLoaded(devices));
  }

  @override
  Future<void> close() {
    _websocketSubscription?.cancel();
    return super.close();
  }
}
