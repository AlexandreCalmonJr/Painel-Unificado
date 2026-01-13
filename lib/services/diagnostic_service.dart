import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/server_config_service.dart';
import 'package:get/get.dart';

class DiagnosticService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();

  String get _baseUrl {
    final config = ServerConfigService.instance.loadConfig();
    return 'http://${config['ip']}:${config['port']}/api';
  }

  Future<Map<String, dynamic>> testLocation({String? ip, String? bssid}) async {
    try {
      final queryParams = <String, String>{};
      if (ip != null) queryParams['ip'] = ip;
      if (bssid != null) queryParams['bssid'] = bssid;

      final uri = Uri.parse(
        '$_baseUrl/devices/test-location',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${_authService.currentToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Falha ao testar localização');
      }
    } catch (e) {
      throw Exception('Erro no teste de localização: $e');
    }
  }

  Future<Map<String, dynamic>> validateBssids() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/devices/validate-bssids'),
        headers: {'Authorization': 'Bearer ${_authService.currentToken}'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Falha na validação de BSSIDs');
      }
    } catch (e) {
      throw Exception('Erro ao validar BSSIDs: $e');
    }
  }

  Future<List<dynamic>> getUnmappedDevices() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/devices/unmapped'),
        headers: {'Authorization': 'Bearer ${_authService.currentToken}'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Falha ao buscar dispositivos não mapeados');
      }
    } catch (e) {
      throw Exception('Erro ao buscar dispositivos não mapeados: $e');
    }
  }
}
