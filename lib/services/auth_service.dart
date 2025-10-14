// File: lib/services/auth_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:painel_windowns/services/server_config_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // ... (todo o resto do seu código: _token, _user, login, etc. permanece igual)
  String? _token;
  Map<String, dynamic>? _user;

  String? get currentToken => _token;
  Map<String, dynamic>? get currentUser => _user;
  bool get isLoggedIn => _token != null;
  bool get isAdmin => _user?['role'] == 'admin';
  List<String>? get permissions => List<String>.from(_user?['permissions'] ?? []);

  Future<void> initializeFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final userDataString = prefs.getString('user');
    if (userDataString != null) {
      try {
        _user = jsonDecode(userDataString);
      } catch (e) {
        await prefs.remove('user');
        _user = null;
      }
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final config = ServerConfigService.instance.loadConfig();
    final serverIp = config['ip'];
    final serverPort = config['port'];

    try {
      final response = await http.post(
        Uri.parse('http://$serverIp:$serverPort/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _user = data['user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('user', jsonEncode(_user));
        
        return {'success': true};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Falha no login'};
      }
    } on TimeoutException {
        return {'success': false, 'message': 'O servidor demorou muito para responder. Verifique a conexão.'};
    } on SocketException {
        return {'success': false, 'message': 'Não foi possível conectar ao servidor. Verifique o IP e a rede.'};
    } on http.ClientException catch (e) {
        return {'success': false, 'message': 'Erro de rede: ${e.message}. Verifique o IP e o Firewall.'};
    } catch (e) {
        return {'success': false, 'message': 'Erro inesperado: ${e.toString()}'};
    }
  }

  // ##### MÉTODO createUser MODIFICADO #####
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    if (!isAdmin) return {'success': false, 'message': 'Acesso não autorizado'};
    final config = ServerConfigService.instance.loadConfig();
    try {
      final response = await http.post(
        Uri.parse('http://${config['ip']}:${config['port']}/api/auth/register'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode(userData),
      );
      final data = jsonDecode(response.body);
      
      // A mudança está aqui: agora retornamos o usuário no sucesso
      if (response.statusCode == 201) {
        return {'success': true, 'message': data['message'], 'user': data['user']};
      } else {
        return {'success': false, 'message': data['message']};
      }

    } catch (e) {
      return {'success': false, 'message': 'Falha na conexão ao criar utilizador'};
    }
  }

  Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> userData) async {
    if (!isAdmin) return {'success': false, 'message': 'Acesso não autorizado'};
    final config = ServerConfigService.instance.loadConfig();
    try {
      final response = await http.put(
        Uri.parse('http://${config['ip']}:${config['port']}/api/auth/users/$userId'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
        body: jsonEncode(userData),
      );
      final data = jsonDecode(response.body);
      return {'success': response.statusCode == 200, 'message': data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Falha na conexão ao atualizar utilizador'};
    }
  }
  
  Future<Map<String, dynamic>> getUsers() async {
    if (!isLoggedIn || !isAdmin) {
      return {'success': false, 'message': 'Acesso não autorizado', 'users': []};
    }
    final config = ServerConfigService.instance.loadConfig();
    try {
      final response = await http.get(
        Uri.parse('http://${config['ip']}:${config['port']}/api/auth/users'),
        headers: {'Authorization': 'Bearer $currentToken'},
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'users': data['users']};
      } else {
        return {'success': false, 'message': 'Falha ao buscar usuários', 'users': []};
      }
    } catch (e) {
      return {'success': false, 'users': [], 'message': 'Erro de conexão: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> deleteUser(String userId) async {
    if (!isAdmin) return {'success': false, 'message': 'Acesso não autorizado'};
    final config = ServerConfigService.instance.loadConfig();
    try {
      final response = await http.delete(
        Uri.parse('http://${config['ip']}:${config['port']}/api/auth/users/$userId'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      final data = jsonDecode(response.body);
      return {'success': response.statusCode == 200, 'message': data['message']};
    } catch (e) {
      return {'success': false, 'message': 'Falha na conexão ao eliminar utilizador'};
    }
  }

  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    if (!isLoggedIn) return {'success': false, 'message': 'Utilizador não autenticado'};
    final config = ServerConfigService.instance.loadConfig();
    try {
      final response = await http.post(
        Uri.parse('http://${config['ip']}:${config['port']}/api/auth/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message'] ?? 'Senha alterada com sucesso'};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Falha ao alterar senha'};
      }
    } on TimeoutException {
      return {'success': false, 'message': 'O servidor demorou muito para responder. Verifique a conexão.'};
    } on SocketException {
      return {'success': false, 'message': 'Não foi possível conectar ao servidor. Verifique o IP e a rede.'};
    } on http.ClientException catch (e) {
      return {'success': false, 'message': 'Erro de rede: ${e.message}. Verifique o IP e o Firewall.'};
    } catch (e) {
      return {'success': false, 'message': 'Erro inesperado: ${e.toString()}'};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    _token = null;
    _user = null;
  }
}