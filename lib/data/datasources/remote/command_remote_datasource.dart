import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:painel_windowns/core/error/exceptions.dart';

/// Data Source remoto para comandos de dispositivos
abstract class CommandRemoteDataSource {
  Future<void> sendCommand(
    String token,
    String deviceId,
    String command, {
    Map<String, dynamic>? params,
  });
  Future<List<Map<String, dynamic>>> getCommandHistory(
    String token,
    String deviceId,
  );
  Future<Map<String, dynamic>> getCommandStatus(String token, String commandId);
}

class CommandRemoteDataSourceImpl implements CommandRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  CommandRemoteDataSourceImpl({required this.client, required this.baseUrl});

  @override
  Future<void> sendCommand(
    String token,
    String deviceId,
    String command, {
    Map<String, dynamic>? params,
  }) async {
    try {
      final body = {'command': command, if (params != null) 'params': params};

      final response = await client.post(
        Uri.parse('$baseUrl/devices/$deviceId/commands'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 202) {
        return;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
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
          e is NotFoundException)
        rethrow;
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCommandHistory(
    String token,
    String deviceId,
  ) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/devices/$deviceId/commands/history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['commands'] ?? data);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Device not found');
      } else {
        throw ServerException(
          message: 'Failed to get command history: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException ||
          e is UnauthorizedException ||
          e is NotFoundException)
        rethrow;
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getCommandStatus(
    String token,
    String commandId,
  ) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/commands/$commandId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Command not found');
      } else {
        throw ServerException(
          message: 'Failed to get command status: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException ||
          e is UnauthorizedException ||
          e is NotFoundException)
        rethrow;
      throw ServerException(message: 'Network error: $e');
    }
  }
}
