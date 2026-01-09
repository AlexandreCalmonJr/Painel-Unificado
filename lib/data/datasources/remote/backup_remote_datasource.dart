import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:painel_windowns/core/error/exceptions.dart';

/// Data Source remoto para backup e restore
abstract class BackupRemoteDataSource {
  Future<Map<String, dynamic>> createBackup(
    String token, {
    String? description,
  });
  Future<List<Map<String, dynamic>>> getBackupList(String token);
  Future<void> restoreBackup(String token, String backupId);
  Future<void> deleteBackup(String token, String backupId);
  Future<String> downloadBackup(String token, String backupId);
}

class BackupRemoteDataSourceImpl implements BackupRemoteDataSource {

  BackupRemoteDataSourceImpl({required this.client, required this.baseUrl});
  final http.Client client;
  final String baseUrl;

  @override
  Future<Map<String, dynamic>> createBackup(
    String token, {
    String? description,
  }) async {
    try {
      final body =
          description != null
              ? {'description': description}
              : <String, dynamic>{};

      final response = await client.post(
        Uri.parse('$baseUrl/backup/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else {
        throw ServerException(
          message: 'Failed to create backup: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getBackupList(String token) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/backup/list'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from((data['backups'] ?? data) as List);
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else {
        throw ServerException(
          message: 'Failed to get backup list: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<void> restoreBackup(String token, String backupId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/backup/restore/$backupId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else if (response.statusCode == 404) {
        throw const NotFoundException(message: 'Backup not found');
      } else {
        throw ServerException(
          message: 'Failed to restore backup: ${response.statusCode}',
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
  Future<void> deleteBackup(String token, String backupId) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/backup/$backupId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else if (response.statusCode == 404) {
        throw const NotFoundException(message: 'Backup not found');
      } else {
        throw ServerException(
          message: 'Failed to delete backup: ${response.statusCode}',
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
  Future<String> downloadBackup(String token, String backupId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/backup/download/$backupId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return response.body;
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else if (response.statusCode == 404) {
        throw const NotFoundException(message: 'Backup not found');
      } else {
        throw ServerException(
          message: 'Failed to download backup: ${response.statusCode}',
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
