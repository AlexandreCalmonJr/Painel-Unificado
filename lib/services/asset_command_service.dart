// File: lib/services/asset_command_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/server_config_service.dart';

class AssetCommandService {
  final AuthService authService;

  AssetCommandService({required this.authService});

  String get _baseUrl {
    final config = ServerConfigService.instance.loadConfig();
    return 'http://${config['ip']}:${config['port']}';
  }

  /// Envia um comando para um asset
  Future<bool> sendCommand({
    required String moduleId,
    required String assetId,
    required String commandType,
    String? customCommand,
    Map<String, dynamic>? parameters,
    int? timeout,
  }) async {
    try {
      final token = authService.currentToken;
      if (token == null) {
        throw Exception('Token não disponível');
      }

      final url = '$_baseUrl/api/modules/$moduleId/assets/$assetId/commands';

      final body = {
        'commandType': commandType,
        if (customCommand != null) 'customCommand': customCommand,
        if (parameters != null) 'parameters': parameters,
        if (timeout != null) 'timeout': timeout,
      };

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print(
          'Erro ao enviar comando: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Exceção ao enviar comando: $e');
      return false;
    }
  }

  /// Busca o histórico de comandos de um asset
  Future<List<Map<String, dynamic>>> getCommandHistory({
    required String moduleId,
    required String assetId,
    int limit = 50,
    String? status,
  }) async {
    try {
      final token = authService.currentToken;
      if (token == null) {
        throw Exception('Token não disponível');
      }

      var url =
          '$_baseUrl/api/modules/$moduleId/assets/$assetId/commands?limit=$limit';
      if (status != null) {
        url += '&status=$status';
      }

      final response = await http
          .get(Uri.parse(url), headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['commands'] != null) {
          return List<Map<String, dynamic>>.from(data['commands']);
        }
      }
      return [];
    } catch (e) {
      print('Erro ao buscar histórico de comandos: $e');
      return [];
    }
  }

  /// Comandos pré-definidos disponíveis
  static const Map<String, Map<String, dynamic>> availableCommands = {
    'restart_computer': {
      'label': 'Reiniciar Computador',
      'icon': 'restart_alt',
      'description': 'Reinicia o computador em 30 segundos',
      'requiresElevation': true,
    },
    'flush_dns': {
      'label': 'Limpar Cache DNS',
      'icon': 'dns',
      'description': 'Limpa o cache DNS do sistema',
      'requiresElevation': false,
    },
    'restart_print_spooler': {
      'label': 'Reiniciar Spooler de Impressão',
      'icon': 'print',
      'description': 'Reinicia o serviço de impressão',
      'requiresElevation': true,
    },
    'clear_temp': {
      'label': 'Limpar Arquivos Temporários',
      'icon': 'cleaning_services',
      'description': 'Remove arquivos temporários do sistema',
      'requiresElevation': false,
    },
    'network_reset': {
      'label': 'Reset de Rede',
      'icon': 'settings_ethernet',
      'description': 'Reseta completamente as configurações de rede',
      'requiresElevation': true,
    },
    'restart_automatos': {
      'label': 'Reiniciar Automatos',
      'icon': 'settings_applications',
      'description': 'Reinicia o serviço Automatos',
      'requiresElevation': true,
    },
    'restart_ndd': {
      'label': 'Reiniciar NDD Print',
      'icon': 'print_disabled',
      'description': 'Reinicia o serviço NDD Print',
      'requiresElevation': true,
    },
  };
}
