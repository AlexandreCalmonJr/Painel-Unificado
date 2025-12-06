// File: lib/services/command_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/logger_service.dart';
import 'package:painel_windowns/services/server_config_service.dart';

class CommandService {
  final AuthService _authService;

  CommandService(this._authService);

  String get _baseUrl {
    final config = ServerConfigService.instance.loadConfig();
    return 'http://${config['ip']}:${config['port']}';
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${_authService.currentToken}',
  };

  /// Envia comando para um ativo
  Future<Map<String, dynamic>> sendCommand({
    required String moduleId,
    required String assetId,
    required String commandType,
    String? customCommand,
    Map<String, dynamic>? parameters,
    int? timeout,
  }) async {
    try {
      final body = {
        'commandType': commandType,
        if (customCommand != null) 'customCommand': customCommand,
        if (parameters != null) 'parameters': parameters,
        if (timeout != null) 'timeout': timeout,
      };

      final response = await http
          .post(
            Uri.parse(
              '$_baseUrl/api/modules/$moduleId/assets/$assetId/commands',
            ),
            headers: _headers,
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro ao enviar comando: ${e.toString()}',
      };
    }
  }

  /// Busca histórico de comandos de um ativo
  Future<List<Map<String, dynamic>>> getCommandHistory({
    required String moduleId,
    required String assetId,
    int limit = 50,
    String? status,
  }) async {
    try {
      final queryParams = {
        'limit': limit.toString(),
        if (status != null) 'status': status,
      };

      final uri = Uri.parse(
        '$_baseUrl/api/modules/$moduleId/assets/$assetId/commands',
      ).replace(queryParameters: queryParams);

      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['commands'] ?? []);
      }
      return [];
    } catch (e) {
      logger.error(
        'Erro ao buscar histórico de comandos',
        tag: 'CommandService.getCommandHistory',
        error: e,
      );
      return [];
    }
  }

  /// Comandos pré-definidos disponíveis
  static const Map<String, Map<String, dynamic>> predefinedCommands = {
    'restart_computer': {
      'label': 'Reiniciar Computador',
      'icon': 'restart_alt',
      'description': 'Reinicia o computador em 30 segundos',
      'requiresElevation': true,
      'color': 'orange',
    },
    'flush_dns': {
      'label': 'Limpar Cache DNS',
      'icon': 'dns',
      'description': 'Executa ipconfig /flushdns',
      'requiresElevation': false,
      'color': 'blue',
    },
    'restart_print_spooler': {
      'label': 'Reiniciar Spooler',
      'icon': 'print',
      'description': 'Reinicia o serviço de impressão do Windows',
      'requiresElevation': true,
      'color': 'purple',
    },
    'restart_automatos': {
      'label': 'Reiniciar Automatos',
      'icon': 'settings',
      'description': 'Reinicia o serviço Automatos',
      'requiresElevation': true,
      'color': 'green',
    },
    'restart_ndd': {
      'label': 'Reiniciar NDD Print',
      'icon': 'print_disabled',
      'description': 'Reinicia o serviço NDD Print',
      'requiresElevation': true,
      'color': 'teal',
    },
    'clear_temp': {
      'label': 'Limpar Arquivos Temp',
      'icon': 'delete_sweep',
      'description': 'Remove arquivos da pasta TEMP',
      'requiresElevation': false,
      'color': 'red',
    },
    'network_reset': {
      'label': 'Resetar Rede',
      'icon': 'settings_ethernet',
      'description': 'Reseta configurações de rede (Winsock, TCP/IP)',
      'requiresElevation': true,
      'color': 'indigo',
    },
    // ✅ NOVOS COMANDOS ADICIONADOS
    'map_lpt2': {
      'label': 'Mapear LPT2',
      'icon': 'print',
      'description': 'Mapeia compartilhamento de rede para LPT2',
      'requiresElevation': true,
      'color': 'teal',
      'hasParams': true, // Habilita inputs no Dialog
    },
    'download_file': {
      'label': 'Enviar Arquivo',
      'icon': 'file_download',
      'description': 'Baixa um arquivo da web para o disco local',
      'requiresElevation': false,
      'color': 'indigo',
      'hasParams': true, // Habilita inputs no Dialog
    },
    'auto_start_app': {
      'label': 'Auto Iniciar App',
      'icon': 'play_circle',
      'description': 'Configura app para iniciar ao ligar o PC',
      'requiresElevation': true,
      'color': 'green',
      'hasParams': true, // Habilita inputs no Dialog
    },
  };
}
