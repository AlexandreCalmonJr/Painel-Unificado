import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:painel_windowns/models/totem.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/server_config_service.dart';


class MonitoringService {
  final AuthService authService;

  MonitoringService({required this.authService});

  /// Busca a lista de totens do servidor
  Future<List<Totem>> getTotems() async {
    try {
      // 1. Obter o token atual do AuthService
      final token = authService.currentToken;
      if (token == null || token.isEmpty) {
        throw Exception('Token de autenticação não encontrado. Faça o login novamente.');
      }

      // 2. Obter a URL base do servidor
      final config = ServerConfigService.instance.loadConfig();
      final baseUrl = 'http://${config['ip']}:${config['port']}';

      if (config['ip'] == null || config['port'] == null) {
        throw Exception('URL do servidor não configurada.');
      }

      // 3. Fazer a requisição HTTP para o endpoint dos totens
      final response = await http.get(
        Uri.parse('$baseUrl/api/monitoring/totems'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Tempo limite de conexão excedido');
        },
      );

      // 4. Tratar a resposta do servidor
      if (response.statusCode == 200) {
        final List<dynamic> totemJson = json.decode(response.body);
        
        // Validar se a resposta não está vazia
        if (totemJson.isEmpty) {
          return [];
        }

        // Converter a lista de JSON para objetos Totem
        return totemJson.map((json) => Totem.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        // Token inválido ou expirado - fazer logout
        await authService.logout();
        throw Exception('Sessão expirada. Por favor, faça o login novamente.');
      } else if (response.statusCode == 403) {
        throw Exception('Acesso negado. Verifique suas permissões.');
      } else if (response.statusCode == 404) {
        throw Exception('Endpoint não encontrado. Verifique a configuração do servidor.');
      } else if (response.statusCode >= 500) {
        throw Exception('Erro no servidor. Tente novamente mais tarde.');
      } else {
        throw Exception('Erro ao carregar totens: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Erro de conexão: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Erro ao processar resposta do servidor: ${e.message}');
    } catch (e) {
      // Se o erro já for uma Exception customizada, repassa
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Erro inesperado: ${e.toString()}');
    }
  }

  /// Alias para compatibilidade com código antigo
  Future<List<Totem>> getDevices() async {
    return getTotems();
  }

  /// Envia dados de monitoramento de um totem (para clientes)
  /// Nota: Esta rota usa /api/monitor (sem autenticação)
  Future<void> sendTotemData(Map<String, dynamic> data) async {
    try {
      final config = ServerConfigService.instance.loadConfig();
      final baseUrl = 'http://${config['ip']}:${config['port']}';

      final response = await http.post(
        Uri.parse('$baseUrl/api/monitor'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('Erro ao enviar dados: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao enviar dados do totem: ${e.toString()}');
    }
  }
}