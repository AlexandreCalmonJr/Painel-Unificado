import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:painel_windowns/models/bssid_mapping.dart';
import 'package:painel_windowns/models/ip_mapping.dart';
import 'package:painel_windowns/models/totem.dart';
import 'package:painel_windowns/models/unit.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/device_service.dart';
import 'package:painel_windowns/services/location_mapper_service.dart';
import 'package:painel_windowns/services/server_config_service.dart';

class MonitoringService {
  final AuthService authService;
  final DeviceService _deviceService = DeviceService();
  
  // Cache dos mapeamentos
  List<Unit> _cachedUnits = [];
  List<BssidMapping> _cachedBssidMappings = [];
  DateTime? _lastMappingUpdate;
  
  // Tempo de cache (5 minutos)
  static const Duration _cacheDuration = Duration(minutes: 5);

  MonitoringService({required this.authService});

  /// Carrega ou atualiza os mapeamentos de localização
  Future<void> _loadMappings({bool forceRefresh = false}) async {
    try {
      // Verifica se o cache ainda é válido
      if (!forceRefresh && 
          _lastMappingUpdate != null && 
          DateTime.now().difference(_lastMappingUpdate!) < _cacheDuration) {
        return; // Cache ainda válido
      }

      final token = authService.currentToken;
      if (token == null || token.isEmpty) {
        return; // Sem token, não carrega mapeamentos
      }

      // Carrega units e bssid mappings em paralelo
      final results = await Future.wait([
        _deviceService.fetchUnits(token),
        _deviceService.fetchBssidMappings(token),
      ]);

      _cachedUnits = results[0] as List<Unit>;
      _cachedBssidMappings = results[1] as List<BssidMapping>;
      _lastMappingUpdate = DateTime.now();
    } catch (e) {
      // Em caso de erro, mantém o cache anterior
      print('Aviso: Não foi possível atualizar mapeamentos de localização: $e');
    }
  }

  /// Busca a lista de totems do servidor com localização atualizada
  Future<List<Totem>> getTotems({bool refreshMappings = false}) async {
    try {
      // 1. Carregar mapeamentos
      await _loadMappings(forceRefresh: refreshMappings);

      // 2. Obter o token atual do AuthService
      final token = authService.currentToken;
      if (token == null || token.isEmpty) {
        throw Exception('Token de autenticação não encontrado. Faça o login novamente.');
      }

      // 3. Obter a URL base do servidor
      final config = ServerConfigService.instance.loadConfig();
      final baseUrl = 'http://${config['ip']}:${config['port']}';

      if (config['ip'] == null || config['port'] == null) {
        throw Exception('URL do servidor não configurada.');
      }

      // 4. Fazer a requisição HTTP para o endpoint dos totens
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

      // 5. Tratar a resposta do servidor
      if (response.statusCode == 200) {
        final List<dynamic> totemJson = json.decode(response.body);
        
        // Validar se a resposta não está vazia
        if (totemJson.isEmpty) {
          return [];
        }

        // Converter a lista de JSON para objetos Totem
        List<Totem> totems = totemJson.map((json) => Totem.fromJson(json)).toList();

        // 6. Aplicar mapeamento de localização
        if (_cachedUnits.isNotEmpty || _cachedBssidMappings.isNotEmpty) {
          totems = LocationMapperService.updateTotemsLocation(
            totems: totems,
            units: _cachedUnits,
            bssidMappings: _cachedBssidMappings,
          );
        }

        return totems;
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
  Future<List<Totem>> getDevices({bool refreshMappings = false}) async {
    return getTotems(refreshMappings: refreshMappings);
  }

  /// Força a atualização dos mapeamentos no próximo getTotems()
  void invalidateMappingsCache() {
    _lastMappingUpdate = null;
  }

  /// Retorna os mapeamentos atualmente em cache
  Map<String, dynamic> getCachedMappings() {
    return {
      'units': _cachedUnits,
      'bssidMappings': _cachedBssidMappings,
      'lastUpdate': _lastMappingUpdate,
    };
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

  /// Busca a lista de mapeamentos de IP/localização (LEGADO)
  Future<List<IpMapping>> getMappings() async {
    try {
      final token = authService.currentToken;
      if (token == null || token.isEmpty) {
        throw Exception('Token de autenticação não encontrado.');
      }

      final config = ServerConfigService.instance.loadConfig();
      final baseUrl = 'http://${config['ip']}:${config['port']}';

      final response = await http.get(
        Uri.parse('$baseUrl/api/monitoring/ip-mappings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => IpMapping.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        await authService.logout();
        throw Exception('Sessão expirada. Por favor, faça o login novamente.');
      } else {
        throw Exception('Falha ao carregar mapeamentos: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Erro ao carregar mapeamentos: ${e.toString()}');
    }
  }

  /// Cria um novo mapeamento de localização (LEGADO)
  Future<void> createIpMapping(String location, String ipStart, String ipEnd) async {
    try {
      final token = authService.currentToken;
      if (token == null || token.isEmpty) {
        throw Exception('Token de autenticação não encontrado.');
      }
      
      final config = ServerConfigService.instance.loadConfig();
      final baseUrl = 'http://${config['ip']}:${config['port']}';

      final response = await http.post(
        Uri.parse('$baseUrl/api/monitoring/ip-mappings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({
          'location': location,
          'ipStart': ipStart,
          'ipEnd': ipEnd,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Erro ao criar mapeamento: ${response.statusCode}');
      }
      
      // Invalida o cache para recarregar na próxima vez
      invalidateMappingsCache();
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Erro ao criar mapeamento: ${e.toString()}');
    }
  }

  /// Apaga um mapeamento de localização (LEGADO)
  Future<void> deleteIpMapping(String id) async {
    try {
      final token = authService.currentToken;
      if (token == null || token.isEmpty) {
        throw Exception('Token de autenticação não encontrado.');
      }

      final config = ServerConfigService.instance.loadConfig();
      final baseUrl = 'http://${config['ip']}:${config['port']}';

      final response = await http.delete(
        Uri.parse('$baseUrl/api/monitoring/ip-mappings/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erro ao deletar mapeamento: ${response.statusCode}');
      }
      
      // Invalida o cache para recarregar na próxima vez
      invalidateMappingsCache();
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Erro ao deletar mapeamento: ${e.toString()}');
    }
  }
}