// File: lib/services/location_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:painel_windowns/data/models/location.dart';
import 'package:painel_windowns/services/server_config_service.dart';

class LocationService {
  static Future<List<Location>> fetchLocations(String token) async {
    try {
      final config = ServerConfigService.instance.loadConfig();
      final serverIp = config['ip'];
      final serverPort = config['port'];

      final response = await http.get(
        Uri.parse('http://$serverIp:$serverPort/api/units'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final dynamic decodedBody = json.decode(response.body);

        // Handle different API response formats
        List<dynamic> data;
        if (decodedBody is List) {
          // Direct array response
          data = decodedBody;
        } else if (decodedBody is Map<String, dynamic>) {
          // Object response with 'units' key
          if (decodedBody.containsKey('units')) {
            data = decodedBody['units'] as List<dynamic>;
          } else if (decodedBody.containsKey('data')) {
            data = decodedBody['data'] as List<dynamic>;
          } else {
            // If it's a single object, wrap it in a list
            data = [decodedBody];
          }
        } else {
          throw Exception('Formato de resposta inesperado da API');
        }

        return data
            .map((json) => Location.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Falha ao carregar localiza��es: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erro ao buscar localiza��es: $e');
    }
  }

  static Future<Location> createLocation(
    String token,
    Map<String, dynamic> locationData,
  ) async {
    try {
      final config = ServerConfigService.instance.loadConfig();
      final serverIp = config['ip'];
      final serverPort = config['port'];

      final response = await http.post(
        Uri.parse('http://$serverIp:$serverPort/api/units'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(locationData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Location.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw Exception('Falha ao criar localiza��o: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao criar localiza��o: $e');
    }
  }

  static Future<Location> updateLocation(
    String token,
    String locationName,
    Map<String, dynamic> locationData,
  ) async {
    try {
      final config = ServerConfigService.instance.loadConfig();
      final serverIp = config['ip'];
      final serverPort = config['port'];

      final response = await http.put(
        Uri.parse('http://$serverIp:$serverPort/api/units/$locationName'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(locationData),
      );

      if (response.statusCode == 200) {
        return Location.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw Exception(
          'Falha ao atualizar localiza��o: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erro ao atualizar localiza��o: $e');
    }
  }

  static Future<void> deleteLocation(String token, String locationName) async {
    try {
      final config = ServerConfigService.instance.loadConfig();
      final serverIp = config['ip'];
      final serverPort = config['port'];

      final response = await http.delete(
        Uri.parse('http://$serverIp:$serverPort/api/units/$locationName'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Falha ao excluir localiza��o: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao excluir localiza��o: $e');
    }
  }

  static Future<Map<String, int>> getLocationStats(String token) async {
    try {
      final locations = await fetchLocations(token);
      final totalLocations = locations.length;
      final onlineLocations = locations.where((l) => l.isOnline).length;
      final totalDevices = locations.fold(0, (sum, l) => sum + l.deviceCount);

      return {
        'total': totalLocations,
        'online': onlineLocations,
        'devices': totalDevices,
      };
    } catch (e) {
      return {'total': 0, 'online': 0, 'devices': 0};
    }
  }

  /// Busca localiza��es e enriquece com dados de dispositivos
  static Future<List<Location>> fetchLocationsWithDeviceData(
    String token,
  ) async {
    try {
      // Busca as localiza��es
      final locations = await fetchLocations(token);

      // Busca os dispositivos
      final config = ServerConfigService.instance.loadConfig();
      final serverIp = config['ip'];
      final serverPort = config['port'];

      final devicesResponse = await http.get(
        Uri.parse('http://$serverIp:$serverPort/api/devices'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (devicesResponse.statusCode == 200) {
        final devicesData = json.decode(devicesResponse.body);
        List<dynamic> devicesList = [];

        if (devicesData is Map<String, dynamic> &&
            devicesData.containsKey('devices')) {
          devicesList = devicesData['devices'] as List;
        } else if (devicesData is List) {
          devicesList = devicesData;
        }

        // Conta dispositivos por unidade
        final Map<String, int> deviceCountByUnit = {};
        final Map<String, bool> onlineStatusByUnit = {};

        for (final device in devicesList) {
          final String? unitName = (device['unit_name'] as String?) ?? (device['unitName'] as String?);
          final bool isOnline =
              (device['is_online'] as bool?) ?? (device['isOnline'] as bool?) ?? false;

          if (unitName != null) {
            deviceCountByUnit[unitName] =
                (deviceCountByUnit[unitName] ?? 0) + 1;
            // Se pelo menos um dispositivo est� online, a unidade est� online
            onlineStatusByUnit[unitName] =
                (onlineStatusByUnit[unitName] ?? false) || isOnline;
          }
        }

        // Enriquece as localiza��es com os dados
        return locations.map((location) {
          final count = deviceCountByUnit[location.name] ?? 0;
          final isOnline = onlineStatusByUnit[location.name] ?? false;

          return location.copyWith(deviceCount: count, isOnline: isOnline);
        }).toList();
      }

      // Se falhar ao buscar dispositivos, retorna localiza��es sem enriquecimento
      return locations;
    } catch (e) {
      throw Exception(
        'Erro ao buscar localiza��es com dados de dispositivos: $e',
      );
    }
  }
}
