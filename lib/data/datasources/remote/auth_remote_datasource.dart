import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:painel_windowns/core/error/exceptions.dart';
import 'package:painel_windowns/services/server_config_service.dart';

/// Data Source remoto para autenticação
abstract class AuthRemoteDataSource {
  /// Realiza login e retorna token
  Future<Map<String, dynamic>> login(String username, String password);

  /// Valida token
  Future<bool> validateToken(String token);

  /// Busca informações do usuário atual
  Future<Map<String, dynamic>> getCurrentUser(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required this.client, required this.baseUrl});
  final http.Client client;
  final String baseUrl;

  String get _currentBaseUrl {
    final config = ServerConfigService.instance.loadConfig();
    return 'http://${config['ip']}:${config['port']}/api';
  }

  @override
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await client.post(
        Uri.parse('$_currentBaseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Invalid credentials');
      } else {
        throw ServerException(message: 'Login failed: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<bool> validateToken(String token) async {
    try {
      final response = await client.get(
        Uri.parse('$_currentBaseUrl/auth/validate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    try {
      final response = await client.get(
        Uri.parse('$_currentBaseUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else {
        throw ServerException(
          message: 'Failed to get user: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: $e');
    }
  }
}
