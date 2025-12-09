// File: lib/services/module_management_service.dart (VERSÃO CORRIGIDA)
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/models/bssid_mapping.dart';
import 'package:painel_windowns/models/desktop.dart';
import 'package:painel_windowns/models/notebook.dart';
import 'package:painel_windowns/models/painel.dart';
import 'package:painel_windowns/models/printer.dart';
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

  // ===================================================================
  // ✅ CORRIGIDO: Método com retries e validação
  // ===================================================================
  Future<http.Response> _performHttpRequest({
    required Future<http.Response> Function() request,
    required String errorMessage,
  }) async {
    int attempts = 0;
    while (attempts < 3) {
      attempts++;
      try {
        final response = await request().timeout(
          const Duration(seconds: 30),
        ); // ✅ Aumentado timeout

        if (response.statusCode == 401) {
          await authService.logout();
          throw Exception('Sessão expirada. Faça login novamente.');
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        } else {
          try {
            final errorData = jsonDecode(response.body);
            throw Exception(
              errorData['message'] ?? 'Erro ${response.statusCode}',
            );
          } catch (_) {
            throw Exception(
              'Erro ${response.statusCode}: ${response.reasonPhrase}',
            );
          }
        }
      } on TimeoutException {
        if (attempts == 3)
          throw Exception('$errorMessage: Tempo esgotado (30s)');
        await Future.delayed(const Duration(seconds: 2));
      } on SocketException {
        if (attempts == 3)
          throw Exception('$errorMessage: Sem conexão com servidor');
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('$errorMessage: ${e.toString()}');
      }
    }
    throw Exception('$errorMessage após 3 tentativas');
  }

  // ===================================================================
  // ✅ NOVO: Método para buscar unidades e BSSIDs (necessário para parse)
  // ===================================================================
  Future<List<Unit>> fetchUnits() async {
    if (_token == null) throw Exception("Não autenticado");

    final response = await _performHttpRequest(
      request:
          () => http.get(Uri.parse('$_baseUrl/api/units'), headers: _headers),
      errorMessage: 'Erro ao buscar unidades',
    );

    final data = jsonDecode(response.body);
    if (data is Map && data.containsKey('units')) {
      return (data['units'] as List)
          .map((json) => Unit.fromJson(json))
          .toList();
    }
    throw Exception('Resposta inválida: esperado lista de unidades');
  }

  Future<List<BssidMapping>> fetchBssidMappings() async {
    if (_token == null) throw Exception("Não autenticado");

    final response = await _performHttpRequest(
      request:
          () => http.get(
            Uri.parse('$_baseUrl/api/bssid-mappings'),
            headers: _headers,
          ),
      errorMessage: 'Erro ao buscar BSSIDs',
    );

    final data = jsonDecode(response.body);
    if (data is List) {
      return data.map((json) => BssidMapping.fromJson(json)).toList();
    }
    throw Exception('Resposta inválida: esperado lista de BSSIDs');
  }

  // ===================================================================
  // ✅ CRÍTICO: Método de parse de ativos MOVIDO PARA CÁ
  // ===================================================================
  /// Parse de ativos baseado no tipo do módulo
  /// AGORA INCLUI UNITS E BSSIDS COMO PARÂMETROS
  ManagedAsset parseAsset(
    Map<String, dynamic> json,
    AssetModuleType moduleType,
    List<Unit> units,
    List<BssidMapping> bssidMappings,
  ) {
    try {
      switch (moduleType) {
        case AssetModuleType.notebook:
          return Notebook.fromJson(json, units, bssidMappings);

        case AssetModuleType.desktop:
          return Desktop.fromJson(json, units);

        case AssetModuleType.panel:
          return Panel.fromJson(json, units);

        case AssetModuleType.printer:
          return Printer.fromJson(json, units);

        default:
          throw UnimplementedError('Tipo não suportado: $moduleType');
      }
    } catch (e, stackTrace) {
      print('❌ Erro ao parsear ativo: $e');
      print('Stack: $stackTrace');
      print('JSON: $json');
      rethrow;
    }
  }

  // ===================================================================
  // ✅ CORRIGIDO E ATUALIZADO: Lista ativos com PARSE AUTOMÁTICO E LOGS
  // ===================================================================
  /// Lista ativos de um módulo (AGORA COM PARSE)
  Future<List<ManagedAsset>> listModuleAssetsTyped({
    required String moduleId,
    required AssetModuleType moduleType,
    required List<Unit> units,
    required List<BssidMapping> bssidMappings,
  }) async {
    if (_token == null) throw Exception("Não autenticado");

    // ✅ LOGS DE DEBUG
    print('📦 Carregando ativos do módulo: $moduleType');
    print('   Units disponíveis: ${units.length}');
    print('   BSSIDs disponíveis: ${bssidMappings.length}');

    if (bssidMappings.isEmpty) {
      print(
        '⚠️ ATENÇÃO: Nenhum BSSID cadastrado! O mapeamento por WiFi não funcionará.',
      );
    }

    final response = await _performHttpRequest(
      request:
          () => http.get(
            Uri.parse('$_baseUrl/api/modules/$moduleId/assets'),
            headers: _headers,
          ),
      errorMessage: 'Erro ao carregar ativos',
    );

    final data = json.decode(response.body);

    if (data is! Map<String, dynamic>) {
      throw Exception('Resposta inválida: esperado objeto JSON');
    }

    if (!data.containsKey('assets')) {
      throw Exception('Resposta sem campo "assets"');
    }

    final assetsList = data['assets'] as List<dynamic>;

    print('📊 Total de ativos recebidos: ${assetsList.length}');

    // ✅ Parse cada ativo COM LOGS
    return assetsList.map((json) {
      try {
        return parseAsset(
          json as Map<String, dynamic>,
          moduleType,
          units,
          bssidMappings,
        );
      } catch (e, stackTrace) {
        print('❌ ERRO ao parsear ativo: $e');
        print('   JSON problemático: ${json['serial_number']}');
        print('   Stack: $stackTrace');
        rethrow;
      }
    }).toList();
  }

  // ===================================================================
  // MANTIDO: Lista módulos
  // ===================================================================
  Future<List<AssetModuleConfig>> listModules() async {
    if (_token == null) throw Exception("Não autenticado");

    final response = await _performHttpRequest(
      request:
          () => http.get(Uri.parse('$_baseUrl/api/modules'), headers: _headers),
      errorMessage: 'Erro ao carregar módulos',
    );

    final data = json.decode(response.body);
    final List<dynamic> modulesJson = data['modules'];
    return modulesJson.map((json) => AssetModuleConfig.fromJson(json)).toList();
  }

  // ===================================================================
  // MANTIDO: Cria módulo
  // ===================================================================
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
      'table_columns': tableColumns,
    };

    final response = await _performHttpRequest(
      request:
          () => http.post(
            Uri.parse('$_baseUrl/api/modules'),
            headers: _headers,
            body: json.encode(moduleData),
          ),
      errorMessage: 'Erro ao criar módulo',
    );

    final data = json.decode(response.body);
    return AssetModuleConfig.fromJson(data['module']);
  }

  // ===================================================================
  // MANTIDO: Atualiza módulo
  // ===================================================================
  Future<AssetModuleConfig> updateModule({
    required String moduleId,
    String? name,
    String? description,
    bool? isActive,
    Map<String, dynamic>? customFields,
    Map<String, dynamic>? settings,
    List<Map<String, String>>? tableColumns,
    required AssetModuleType type,
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
      request:
          () => http.put(
            Uri.parse('$_baseUrl/api/modules/$moduleId'),
            headers: _headers,
            body: json.encode(updateData),
          ),
      errorMessage: 'Erro ao atualizar módulo',
    );

    final data = json.decode(response.body);
    return AssetModuleConfig.fromJson(data['module']);
  }

  // ===================================================================
  // MANTIDO: Deleta módulo
  // ===================================================================
  Future<bool> deleteModule(String moduleId) async {
    if (_token == null) throw Exception("Não autenticado");

    try {
      await _performHttpRequest(
        request:
            () => http.delete(
              Uri.parse('$_baseUrl/api/modules/$moduleId'),
              headers: _headers,
            ),
        errorMessage: 'Erro ao deletar módulo',
      );
      return true;
    } catch (e) {
      print('Erro ao deletar módulo: $e');
      return false;
    }
  }

  // ===================================================================
  // ⚠️ MANUTENÇÃO (CORRIGIDA) ⚠️
  // ===================================================================
  Future<Map<String, dynamic>> setMaintenanceMode({
    required String moduleId,
    required String assetId,
    required bool maintenanceMode, // <-- Nome do parâmetro do Flutter
    String? reason,
  }) async {
    if (_token == null) throw Exception("Não autenticado");

    // ✅ CORREÇÃO 1: Mapeamento dos nomes de campos
    final body = {
      'maintenance_status': maintenanceMode, // <-- Nome do campo do servidor
      'status':
          maintenanceMode
              ? 'maintenance'
              : 'online', // <-- Atualiza o status principal
      'maintenance_reason': reason ?? '',
      'maintenance_ticket': reason ?? '', // O painel usa a razão como ticket
    };

    final response = await _performHttpRequest(
      request:
          () => http.patch(
            // ✅ CORREÇÃO 2: URL corrigida (removido /maintenance no final)
            Uri.parse('$_baseUrl/api/modules/$moduleId/assets/$assetId'),
            headers: _headers,
            body: jsonEncode(body),
          ),
      errorMessage: 'Erro ao atualizar manutenção',
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ===================================================================
  // PERMISSÕES
  // ===================================================================
  Future<List<String>> getModulePermissions(String moduleId) async {
    if (_token == null) throw Exception("Não autenticado");

    final response = await _performHttpRequest(
      request:
          () => http.get(
            Uri.parse('$_baseUrl/api/modules/$moduleId/permissions'),
            headers: _headers,
          ),
      errorMessage: 'Erro ao buscar permissões',
    );

    final data = jsonDecode(response.body);
    if (data['success'] == true && data['users'] is List) {
      return List<String>.from(data['users']);
    }
    throw Exception(data['message'] ?? 'Resposta inválida');
  }

  Future<void> updateModulePermissions(
    String moduleId,
    List<String> userIds,
  ) async {
    if (_token == null) throw Exception("Não autenticado");

    await _performHttpRequest(
      request:
          () => http.put(
            Uri.parse('$_baseUrl/api/modules/$moduleId/permissions'),
            headers: _headers,
            body: jsonEncode({'userIds': userIds}),
          ),
      errorMessage: 'Erro ao atualizar permissões',
    );
  }

  // ===================================================================
  // CRUD DE ATIVOS
  // ===================================================================
  Future<Map<String, dynamic>> addAssetToModule({
    required String moduleId,
    required Map<String, dynamic> assetData,
  }) async {
    if (_token == null) throw Exception("Não autenticado");

    final response = await _performHttpRequest(
      request:
          () => http.post(
            Uri.parse('$_baseUrl/api/modules/$moduleId/assets'),
            headers: _headers,
            body: json.encode(assetData),
          ),
      errorMessage: 'Erro ao adicionar ativo',
    );

    final data = json.decode(response.body);
    return data['asset'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateAsset({
    required String moduleId,
    required String assetId,
    required Map<String, dynamic> updateData,
  }) async {
    if (_token == null) throw Exception("Não autenticado");

    final response = await _performHttpRequest(
      request:
          () => http.put(
            Uri.parse('$_baseUrl/api/modules/$moduleId/assets/$assetId'),
            headers: _headers,
            body: json.encode(updateData),
          ),
      errorMessage: 'Erro ao atualizar ativo',
    );

    final data = json.decode(response.body);
    return data['asset'] as Map<String, dynamic>;
  }

  Future<bool> deleteAsset({
    required String moduleId,
    required String assetId,
  }) async {
    if (_token == null) throw Exception("Não autenticado");

    try {
      await _performHttpRequest(
        request:
            () => http.delete(
              Uri.parse('$_baseUrl/api/modules/$moduleId/assets/$assetId'),
              headers: _headers,
            ),
        errorMessage: 'Erro ao deletar ativo',
      );
      return true;
    } catch (e) {
      print('Erro ao deletar ativo: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchAssetHistory(
    String token,
    String assetId,
  ) async {
    if (token.isEmpty) throw Exception("Não autenticado");

    final response = await _performHttpRequest(
      request:
          () => http.get(
            // ⚠️ NOTA: Requer a rota GET /:moduleId/assets/:assetId/history no servidor
            Uri.parse(
              '$_baseUrl/api/modules/${assetId.split('_')[0]}/assets/$assetId/history',
            ),
            headers: _headers,
          ),
      errorMessage: 'Erro ao buscar histórico',
    );

    final data = json.decode(response.body);

    if (data['success'] == true && data['history'] is List) {
      return List<Map<String, dynamic>>.from(data['history']);
    }

    throw Exception(data['message'] ?? 'Falha ao carregar histórico');
  }
}
