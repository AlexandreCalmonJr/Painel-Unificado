import 'package:equatable/equatable.dart';

/// Base class for all totem-related events.
abstract class TotemEvent extends Equatable {
  const TotemEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all totems.
class LoadTotems extends TotemEvent {
  const LoadTotems();
}

/// Event to refresh totems list.
class RefreshTotems extends TotemEvent {
  const RefreshTotems();
}

/// Event to load a specific totem by ID.
class LoadTotemById extends TotemEvent {
  final String totemId;

  const LoadTotemById(this.totemId);

  @override
  List<Object?> get props => [totemId];
}
