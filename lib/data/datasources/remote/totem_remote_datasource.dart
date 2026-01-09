import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:painel_windowns/core/error/exceptions.dart';
import 'package:painel_windowns/data/models/totem_model.dart';

/// Data Source remoto para totems
abstract class TotemRemoteDataSource {
  Future<List<Totem>> getTotems(String token);
  Future<Totem> getTotemById(String token, String totemId);
  Future<void> sendCommand(String token, String totemId, String command);
  Future<void> updateTotem(String token, Totem totem);
}

class TotemRemoteDataSourceImpl implements TotemRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  TotemRemoteDataSourceImpl({required this.client, required this.baseUrl});

  @override
  Future<List<Totem>> getTotems(String token) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/totems'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final jsonList = (data['totems'] ?? data) as List<dynamic>;
        return jsonList
            .map((json) => Totem.fromJson(json as Map<String, dynamic>, [], []))
            .toList();
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else {
        throw ServerException(
          message: 'Failed to load totems: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<Totem> getTotemById(String token, String totemId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/totems/$totemId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return Totem.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
          [],
          [],
        );
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Totem not found');
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else {
        throw ServerException(
          message: 'Failed to load totem: ${response.statusCode}',
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
  Future<void> sendCommand(String token, String totemId, String command) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/totems/$totemId/command'),
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
        throw NotFoundException(message: 'Totem not found');
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
  Future<void> updateTotem(String token, Totem totem) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/totems/${totem.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'hostname': totem.hostname,
          'status': totem.status,
          'location': totem.location,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Totem not found');
      } else {
        throw ServerException(
          message: 'Failed to update totem: ${response.statusCode}',
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
