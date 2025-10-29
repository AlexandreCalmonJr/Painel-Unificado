import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
// Importe o modelo Totem
import 'package:painel_windowns/models/totem.dart';
// Importe seu serviço de configuração de servidor
import 'package:painel_windowns/services/server_config_service.dart'; 

// Constantes para a lógica de retentativa
const int kMaxRetries = 3;
const Duration kRetryDelay = Duration(seconds: 2);

///
/// Serviço dedicado para gerenciar as operações CRUD da API de Totens.
/// (/api/monitoring/...)
///
class TotemService {

  /// Wrapper de requisição HTTP com lógica de retentativa, timeout e tratamento de erro.
  Future<http.Response> _performHttpRequest({
    required Future<http.Response> Function() request,
    required String errorMessage,
  }) async {
    int attempts = 0;
    while (attempts < kMaxRetries) {
      attempts++;
      try {
        final response = await request().timeout(const Duration(seconds: 15));
        
        // Sucesso
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        } 
        
        // Erro do Servidor (tratado)
        else {
          try {
            // Tenta decodificar o erro da API (ex: { "message": "..." })
            final errorData = jsonDecode(response.body);
            final apiError = errorData['message'] ?? errorData['error'] ?? 'Erro ${response.statusCode}: ${response.reasonPhrase}';
            throw Exception(apiError);
          } catch (_) {
            // Falha ao decodificar, usa o status HTTP
            throw Exception('Erro ${response.statusCode}: ${response.reasonPhrase}');
          }
        }
      } on TimeoutException {
        if (attempts == kMaxRetries) throw Exception('$errorMessage: Tempo limite esgotado.');
        await Future.delayed(kRetryDelay);
      } on SocketException {
        if (attempts == kMaxRetries) throw Exception('$errorMessage: Falha na conexão com o servidor.');
        await Future.delayed(kRetryDelay);
      } catch (e) {
        // Captura erros (incluindo os throw Exception de cima)
        throw Exception('$errorMessage: ${e.toString().replaceFirst("Exception: ", "")}');
      }
    }
    // Nunca deve chegar aqui, mas é um fallback
    throw Exception('$errorMessage após $kMaxRetries tentativas.');
  }

  // ----------------------------------------------
  // MÉTODOS CRUD PARA TOTEMS
  // ----------------------------------------------

  /// [R] READ (All)
  /// Busca todos os totens do servidor.
  /// Rota: GET /api/monitoring/totems
  Future<List<Totem>> fetchTotems(String token) async {
    final config = ServerConfigService.instance.loadConfig();
    final serverIp = config['ip'];
    final serverPort = config['port'];

    final response = await _performHttpRequest(
      request: () => http.get(
        Uri.parse('http://$serverIp:$serverPort/api/monitoring/totems'),
        headers: {'Authorization': 'Bearer $token'},
      ),
      errorMessage: 'Erro ao buscar totens',
    );

    final data = jsonDecode(response.body);
    if (data is List) {
      return data.map((json) => Totem.fromJson(json)).toList();
    }
    
    throw Exception('Resposta inválida do servidor: Esperado uma lista de totens.');
  }

  /// [R] READ (Single)
  /// Busca um totem específico pelo seu Serial Number.
  /// Rota: GET /api/monitoring/totems/:serialNumber
  Future<Totem> fetchTotem(String token, String serialNumber) async {
    final config = ServerConfigService.instance.loadConfig();
    final serverIp = config['ip'];
    final serverPort = config['port'];
    
    final encodedSerial = Uri.encodeComponent(serialNumber);

    final response = await _performHttpRequest(
      request: () => http.get(
        Uri.parse('http://$serverIp:$serverPort/api/monitoring/totems/$encodedSerial'),
        headers: {'Authorization': 'Bearer $token'},
      ),
      errorMessage: 'Erro ao buscar dados do totem',
    );
    
    final data = jsonDecode(response.body);
    // A rota de item único retorna o objeto Totem diretamente
    return Totem.fromJson(data);
  }

  /// [U] UPDATE
  /// Atualiza dados de um totem no servidor (ex: notas do admin).
  /// Rota: PUT /api/monitoring/totems/:serialNumber
  Future<String> updateTotem(String token, String serialNumber, Map<String, dynamic> updateData) async {
    final config = ServerConfigService.instance.loadConfig();
    final serverIp = config['ip'];
    final serverPort = config['port'];
    
    final encodedSerial = Uri.encodeComponent(serialNumber);

    final response = await _performHttpRequest(
      request: () => http.put(
        Uri.parse('http://$serverIp:$serverPort/api/monitoring/totems/$encodedSerial'),
        headers: {
          'Authorization': 'Bearer $token', 
          'Content-Type': 'application/json'
        },
        body: jsonEncode(updateData),
      ),
      errorMessage: 'Erro ao atualizar totem',
    );
    
    final data = jsonDecode(response.body);
    return data['message']?.toString() ?? 'Totem atualizado com sucesso';
  }

  /// [D] DELETE
  /// Exclui um totem do servidor.
  /// Rota: DELETE /api/monitoring/totems/:serialNumber
  Future<String> deleteTotem(String token, String serialNumber) async {
    final config = ServerConfigService.instance.loadConfig();
    final serverIp = config['ip'];
    final serverPort = config['port'];
    
    final encodedSerial = Uri.encodeComponent(serialNumber);

    final response = await _performHttpRequest(
      request: () => http.delete(
        Uri.parse('http://$serverIp:$serverPort/api/monitoring/totems/$encodedSerial'),
        headers: {'Authorization': 'Bearer $token'},
      ),
      errorMessage: 'Erro ao excluir totem',
    );

    final data = jsonDecode(response.body);
    return data['message']?.toString() ?? 'Totem excluído com sucesso';
  }
}