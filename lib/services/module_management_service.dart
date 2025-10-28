// File: lib/services/module_management_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/models/unit.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/server_config_service.dart';

class ModuleManagementService {
  final AuthService authService;

  ModuleManagementService({required this.authService});
  
  String? get _token => authService.currentToken;
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_token',
  };
  String get _baseUrl {
    final config = ServerConfigService.instance.loadConfig();
    return 'http://${config['ip']}:${config['port']}';
  }

  Future<http.Response> _performHttpRequest({
    required Future<http.Response> Function() request,
    required String errorMessage,
  }) async {
    int attempts = 0;
    while (attempts < 3) { // kMaxRetries
      attempts++;
      try {
        final response = await request().timeout(const Duration(seconds: 15));
        
        if (response.statusCode == 401) {
           await authService.logout();
           throw Exception('Sessão expirada. Por favor, faça o login novamente.');
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        } else {
          try {
            final errorData = jsonDecode(response.body);
            throw Exception(errorData['message'] ?? 'Erro ${response.statusCode}: ${response.reasonPhrase}');
          } catch (_) {
            throw Exception('Erro ${response.statusCode}: ${response.reasonPhrase}');
          }
        }
      } on TimeoutException {
        if (attempts == 3) throw Exception('$errorMessage: Tempo limite esgotado.');
        await Future.delayed(const Duration(seconds: 2));
      } on SocketException {
         if (attempts == 3) throw Exception('$errorMessage: Falha na conexão com o servidor.');
         await Future.delayed(const Duration(seconds: 2));
      } on http.ClientException catch(e) {
         if (attempts == 3) throw Exception('$errorMessage: ${e.message}');
         await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('$errorMessage: ${e.toString()}');
      }
    }
    throw Exception('$errorMessage após 3 tentativas.');
  }

  /// Busca todas as unidades
  Future<List<Unit>> fetchUnits() async {
    if (_token == null) throw Exception("Não autenticado");

    final response = await _performHttpRequest(
      request: () => http.get(
        Uri.parse('$_baseUrl/api/units'),
        headers: _headers,
      ),
      errorMessage: 'Erro ao buscar unidades',
    );

    final data = jsonDecode(response.body);
    if (data is Map<String, dynamic> && data.containsKey('units')) {
      return (data['units'] as List).map((json) => Unit.fromJson(json)).toList();
    }
    throw Exception('Resposta inválida do servidor: Esperado uma lista de unidades.');
  }

  /// Lista todos os módulos disponíveis
  Future<List<AssetModuleConfig>> listModules() async {
    if (_token == null) throw Exception("Não autenticado");
    final response = await _performHttpRequest(
      request: () => http.get(
        Uri.parse('$_baseUrl/api/modules'),
        headers: _headers,
      ),
      errorMessage: 'Erro ao carregar módulos',
    );
    final data = json.decode(response.body);
    final List<dynamic> modulesJson = data['modules'];
    return modulesJson.map((json) => AssetModuleConfig.fromJson(json)).toList();
  }

  /// Cria um novo módulo
  Future<AssetModuleConfig> createModule({
    required String name,
    required String description,
    required AssetModuleType type,
    Map<String, dynamic> customFields = const {},
    Map<String, dynamic> settings = const {},
    required List<Map<String, String>> tableColumns,
  }) async {
    if (_token == null) throw Exception("Não autenticado");
    
    final moduleData = {
      'name': name,
      'description': description,
      'type': type.identifier,
      'is_custom': type == AssetModuleType.custom,
      'custom_fields': customFields,
      'settings': settings,
      'table_columns': tableColumns, // Envia a configuração
    };

    final response = await _performHttpRequest(
      request: () => http.post(
        Uri.parse('$_baseUrl/api/modules'),
        headers: _headers,
        body: json.encode(moduleData),
      ),
      errorMessage: 'Erro ao criar módulo',
    );
    
    final data = json.decode(response.body);
    return AssetModuleConfig.fromJson(data['module']);
  }

  /// Atualiza um módulo existente
  Future<AssetModuleConfig> updateModule({
    required String moduleId,
    String? name,
    String? description,
    bool? isActive,
    Map<String, dynamic>? customFields,
    Map<String, dynamic>? settings,
    List<Map<String, String>>? tableColumns, required AssetModuleType type,
  }) async {
    if (_token == null) throw Exception("Não autenticado");

    final updateData = <String, dynamic>{};
    if (name != null) updateData['name'] = name;
    if (description != null) updateData['description'] = description;
    if (isActive != null) updateData['is_active'] = isActive;
    if (customFields != null) updateData['custom_fields'] = customFields;
    if (settings != null) updateData['settings'] = settings;
    if (tableColumns != null) updateData['table_columns'] = tableColumns;

    final response = await _performHttpRequest(
      request: () => http.put(
        Uri.parse('$_baseUrl/api/modules/$moduleId'),
        headers: _headers,
        body: json.encode(updateData),
      ),
      errorMessage: 'Erro ao atualizar módulo',
    );
    
    final data = json.decode(response.body);
    return AssetModuleConfig.fromJson(data['module']);
  }

  /// Deleta um módulo
  Future<void> deleteModule(String moduleId) async {
    if (_token == null) throw Exception("Não autenticado");
    await _performHttpRequest(
      request: () => http.delete(
        Uri.parse('$_baseUrl/api/modules/$moduleId'),
        headers: _headers,
      ),
      errorMessage: 'Erro ao deletar módulo',
    );
  }

  /// Lista ativos (JSON bruto) de um módulo específico
  Future<List<dynamic>> listModuleAssets(String moduleId) async {
    if (_token == null) throw Exception("Não autenticado");
    final response = await _performHttpRequest(
      request: () => http.get(
        Uri.parse('$_baseUrl/api/modules/$moduleId/assets'),
        headers: _headers,
      ),
      errorMessage: 'Erro ao carregar ativos',
    );
    final data = json.decode(response.body);
    return data['assets'] as List<dynamic>;
  }

  /// Adiciona um ativo a um módulo (não usado, mas mantido)
  Future<Map<String, dynamic>> addAssetToModule({
    required String moduleId,
    required Map<String, dynamic> assetData,
  }) async {
    if (_token == null) throw Exception("Não autenticado");
    final response = await _performHttpRequest(
      request: () => http.post(
        Uri.parse('$_baseUrl/api/modules/$moduleId/assets'),
        headers: _headers,
        body: json.encode(assetData),
      ),
      errorMessage: 'Erro ao adicionar ativo',
    );
    final data = json.decode(response.body);
    return data['asset'] as Map<String, dynamic>;
  }

  /// Atualiza um ativo
  Future<Map<String, dynamic>> updateAsset({
    required String moduleId,
    required String assetId,
    required Map<String, dynamic> updateData,
  }) async {
    if (_token == null) throw Exception("Não autenticado");
    final response = await _performHttpRequest(
      request: () => http.put(
        Uri.parse('$_baseUrl/api/modules/$moduleId/assets/$assetId'),
        headers: _headers,
        body: json.encode(updateData),
      ),
      errorMessage: 'Erro ao atualizar ativo',
    );
    final data = json.decode(response.body);
    return data['asset'] as Map<String, dynamic>;
  }

  /// Deleta um ativo
  Future<void> deleteAsset({
    required String moduleId,
    required String assetId,
  }) async {
    if (_token == null) throw Exception("Não autenticado");
    await _performHttpRequest(
      request: () => http.delete(
        Uri.parse('$_baseUrl/api/modules/$moduleId/assets/$assetId'),
        headers: _headers,
      ),
      errorMessage: 'Erro ao deletar ativo',
    );
  }

  /// Busca os IDs dos usuários que têm permissão para um módulo
  Future<List<String>> getModulePermissions(String moduleId) async {
    if (_token == null) throw Exception("Não autenticado");
    final response = await _performHttpRequest(
      request: () => http.get(
        Uri.parse('$_baseUrl/api/modules/$moduleId/permissions'),
        headers: _headers,
      ),
      errorMessage: 'Erro ao buscar permissões',
    );
    final data = jsonDecode(response.body);
    if (data['success'] == true && data['users'] is List) {
      return List<String>.from(data['users']);
    }
    throw Exception(data['message'] ?? 'Resposta inválida do servidor');
  }

  /// Atualiza a lista de usuários que têm permissão
  Future<void> updateModulePermissions(String moduleId, List<String> userIds) async {
    if (_token == null) throw Exception("Não autenticado");
    await _performHttpRequest(
      request: () => http.put(
        Uri.parse('$_baseUrl/api/modules/$moduleId/permissions'),
        headers: _headers,
        body: jsonEncode({'userIds': userIds}),
      ),
      errorMessage: 'Erro ao atualizar permissões',
    );
  }

  Future setMaintenanceMode({required String moduleId, required String assetId, required bool maintenanceMode, String? reason}) async {}
}