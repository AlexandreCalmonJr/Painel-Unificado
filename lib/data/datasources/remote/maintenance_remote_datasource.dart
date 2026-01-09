import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:painel_windowns/core/error/exceptions.dart';

/// Data Source remoto para manutenção de ativos
abstract class MaintenanceRemoteDataSource {
  Future<List<Map<String, dynamic>>> getMaintenanceRecords(
    String token,
    String assetId,
  );
  Future<Map<String, dynamic>> createMaintenanceRecord(
    String token,
    Map<String, dynamic> record,
  );
  Future<void> updateMaintenanceRecord(
    String token,
    String recordId,
    Map<String, dynamic> record,
  );
  Future<List<Map<String, dynamic>>> getScheduledMaintenance(String token);
}

class MaintenanceRemoteDataSourceImpl implements MaintenanceRemoteDataSource {

  MaintenanceRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
  });
  final http.Client client;
  final String baseUrl;

  @override
  Future<List<Map<String, dynamic>>> getMaintenanceRecords(
    String token,
    String assetId,
  ) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/assets/$assetId/maintenance'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(
          (data['records'] ?? data) as List,
        );
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else if (response.statusCode == 404) {
        throw const NotFoundException(message: 'Asset not found');
      } else {
        throw ServerException(
          message: 'Failed to get maintenance records: ${response.statusCode}',
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
  Future<Map<String, dynamic>> createMaintenanceRecord(
    String token,
    Map<String, dynamic> record,
  ) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/maintenance'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(record),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else {
        throw ServerException(
          message:
              'Failed to create maintenance record: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<void> updateMaintenanceRecord(
    String token,
    String recordId,
    Map<String, dynamic> record,
  ) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/maintenance/$recordId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(record),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else if (response.statusCode == 404) {
        throw const NotFoundException(message: 'Maintenance record not found');
      } else {
        throw ServerException(
          message:
              'Failed to update maintenance record: ${response.statusCode}',
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
  Future<List<Map<String, dynamic>>> getScheduledMaintenance(
    String token,
  ) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/maintenance/scheduled'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(
          (data['scheduled'] ?? data) as List,
        );
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else {
        throw ServerException(
          message:
              'Failed to get scheduled maintenance: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Network error: $e');
    }
  }
}
