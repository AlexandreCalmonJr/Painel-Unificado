import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:painel_windowns/data/models/ip_mapping_model.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/server_config_service.dart';

class IpMappingService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();

  String get _baseUrl {
    final config = ServerConfigService.instance.loadConfig();
    return 'http://${config['ip']}:${config['port']}/api/units/ip-mappings'; // Ajustar rota conforme backend
  }

  Future<List<IpMapping>> fetchIpMappings() async {
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
        return IpMapping.fromJsonList(data);
      } else {
        throw Exception('Falha ao carregar mapeamentos de IP');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<void> createIpMapping(IpMapping mapping) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer ${_authService.currentToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(mapping.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception('Falha ao criar mapeamento de IP');
      }
    } catch (e) {
      throw Exception('Erro ao criar mapeamento: $e');
    }
  }

  Future<void> deleteIpMapping(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: {'Authorization': 'Bearer ${_authService.currentToken}'},
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao excluir mapeamento de IP');
      }
    } catch (e) {
      throw Exception('Erro ao excluir mapeamento: $e');
    }
  }
}
