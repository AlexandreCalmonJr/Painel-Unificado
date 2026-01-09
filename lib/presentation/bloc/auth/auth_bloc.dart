import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:painel_windowns/domain/usecases/auth/login_usecase.dart';
import 'package:painel_windowns/domain/usecases/auth/logout_usecase.dart';
import 'package:painel_windowns/domain/usecases/usecase.dart';
import 'package:painel_windowns/presentation/bloc/auth/auth_event.dart';
import 'package:painel_windowns/presentation/bloc/auth/auth_state.dart';

/// BLoC for managing authentication state and business logic.
///
/// This BLoC handles authentication operations such as login,
/// logout, and checking authentication status.
@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {

  AuthBloc({required this.loginUseCase, required this.logoutUseCase})
    : super(const AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;

  /// Handles the CheckAuthStatus event.
  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    // TODO: Implement check auth status logic
    // For now, assume unauthenticated
    await Future.delayed(const Duration(milliseconds: 500));
    emit(const Unauthenticated());
  }

  /// Handles the LoginRequested event.
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await loginUseCase(
      LoginParams(username: event.username, password: event.password),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  /// Handles the LogoutRequested event.
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await logoutUseCase(const NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const Unauthenticated()),
    );
  }
}
