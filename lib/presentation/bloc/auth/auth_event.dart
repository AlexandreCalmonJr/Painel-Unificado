import 'package:equatable/equatable.dart';

/// Base class for all authentication-related events.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check if user is authenticated.
class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

/// Event to login a user.
class LoginRequested extends AuthEvent {
  final String username;
  final String password;

  const LoginRequested({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}

/// Event to logout a user.
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
