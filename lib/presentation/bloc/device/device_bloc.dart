import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:painel_windowns/domain/usecases/device/get_devices_usecase.dart';
import 'package:painel_windowns/domain/usecases/usecase.dart';
import 'package:painel_windowns/presentation/bloc/device/device_event.dart';
import 'package:painel_windowns/presentation/bloc/device/device_state.dart';

/// BLoC for managing device-related state and business logic.
///
/// This BLoC handles device operations such as loading devices,
/// refreshing the device list, and loading individual devices.
@injectable
class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final GetDevicesUseCase getDevicesUseCase;

  DeviceBloc({required this.getDevicesUseCase}) : super(const DeviceInitial()) {
    on<LoadDevices>(_onLoadDevices);
    on<RefreshDevices>(_onRefreshDevices);
  }

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
}
