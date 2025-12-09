// File: lib/services/asset_maintenance_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/server_config_service.dart';

class AssetMaintenanceService {
  final AuthService authService;

  AssetMaintenanceService({required this.authService});

  String get _baseUrl {
    final config = ServerConfigService.instance.loadConfig();
    return 'http://${config['ip']}:${config['port']}';
  }

  /// Atualiza o status de manutenção de um asset
  Future<bool> setMaintenanceStatus({
    required String moduleId,
    required String assetId,
    required bool status,
    String? ticket,
    String? reason,
  }) async {
    try {
      final token = authService.currentToken;
      if (token == null) {
        throw Exception('Token não disponível');
      }

      final url = '$_baseUrl/api/modules/$moduleId/assets/$assetId/maintenance';

      final body = {
        'maintenance_status': status,
        if (ticket != null && ticket.isNotEmpty) 'maintenance_ticket': ticket,
        if (reason != null && reason.isNotEmpty) 'maintenance_reason': reason,
        'maintenance_history_entry': json.encode({
          'timestamp': DateTime.now().toIso8601String(),
          'status': status ? 'Em Manutenção' : 'Operacional',
          if (ticket != null && ticket.isNotEmpty) 'ticket': ticket,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        }),
      };

      final response = await http
          .put(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      } else {
        print(
          'Erro ao atualizar manutenção: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Exceção ao atualizar manutenção: $e');
      return false;
    }
  }
}
