import 'package:equatable/equatable.dart';
import 'package:painel_windowns/domain/entities/totem_entity.dart';

/// Base class for all totem-related states.
abstract class TotemState extends Equatable {
  const TotemState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the totem bloc is first created.
class TotemInitial extends TotemState {
  const TotemInitial();
}

/// State when totems are being loaded.
class TotemLoading extends TotemState {
  const TotemLoading();
}

/// State when totems have been successfully loaded.
class TotemLoaded extends TotemState {

  const TotemLoaded(this.totems);
  final List<TotemEntity> totems;

  @override
  List<Object?> get props => [totems];
}

/// State when an error occurs while loading totems.
class TotemError extends TotemState {

  const TotemError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
