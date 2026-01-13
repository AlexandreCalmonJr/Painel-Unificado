import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/server_config_service.dart';

class ConfigProfileService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();

  String get _baseUrl {
    final config = ServerConfigService.instance.loadConfig();
    return 'http://${config['ip']}:${config['port']}/api/config-profiles';
  }

  Future<List<Map<String, dynamic>>> listProfiles() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer ${_authService.currentToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Falha ao listar perfis de configuração');
      }
    } catch (e) {
      throw Exception('Erro ao listar perfis: $e');
    }
  }

  Future<void> createProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer ${_authService.currentToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(profileData),
      );

      if (response.statusCode != 201) {
        throw Exception('Falha ao criar perfil de configuração');
      }
    } catch (e) {
      throw Exception('Erro ao criar perfil: $e');
    }
  }
}
