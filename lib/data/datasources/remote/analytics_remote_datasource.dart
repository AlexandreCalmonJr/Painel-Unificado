import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:painel_windowns/core/error/exceptions.dart';

/// Data Source remoto para analytics e métricas
abstract class AnalyticsRemoteDataSource {
  Future<Map<String, dynamic>> getDashboardMetrics(String token);
  Future<Map<String, dynamic>> getDeviceMetrics(String token, String deviceId);
  Future<List<Map<String, dynamic>>> getUsageStatistics(
    String token, {
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Map<String, dynamic>> getSystemHealth(String token);
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {

  AnalyticsRemoteDataSourceImpl({required this.client, required this.baseUrl});
  final http.Client client;
  final String baseUrl;

  @override
  Future<Map<String, dynamic>> getDashboardMetrics(String token) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/analytics/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else {
        throw ServerException(
          message: 'Failed to get dashboard metrics: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getDeviceMetrics(
    String token,
    String deviceId,
  ) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/analytics/devices/$deviceId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else if (response.statusCode == 404) {
        throw const NotFoundException(message: 'Device not found');
      } else {
        throw ServerException(
          message: 'Failed to get device metrics: ${response.statusCode}',
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
  Future<List<Map<String, dynamic>>> getUsageStatistics(
    String token, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/analytics/usage');

      if (startDate != null || endDate != null) {
        final queryParams = <String, String>{};
        if (startDate != null) {
          queryParams['start'] = startDate.toIso8601String();
        }
        if (endDate != null) queryParams['end'] = endDate.toIso8601String();
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
        return List<Map<String, dynamic>>.from((data['statistics'] ?? data) as List);
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else {
        throw ServerException(
          message: 'Failed to get usage statistics: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getSystemHealth(String token) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/analytics/health'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else {
        throw ServerException(
          message: 'Failed to get system health: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Network error: $e');
    }
  }
}
