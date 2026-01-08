import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:painel_windowns/core/error/exceptions.dart';

/// Data Source remoto para relatórios
abstract class ReportRemoteDataSource {
  Future<Map<String, dynamic>> generateDeviceReport(
    String token, {
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Map<String, dynamic>> generateMaintenanceReport(
    String token, {
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Map<String, dynamic>> generateUsageReport(
    String token, {
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<List<Map<String, dynamic>>> getAvailableReports(String token);
  Future<String> downloadReport(String token, String reportId);
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  ReportRemoteDataSourceImpl({required this.client, required this.baseUrl});

  @override
  Future<Map<String, dynamic>> generateDeviceReport(
    String token, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/reports/devices');

      final queryParams = <String, String>{};
      if (startDate != null) queryParams['start'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end'] = endDate.toIso8601String();

      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw ServerException(
          message: 'Failed to generate device report: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> generateMaintenanceReport(
    String token, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/reports/maintenance');

      final queryParams = <String, String>{};
      if (startDate != null) queryParams['start'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end'] = endDate.toIso8601String();

      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw ServerException(
          message:
              'Failed to generate maintenance report: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> generateUsageReport(
    String token, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/reports/usage');

      final queryParams = <String, String>{};
      if (startDate != null) queryParams['start'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end'] = endDate.toIso8601String();

      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw ServerException(
          message: 'Failed to generate usage report: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAvailableReports(String token) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/reports'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['reports'] ?? data);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw ServerException(
          message: 'Failed to get available reports: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<String> downloadReport(String token, String reportId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/reports/$reportId/download'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return response.body;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Report not found');
      } else {
        throw ServerException(
          message: 'Failed to download report: ${response.statusCode}',
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
