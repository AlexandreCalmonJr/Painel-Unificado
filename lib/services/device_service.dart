import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:painel_windowns/data/models/bssid_mapping.dart';
import 'package:painel_windowns/data/models/device_model.dart';
import 'package:painel_windowns/data/models/totem_model.dart';
import 'package:painel_windowns/data/models/unit_model.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/server_config_service.dart';
import 'package:get/get.dart';

const int kMaxRetries = 3;
const Duration kRetryDelay = Duration(seconds: 2);

class DeviceService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();

  Future<http.Response> _performHttpRequest({
    required Future<http.Response> Function() request,
    required String errorMessage,
  }) async {
    int attempts = 0;
    while (attempts < kMaxRetries) {
      attempts++;
      try {
        final response = await request().timeout(const Duration(seconds: 15));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        } else {
          try {
            final errorData = jsonDecode(response.body);
            throw Exception(
              errorData['error'] ??
                  'Erro ${response.statusCode}: ${response.reasonPhrase}',
            );
          } catch (_) {
            throw Exception(
              'Erro ${response.statusCode}: ${response.reasonPhrase}',
            );
          }
        }
      } on TimeoutException {
        if (attempts == kMaxRetries) {
          throw Exception('$errorMessage: Tempo limite esgotado.');
        }
        await Future.delayed(kRetryDelay);
      } on SocketException {
        if (attempts == kMaxRetries) {
          throw Exception('$errorMessage: Falha na conexão com o servidor.');
        }
        await Future.delayed(kRetryDelay);
      } catch (e) {
        throw Exception(
          '$errorMessage: ${e.toString().replaceFirst("Exception: ", "")}',
        );
      }
    }
    throw Exception('$errorMessage após $kMaxRetries tentativas.');
  }

  // Busca dispositivos com paginação e filtros
  Future<Map<String, dynamic>> fetchDevices(
    String token,
    List<Unit> units, {
    int page = 1,
    int limit = 50,
    String? search,
    String? status,
    String? type,
  }) async {
    final config = ServerConfigService.instance.loadConfig();
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (type != null && type.isNotEmpty) queryParams['type'] = type;

    final uri = Uri.http(
      '${config['ip']}:${config['port']}',
      '/api/devices',
      queryParams,
    );

    try {
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer ${_authService.currentToken}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> devicesJson = data['devices'] as List<dynamic>;

        // Note: Device.fromJson might need units/bssids if it does complex mapping inside.
        // For now, assuming simple mapping or that we fetch dependencies if needed.
        // If Device.fromJson requires units/bssids, we should fetch them first or adjust the model.
        // Based on previous code, it seemed to require them. Let's check if we can simplify or if we need to fetch them.
        // Ideally, the backend should return mapped data.
        // For this implementation, I will assume simple parsing or that we pass empty lists if not critical for the list view.
        final devices =
            devicesJson.map((json) => Device.fromJson(json, [])).toList();

        return {
          'devices': devices,
          'total': data['total'],
          'page': data['page'],
          'totalPages': data['totalPages'],
        };
      } else {
        throw Exception('Falha ao carregar dispositivos');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<List<BssidMapping>> fetchBssidMappings(String token) async {
    final config = ServerConfigService.instance.loadConfig();
    final serverIp = config['ip'];
    final serverPort = config['port'];

    final response = await _performHttpRequest(
      request:
          () => http.get(
            Uri.parse('http://$serverIp:$serverPort/api/bssid-mappings'),
            headers: {'Authorization': 'Bearer $token'},
          ),
      errorMessage: 'Erro ao buscar mapeamentos de BSSID',
    );
    final data = jsonDecode(response.body);
    if (data is List) {
      return data
          .map((json) => BssidMapping.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Resposta inválida: Esperado uma lista de mapeamentos');
  }

  Future<List<BssidMapping>> fetchBssidsForUnit(
    String token,
    String unitName,
  ) async {
    final config = ServerConfigService.instance.loadConfig();
    final serverIp = config['ip'];
    final serverPort = config['port'];

    final encodedUnitName = Uri.encodeComponent(unitName);

    final response = await _performHttpRequest(
      request:
          () => http.get(
            Uri.parse(
              'http://$serverIp:$serverPort/api/bssid-mappings/by-unit/$encodedUnitName',
            ),
            headers: {'Authorization': 'Bearer $token'},
          ),
      errorMessage: 'Erro ao buscar BSSIDs para a unidade $unitName',
    );

    final data = jsonDecode(response.body);
    if (data is List) {
      return data
          .map((json) => BssidMapping.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      if (data is Map<String, dynamic> && data.containsKey('error')) {
        throw Exception(data['error']);
      }
      throw Exception('Resposta inválida: Esperado uma lista de BSSIDs');
    }
  }

  Future<String> sendCommand(
    String token,
    String serialNumber,
    String command,
    Map<String, dynamic> parameters,
  ) async {
    final config = ServerConfigService.instance.loadConfig();
    final serverIp = config['ip'];
    final serverPort = config['port'];

    final body = {
      'serial_number': serialNumber,
      'command': command,
      ...parameters,
    };

    final response = await _performHttpRequest(
      request:
          () => http.post(
            Uri.parse(
              'http://$serverIp:$serverPort/api/devices/executeCommand',
            ),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          ),
      errorMessage: 'Erro ao enviar comando',
    );

    final data = jsonDecode(response.body);
    return data['message']?.toString() ?? 'Comando executado com sucesso';
  }

  Future<String> deleteDevice(String token, String serialNumber) async {
    final config = ServerConfigService.instance.loadConfig();
    final serverIp = config['ip'];
    final serverPort = config['port'];

    final response = await _performHttpRequest(
      request:
          () => http.delete(
            Uri.parse('http://$serverIp:$serverPort/api/devices/$serialNumber'),
            headers: {'Authorization': 'Bearer $token'},
          ),
      errorMessage: 'Erro ao excluir dispositivo',
    );
    final data = jsonDecode(response.body);
    return data['message']?.toString() ?? 'Dispositivo excluído com sucesso';
  }

  Future<String> createUnit(String token, Unit unit) async {
    final config = ServerConfigService.instance.loadConfig();
    final serverIp = config['ip'];
    final serverPort = config['port'];
    await _performHttpRequest(
      request:
          () => http.post(
            Uri.parse('http://$serverIp:$serverPort/api/units'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(unit.toJson()),
          ),
      errorMessage: 'Erro ao criar unidade',
    );
    return 'Unidade criada com sucesso';
  }

  Future<String> updateUnit(String token, String unitName, Unit unit) async {
    final config = ServerConfigService.instance.loadConfig();
    final serverIp = config['ip'];
    final serverPort = config['port'];
    await _performHttpRequest(
      request:
          () => http.put(
            Uri.parse('http://$serverIp:$serverPort/api/units/$unitName'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(unit.toJson()),
          ),
      errorMessage: 'Erro ao atualizar unidade',
    );
    return 'Unidade atualizada com sucesso';
  }

  Future<String> deleteUnit(String token, String unitName) async {
    final config = ServerConfigService.instance.loadConfig();
    final serverIp = config['ip'];
    final serverPort = config['port'];
    final response = await _performHttpRequest(
      request:
          () => http.delete(
            Uri.parse('http://$serverIp:$serverPort/api/units/$unitName'),
            headers: {'Authorization': 'Bearer $token'},
          ),
      errorMessage: 'Erro ao excluir unidade',
    );
    final data = jsonDecode(response.body);
    return data['message']?.toString() ?? 'Unidade excluída com sucesso';
  }

  Future<String> createBssidMapping(String token, BssidMapping mapping) async {
    final config = ServerConfigService.instance.loadConfig();
    final serverIp = config['ip'];
    final serverPort = config['port'];
    await _performHttpRequest(
      request:
          () => http.post(
            Uri.parse('http://$serverIp:$serverPort/api/bssid-mappings'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(mapping.toJson()),
          ),
      errorMessage: 'Erro ao criar mapeamento',
    );
    return 'Mapeamento de BSSID criado com sucesso';
  }

  Future<String> updateBssidMapping(
    String token,
    String macAddressRadio,
    BssidMapping mapping,
  ) async {
    final config = ServerConfigService.instance.loadConfig();
    final serverIp = config['ip'];
    final serverPort = config['port'];
    await _performHttpRequest(
      request:
          () => http.put(
            Uri.parse(
              'http://$serverIp:$serverPort/api/bssid-mappings/$macAddressRadio',
            ),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(mapping.toJson()),
          ),
      errorMessage: 'Erro ao atualizar mapeamento',
    );
    return 'Mapeamento de BSSID atualizado com sucesso';
  }

  Future<String> deleteBssidMapping(
    String token,
    String macAddressRadio,
  ) async {
    final config = ServerConfigService.instance.loadConfig();
    final serverIp = config['ip'];
    final serverPort = config['port'];
    await _performHttpRequest(
      request:
          () => http.delete(
            Uri.parse(
              'http://$serverIp:$serverPort/api/bssid-mappings/$macAddressRadio',
            ),
            headers: {'Authorization': 'Bearer $token'},
          ),
      errorMessage: 'Erro ao excluir mapeamento',
    );
    return 'Mapeamento de BSSID excluído com sucesso';
  }

  Future<List<Unit>> fetchUnits(String token) async {
    final config = ServerConfigService.instance.loadConfig();
    final serverIp = config['ip'];
    final serverPort = config['port'];

    final response = await _performHttpRequest(
      request:
          () => http.get(
            Uri.parse('http://$serverIp:$serverPort/api/units'),
            headers: {'Authorization': 'Bearer $token'},
          ),
      errorMessage: 'Erro ao buscar unidades',
    );

    final data = jsonDecode(response.body);

    if (data is Map<String, dynamic> &&
        data['success'] == true &&
        data['units'] is List) {
      return (data['units'] as List)
          .map((json) => Unit.fromJson(json as Map<String, dynamic>))
          .toList();
    } else if (data is List) {
      return data
          .map((json) => Unit.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Resposta inválida do servidor: Esperado "success: true" e uma lista de "units".',
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchLocationHistory(
    String token,
    String serialNumber,
  ) async {
    final config = ServerConfigService.instance.loadConfig();
    final serverIp = config['ip'];
    final serverPort = config['port'];

    final response = await _performHttpRequest(
      request:
          () => http.get(
            Uri.parse(
              'http://$serverIp:$serverPort/api/devices/$serialNumber/location-history',
            ),
            headers: {'Authorization': 'Bearer $token'},
          ),
      errorMessage: 'Erro ao buscar histórico de localização',
    );

    final data = jsonDecode(response.body);
    if (data['success'] == true && data['history'] is List) {
      return List<Map<String, dynamic>>.from(data['history'] as List);
    } else {
      throw Exception(
        data['message'] ?? 'Falha ao carregar histórico de localização',
      );
    }
  }

  Future<List<Totem>> fetchTotems(String token) async {
    final config = ServerConfigService.instance.loadConfig();
    final serverIp = config['ip'];
    final serverPort = config['port'];

    final units = await fetchUnits(token);
    final bssidMappings = await fetchBssidMappings(token);

    final response = await _performHttpRequest(
      request:
          () => http.get(
            Uri.parse('http://$serverIp:$serverPort/api/monitoring/totems'),
            headers: {'Authorization': 'Bearer $token'},
          ),
      errorMessage: 'Erro ao buscar totens',
    );
    final data = jsonDecode(response.body);
    if (data is List) {
      return data
          .map(
            (json) => Totem.fromJson(
              json as Map<String, dynamic>,
              units,
              bssidMappings,
            ),
          )
          .toList();
    } else if (data is Map<String, dynamic> && data.containsKey('totems')) {
      return (data['totems'] as List)
          .map(
            (json) => Totem.fromJson(
              json as Map<String, dynamic>,
              units,
              bssidMappings,
            ),
          )
          .toList();
    }
    throw Exception(
      'Resposta inválida do servidor: Esperado uma lista de totens.',
    );
  }

  // Atualizar Totem
  Future<void> updateTotem(
    String serialNumber,
    Map<String, dynamic> data,
  ) async {
    final config = ServerConfigService.instance.loadConfig();
    try {
      final response = await http.put(
        Uri.parse(
          'http://${config['ip']}:${config['port']}/api/totems/$serialNumber',
        ),
        headers: {
          'Authorization': 'Bearer ${_authService.currentToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao atualizar totem');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar totem: $e');
    }
  }

  // Excluir Totem
  Future<void> deleteTotem(String serialNumber) async {
    final config = ServerConfigService.instance.loadConfig();
    try {
      final response = await http.delete(
        Uri.parse(
          'http://${config['ip']}:${config['port']}/api/totems/$serialNumber',
        ),
        headers: {'Authorization': 'Bearer ${_authService.currentToken}'},
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao excluir totem');
      }
    } catch (e) {
      throw Exception('Erro ao excluir totem: $e');
    }
  }

  // Resumo de Localização
  Future<Map<String, dynamic>> fetchLocationSummary() async {
    final config = ServerConfigService.instance.loadConfig();
    try {
      final response = await http.get(
        Uri.parse(
          'http://${config['ip']}:${config['port']}/api/devices/locations/summary',
        ),
        headers: {'Authorization': 'Bearer ${_authService.currentToken}'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Falha ao carregar resumo de localização');
      }
    } catch (e) {
      throw Exception('Erro ao carregar resumo: $e');
    }
  }
}
