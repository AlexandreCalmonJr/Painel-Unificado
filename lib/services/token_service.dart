import 'package:injectable/injectable.dart';
import 'package:painel_windowns/services/auth_service.dart';

/// Service responsible for providing authentication tokens to use cases.
///
/// This service acts as a bridge between the AuthService and the domain layer,
/// following the Dependency Inversion Principle by providing a clean interface
/// for token retrieval without exposing the entire AuthService to use cases.
@lazySingleton
class TokenService {
  final AuthService _authService;

  TokenService(this._authService);

  /// Retrieves the current authentication token.
  ///
  /// Returns null if the user is not authenticated.
  String? getToken() {
    return _authService.currentToken;
  }

  /// Checks if the user is currently authenticated.
  bool isAuthenticated() {
    return _authService.isLoggedIn;
  }
}
