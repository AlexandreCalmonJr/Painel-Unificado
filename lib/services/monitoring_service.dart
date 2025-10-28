// File: lib/services/module_management_service.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:painel_windowns/services/auth_service.dart';

class ModuleManagementService {
  final AuthService authService;
  static const String baseUrl = 'http://seu-servidor.com/api'; // AJUSTE CONFORME SEU SERVIDOR

  ModuleManagementService({required this.authService});

  /// Headers padrão para requisições autenticadas
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${authService.currentToken}',
    };
  }

  /// Atualiza um ativo
  Future<Map<String, dynamic>> updateAsset({
    required String moduleId,
    required String assetId,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/modules/$moduleId/assets/$assetId');
      
      final response = await http.put(
        url,
        headers: _getHeaders(),
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Ativo atualizado com sucesso',
          'asset': data['asset'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Erro ao atualizar ativo',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  /// Deleta um ativo
  Future<Map<String, dynamic>> deleteAsset({
    required String moduleId,
    required String assetId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/modules/$moduleId/assets/$assetId');
      
      final response = await http.delete(
        url,
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Ativo excluído com sucesso',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Erro ao excluir ativo',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  /// Marca ativo para manutenção ou retorna à produção
  Future<Map<String, dynamic>> setMaintenanceMode({
    required String moduleId,
    required String assetId,
    required bool maintenanceMode,
    String? reason,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/modules/$moduleId/assets/$assetId/maintenance');
      
      final body = {
        'maintenance_mode': maintenanceMode,
        if (reason != null && reason.isNotEmpty) 'maintenance_reason': reason,
      };

      final response = await http.patch(
        url,
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 
            (maintenanceMode 
              ? 'Ativo marcado para manutenção' 
              : 'Ativo retornou à produção'),
          'asset': data['asset'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Erro ao alterar status de manutenção',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  /// Atualiza apenas o status de um ativo
  Future<Map<String, dynamic>> updateAssetStatus({
    required String moduleId,
    required String assetId,
    required String status,
  }) async {
    try {
      // Valida status
      const validStatuses = ['online', 'offline', 'maintenance', 'sem monitorar'];
      if (!validStatuses.contains(status)) {
        return {
          'success': false,
          'message': 'Status inválido. Valores aceitos: ${validStatuses.join(", ")}',
        };
      }

      final url = Uri.parse('$baseUrl/modules/$moduleId/assets/$assetId/status');
      
      final response = await http.patch(
        url,
        headers: _getHeaders(),
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Status atualizado com sucesso',
          'asset': data['asset'],
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Erro ao atualizar status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  /// Lista todos os ativos de um módulo
  Future<Map<String, dynamic>> getModuleAssets({
    required String moduleId,
    int page = 1,
    int limit = 50,
    String? status,
    String? search,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final uri = Uri.parse('$baseUrl/modules/$moduleId/assets')
          .replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: _getHeaders());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'assets': data['assets'] ?? [],
          'total_pages': data['total_pages'] ?? 1,
          'current_page': data['current_page'] ?? 1,
          'total_count': data['total_count'] ?? 0,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Erro ao carregar ativos',
          'assets': [],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
        'assets': [],
      };
    }
  }

  /// Cria um novo ativo
  Future<Map<String, dynamic>> createAsset({
    required String moduleId,
    required Map<String, dynamic> assetData,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/modules/$moduleId/assets');
      
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(assetData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Ativo criado com sucesso',
          'asset': data['asset'],
          'updated': data['updated'] ?? false,
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Erro ao criar ativo',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }
}