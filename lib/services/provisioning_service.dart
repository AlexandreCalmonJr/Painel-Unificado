import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/server_config_service.dart';

class ProvisioningService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();

  String get _baseUrl {
    final config = ServerConfigService.instance.loadConfig();
    return 'http://${config['ip']}:${config['port']}/api/provisioning';
  }

  Future<String> generateToken(
    String profileId, {
    int? usageLimit,
    int? expiresInHours,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/token'),
        headers: {
          'Authorization': 'Bearer ${_authService.currentToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'configProfileId': profileId,
          'usageLimit': usageLimit,
          'expiresInHours': expiresInHours,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['token'] as String;
      } else {
        throw Exception('Falha ao gerar token de provisionamento');
      }
    } catch (e) {
      throw Exception('Erro ao gerar token: $e');
    }
  }

  Future<Map<String, dynamic>> enrollDevice(
    String token,
    Map<String, dynamic> deviceData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/enroll'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token, 'deviceData': deviceData}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Falha no provisionamento do dispositivo');
      }
    } catch (e) {
      throw Exception('Erro no provisionamento: $e');
    }
  }
}
