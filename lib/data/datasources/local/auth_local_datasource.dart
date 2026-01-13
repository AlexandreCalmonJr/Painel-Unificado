import 'package:painel_windowns/core/error/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Data Source local para autenticação (token storage)
abstract class AuthLocalDataSource {
  /// Salva token de autenticação
  Future<void> saveAuthToken(String token);

  /// Busca token de autenticação
  Future<String?> getAuthToken();

  /// Remove token de autenticação
  Future<void> removeAuthToken();

  /// Salva dados do usuário
  Future<void> saveUserData(Map<String, dynamic> userData);

  /// Busca dados do usuário
  Future<Map<String, dynamic>?> getUserData();

  /// Limpa todos os dados de autenticação
  Future<void> clearAuthData();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {

  AuthLocalDataSourceImpl({required this.sharedPreferences});
  final SharedPreferences sharedPreferences;

  static const String AUTH_TOKEN_KEY = 'AUTH_TOKEN';
  static const String USER_DATA_KEY = 'USER_DATA';

  @override
  Future<void> saveAuthToken(String token) async {
    try {
      await sharedPreferences.setString(AUTH_TOKEN_KEY, token);
    } catch (e) {
      throw CacheException(message: 'Error saving token: $e');
    }
  }

  @override
  Future<String?> getAuthToken() async {
    try {
      return sharedPreferences.getString(AUTH_TOKEN_KEY);
    } catch (e) {
      throw CacheException(message: 'Error reading token: $e');
    }
  }

  @override
  Future<void> removeAuthToken() async {
    try {
      await sharedPreferences.remove(AUTH_TOKEN_KEY);
    } catch (e) {
      throw CacheException(message: 'Error removing token: $e');
    }
  }

  @override
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final userDataString = userData.toString();
      await sharedPreferences.setString(USER_DATA_KEY, userDataString);
    } catch (e) {
      throw CacheException(message: 'Error saving user data: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final userDataString = sharedPreferences.getString(USER_DATA_KEY);
      if (userDataString != null) {
        // Simplified - in production, use proper JSON serialization
        return {};
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Error reading user data: $e');
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      await sharedPreferences.remove(AUTH_TOKEN_KEY);
      await sharedPreferences.remove(USER_DATA_KEY);
    } catch (e) {
      throw CacheException(message: 'Error clearing auth data: $e');
    }
  }
}
