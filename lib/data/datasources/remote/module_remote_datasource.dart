import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:painel_windowns/core/error/exceptions.dart';

/// Data Source remoto para módulos/ativos
abstract class ModuleRemoteDataSource {
  Future<List<Map<String, dynamic>>> getModulesByType(
    String token,
    String type,
  );
  Future<Map<String, dynamic>> getModuleById(String token, String moduleId);
  Future<void> sendCommand(String token, String moduleId, String command);
  Future<void> updateModule(
    String token,
    String moduleId,
    Map<String, dynamic> module,
  );
}

class ModuleRemoteDataSourceImpl implements ModuleRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  ModuleRemoteDataSourceImpl({required this.client, required this.baseUrl});

  @override
  Future<List<Map<String, dynamic>>> getModulesByType(
    String token,
    String type,
  ) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/modules?type=$type'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['modules'] ?? data);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw ServerException(
          message: 'Failed to load modules: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getModuleById(
    String token,
    String moduleId,
  ) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/modules/$moduleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Module not found');
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw ServerException(
          message: 'Failed to load module: ${response.statusCode}',
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
  Future<void> sendCommand(
    String token,
    String moduleId,
    String command,
  ) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/modules/$moduleId/command'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'command': command}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Module not found');
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
  Future<void> updateModule(
    String token,
    String moduleId,
    Map<String, dynamic> module,
  ) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/modules/$moduleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(module),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Module not found');
      } else {
        throw ServerException(
          message: 'Failed to update module: ${response.statusCode}',
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
