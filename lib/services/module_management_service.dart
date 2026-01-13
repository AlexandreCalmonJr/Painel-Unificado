import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:painel_windowns/data/models/asset_module_base_model.dart';
import 'package:painel_windowns/data/models/bssid_mapping.dart';
import 'package:painel_windowns/data/models/unit_model.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/location_mapper_service.dart';
import 'package:painel_windowns/services/server_config_service.dart';

class ModuleManagementService {
  ModuleManagementService({required this.authService});
  final AuthService authService;

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
  // CORREÇÃO: Método com retries e validação
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
        );

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
        if (attempts == 3) {
          throw Exception('$errorMessage: Tempo esgotado (30s)');
        }
        await Future.delayed(const Duration(seconds: 2));
      } on SocketException {
        if (attempts == 3) {
          throw Exception('$errorMessage: Sem conexão com servidor');
        }
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('$errorMessage: ${e.toString()}');
      }
    }
    throw Exception('$errorMessage após 3 tentativas');
  }

  // ===================================================================
  // Método para buscar unidades e BSSIDs (necessário para parse)
  // ===================================================================
  Future<List<Unit>> fetchUnits() async {
    if (_token == null) throw Exception('Não autenticado');

    final response = await _performHttpRequest(
      request: () =>
          http.get(Uri.parse('$_baseUrl/api/units'), headers: _headers),
      errorMessage: 'Erro ao buscar unidades',
    );

    final data = jsonDecode(response.body);
    if (data is Map && data.containsKey('units')) {
      return (data['units'] as List)
          .map((json) => Unit.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Resposta inválida: esperado lista de unidades');
  }

  Future<List<BssidMapping>> fetchBssidMappings() async {
    if (_token == null) throw Exception('Não autenticado');

    final response = await _performHttpRequest(
      request: () => http.get(
        Uri.parse('$_baseUrl/api/bssid-mappings'),
        headers: _headers,
      ),
      errorMessage: 'Erro ao buscar BSSIDs',
    );

    final data = jsonDecode(response.body);
    if (data is List) {
      return data
          .map((json) => BssidMapping.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Resposta inválida: esperado lista de BSSIDs');
  }

  // ===================================================================
  // CRÍTICO: Método de parse de ativos centralizado
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
      final id = (json['_id'] ?? json['id']) as String;
      final assetName =
          (json['asset_name'] ?? json['hostname'] ?? 'N/A') as String;
      final serialNumber = (json['serial_number'] ?? 'N/A') as String;
      final status = (json['status'] ?? 'offline') as String;
      DateTime lastSeen;
      try {
        lastSeen = DateTime.parse(json['last_seen'] as String);
      } catch (_) {
        lastSeen = DateTime.now();
      }

      String? unit = json['unit'] as String?;
      String? sector = json['sector'] as String?;
      String? floor = json['floor'] as String?;
      String? location = json['location'] as String?;

      final macAddressRadio =
          (json['mac_address_radio'] ?? json['bssid'] ?? '') as String;
      final shouldMap =
          (unit == null || unit == 'N/A' || unit == 'Desconhecido') ||
              (sector == null || sector == 'Desconhecido') ||
              (floor == null || floor == 'Desconhecido');

      if (shouldMap) {
        try {
          final locationData = LocationMapperService.mapLocation(
            units: units,
            bssidMappings: bssidMappings,
            ip: (json['ip_address'] ?? 'N/A') as String,
            macAddress: macAddressRadio,
            originalLocation: location ?? 'N/D',
          );

          unit ??= locationData.unitName;
          sector ??= locationData.sector;
          floor ??= locationData.floor;
          location ??= locationData.locationName;
        } catch (e) {
          print('Falha no mapeamento de localização: $e');
        }
      }

      return _ServiceManagedAsset(
        id: id,
        assetName: assetName,
        assetType: moduleType.identifier,
        serialNumber: serialNumber,
        status: status,
        lastSeen: lastSeen,
        customData:
            json['custom_data'] != null
                ? Map<String, dynamic>.from(json['custom_data'] as Map)
                : json,
        location: location,
        assignedTo: json['assigned_to'] as String?,
        unit: unit,
        sector: sector,
        floor: floor,
      );
    } catch (e, stackTrace) {
      print('Erro ao parsear ativo: $e');
      print('Stack: $stackTrace');
      print('JSON: $json');
      rethrow;
    }
  }

  // ===================================================================
  // CORRIGIDO: Lista ativos com PARSE AUTOMÁTICO
  // ===================================================================
  /// Lista ativos de um módulo (AGORA COM PARSE)
  Future<List<ManagedAsset>> listModuleAssetsTyped({
    required String moduleId,
    required AssetModuleType moduleType,
    required List<Unit> units,
    required List<BssidMapping> bssidMappings,
  }) async {
    if (_token == null) throw Exception('Não autenticado');

    print('📦 Carregando ativos do módulo: $moduleType');
    print('   Units disponíveis: ${units.length}');
    print('   BSSIDs disponíveis: ${bssidMappings.length}');

    if (bssidMappings.isEmpty) {
      print(
        '⚠️ ATENÇÃO: Nenhum BSSID cadastrado! O mapeamento por WiFi não funcionará.',
      );
    }

    final response = await _performHttpRequest(
      request: () => http.get(
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
  // Lista módulos
  // ===================================================================
  Future<List<AssetModuleConfig>> listModules() async {
    if (_token == null) throw Exception('Não autenticado');

    final response = await _performHttpRequest(
      request: () =>
          http.get(Uri.parse('$_baseUrl/api/modules'), headers: _headers),
      errorMessage: 'Erro ao carregar módulos',
    );

    final data = json.decode(response.body);
    final List<dynamic> modulesJson = (data['modules'] as List);
    return modulesJson
        .map((json) => AssetModuleConfig.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ===================================================================
  // Cria módulo
  // ===================================================================
  Future<AssetModuleConfig> createModule({
    required String name,
    required String description,
    required AssetModuleType type,
    required List<Map<String, String>> tableColumns,
    Map<String, dynamic> customFields = const {},
    Map<String, dynamic> settings = const {},
  }) async {
    if (_token == null) throw Exception('Não autenticado');

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
      request: () => http.post(
        Uri.parse('$_baseUrl/api/modules'),
        headers: _headers,
        body: json.encode(moduleData),
      ),
      errorMessage: 'Erro ao criar módulo',
    );

    final data = json.decode(response.body);
    return AssetModuleConfig.fromJson(data['module'] as Map<String, dynamic>);
  }

  // ===================================================================
  // Atualiza módulo
  // ===================================================================
  Future<AssetModuleConfig> updateModule({
    required String moduleId,
    required AssetModuleType type,
    String? name,
    String? description,
    bool? isActive,
    Map<String, dynamic>? customFields,
    Map<String, dynamic>? settings,
    List<Map<String, String>>? tableColumns,
  }) async {
    if (_token == null) throw Exception('Não autenticado');

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
    return AssetModuleConfig.fromJson(data['module'] as Map<String, dynamic>);
  }

  // ===================================================================
  // Deleta módulo
  // ===================================================================
  Future<bool> deleteModule(String moduleId) async {
    if (_token == null) throw Exception('Não autenticado');

    try {
      await _performHttpRequest(
        request: () => http.delete(
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
  // CORREÇÃO: Manutenção (status correto ao sair)
  // ===================================================================
  Future<Map<String, dynamic>> setMaintenanceMode({
    required String moduleId,
    required String assetId,
    required bool maintenanceMode,
    String? reason,
  }) async {
    if (_token == null) throw Exception('Não autenticado');

    // Monta o body base
    final body = <String, dynamic>{
      'maintenance_status': maintenanceMode,
      'maintenance_reason': reason ?? '',
      'maintenance_ticket': reason ?? '',
    };

    // Só força status 'maintenance' ao entrar em manutenção
    // Ao sair, deixa o agente atualizar o status real (online/offline)
    if (maintenanceMode) {
      body['status'] = 'maintenance';
    }

    final response = await _performHttpRequest(
      request: () => http.patch(
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
    if (_token == null) throw Exception('Não autenticado');

    final response = await _performHttpRequest(
      request: () => http.get(
        Uri.parse('$_baseUrl/api/modules/$moduleId/permissions'),
        headers: _headers,
      ),
      errorMessage: 'Erro ao buscar permissões',
    );

    final data = jsonDecode(response.body);
    if (data['success'] == true && data['users'] is List) {
      return List<String>.from(data['users'] as List);
    }
    throw Exception(data['message'] ?? 'Resposta inválida');
  }

  Future<void> updateModulePermissions(
    String moduleId,
    List<String> userIds,
  ) async {
    if (_token == null) throw Exception('Não autenticado');

    await _performHttpRequest(
      request: () => http.put(
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
    if (_token == null) throw Exception('Não autenticado');

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

  Future<Map<String, dynamic>> updateAsset({
    required String moduleId,
    required String assetId,
    required Map<String, dynamic> updateData,
  }) async {
    if (_token == null) throw Exception('Não autenticado');

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

  Future<bool> deleteAsset({
    required String moduleId,
    required String assetId,
  }) async {
    if (_token == null) throw Exception('Não autenticado');

    try {
      await _performHttpRequest(
        request: () => http.delete(
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
    if (token.isEmpty) throw Exception('Não autenticado');

    final response = await _performHttpRequest(
      request: () => http.get(
        Uri.parse(
          '$_baseUrl/api/modules/${assetId.split('_')[0]}/assets/$assetId/history',
        ),
        headers: _headers,
      ),
      errorMessage: 'Erro ao buscar histórico',
    );

    final data = json.decode(response.body);

    if (data['success'] == true && data['history'] is List) {
      return List<Map<String, dynamic>>.from(data['history'] as List);
    }

    throw Exception(data['message'] ?? 'Falha ao carregar histórico');
  }
}

// Implementação simples de ManagedAsset usada pelo service
class _ServiceManagedAsset extends ManagedAsset {
  _ServiceManagedAsset({
    required String id,
    required String assetName,
    required String assetType,
    required String serialNumber,
    required String status,
    required DateTime lastSeen,
    Map<String, dynamic> customData = const {},
    String? location,
    String? assignedTo,
    String? unit,
    String? sector,
    String? floor,
  })  : _custom = customData,
        super(
          id: id,
          assetName: assetName,
          assetType: assetType,
          serialNumber: serialNumber,
          status: status,
          lastSeen: lastSeen,
          customData: customData,
          location: location,
          assignedTo: assignedTo,
          unit: unit,
          sector: sector,
          floor: floor,
        );

  final Map<String, dynamic> _custom;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'asset_name': assetName,
      'asset_type': assetType,
      'serial_number': serialNumber,
      'status': status,
      'last_seen': lastSeen.toIso8601String(),
      'location': location,
      'assigned_to': assignedTo,
      'unit': unit,
      'sector': sector,
      'floor': floor,
      'custom_data': _custom,
    };
  }
}