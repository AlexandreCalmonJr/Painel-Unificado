import 'package:equatable/equatable.dart';
import 'package:painel_windowns/domain/entities/user_entity.dart';

/// Base class for all authentication-related states.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the auth bloc is first created.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State when authentication is being checked.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State when user is authenticated.
class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// State when user is not authenticated.
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// State when an authentication error occurs.
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
