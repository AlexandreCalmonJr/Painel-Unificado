import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:painel_windowns/core/error/exceptions.dart';

/// Data Source remoto para logs do sistema
abstract class LoggerRemoteDataSource {
  Future<void> sendLog(String token, Map<String, dynamic> logData);
  Future<List<Map<String, dynamic>>> getLogs(
    String token, {
    String? level,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<void> clearLogs(String token);
}

class LoggerRemoteDataSourceImpl implements LoggerRemoteDataSource {

  LoggerRemoteDataSourceImpl({required this.client, required this.baseUrl});
  final http.Client client;
  final String baseUrl;

  @override
  Future<void> sendLog(String token, Map<String, dynamic> logData) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/logs'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(logData),
      );

      if (response.statusCode == 201 ||
          response.statusCode == 200 ||
          response.statusCode == 202) {
        return;
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else {
        throw ServerException(
          message: 'Failed to send log: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      // Don't throw on log failures to avoid cascading errors
      print('Warning: Failed to send log: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getLogs(
    String token, {
    String? level,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/logs');

      final queryParams = <String, String>{};
      if (level != null) queryParams['level'] = level;
      if (startDate != null) queryParams['start'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end'] = endDate.toIso8601String();

      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from((data['logs'] ?? data) as List);
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else {
        throw ServerException(
          message: 'Failed to get logs: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<void> clearLogs(String token) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/logs'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else {
        throw ServerException(
          message: 'Failed to clear logs: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Network error: $e');
    }
  }
}
