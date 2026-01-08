import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:painel_windowns/domain/usecases/totem/get_totems_usecase.dart';
import 'package:painel_windowns/domain/usecases/usecase.dart';
import 'package:painel_windowns/presentation/bloc/totem/totem_event.dart';
import 'package:painel_windowns/presentation/bloc/totem/totem_state.dart';

/// BLoC for managing totem-related state and business logic.
///
/// This BLoC handles totem operations such as loading totems,
/// refreshing the totem list, and loading individual totems.
@injectable
class TotemBloc extends Bloc<TotemEvent, TotemState> {
  final GetTotemsUseCase getTotemsUseCase;

  TotemBloc({required this.getTotemsUseCase}) : super(const TotemInitial()) {
    on<LoadTotems>(_onLoadTotems);
    on<RefreshTotems>(_onRefreshTotems);
  }

  /// Handles the LoadTotems event.
  Future<void> _onLoadTotems(LoadTotems event, Emitter<TotemState> emit) async {
    emit(const TotemLoading());

    final result = await getTotemsUseCase(const NoParams());

    result.fold(
      (failure) => emit(TotemError(failure.message)),
      (totems) => emit(TotemLoaded(totems)),
    );
  }

  /// Handles the RefreshTotems event.
  Future<void> _onRefreshTotems(
    RefreshTotems event,
    Emitter<TotemState> emit,
  ) async {
    // Keep current state while refreshing
    final currentState = state;

    final result = await getTotemsUseCase(const NoParams());

    result.fold((failure) {
      // If refresh fails, keep the current state
      if (currentState is TotemLoaded) {
        emit(currentState);
      } else {
        emit(TotemError(failure.message));
      }
    }, (totems) => emit(TotemLoaded(totems)));
  }
}
