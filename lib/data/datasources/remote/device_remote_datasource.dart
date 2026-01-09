import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:painel_windowns/core/error/exceptions.dart';
import 'package:painel_windowns/data/models/device_model.dart';

/// Data Source remoto para dispositivos
///
/// Responsável por fazer chamadas HTTP para a API de dispositivos
abstract class DeviceRemoteDataSource {
  /// Busca todos os dispositivos da API
  Future<List<Device>> getDevices(String token);

  /// Busca um dispositivo específico por ID
  Future<Device> getDeviceById(String token, String deviceId);

  /// Envia um comando para um dispositivo
  Future<void> sendCommand(String token, String deviceId, String command);

  /// Atualiza informações de um dispositivo
  Future<void> updateDevice(String token, Device device);
}

class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  DeviceRemoteDataSourceImpl({required this.client, required this.baseUrl});

  @override
  Future<List<Device>> getDevices(String token) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/devices'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonList = json.decode(response.body) as List<dynamic>;
        // Nota: Device.fromJson precisa de units, por enquanto passamos lista vazia
        return jsonList
            .map((json) => Device.fromJson(json as Map<String, dynamic>, []))
            .toList();
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else {
        throw ServerException(
          message: 'Failed to load devices: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<Device> getDeviceById(String token, String deviceId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/devices/$deviceId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return Device.fromJson(jsonData, []);
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Device not found');
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else {
        throw ServerException(
          message: 'Failed to load device: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException ||
          e is UnauthorizedException ||
          e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<void> sendCommand(
    String token,
    String deviceId,
    String command,
  ) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/devices/$deviceId/command'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'command': command}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Device not found');
      } else {
        throw ServerException(
          message: 'Failed to send command: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException ||
          e is UnauthorizedException ||
          e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<void> updateDevice(String token, Device device) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/devices/${device.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'device_name': device.deviceName,
          'status': device.status,
          'location': device.location,
          'sector': device.sector,
          'floor': device.floor,
          'unit': device.unit,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Device not found');
      } else {
        throw ServerException(
          message: 'Failed to update device: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException ||
          e is UnauthorizedException ||
          e is NotFoundException) {
        rethrow;
      }
      throw ServerException(message: 'Network error: $e');
    }
  }
}
