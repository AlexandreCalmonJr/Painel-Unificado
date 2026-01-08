import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:painel_windowns/core/error/exceptions.dart';

/// Data Source remoto para notificações
abstract class NotificationRemoteDataSource {
  Future<List<Map<String, dynamic>>> getNotifications(String token);
  Future<void> markAsRead(String token, String notificationId);
  Future<void> markAllAsRead(String token);
  Future<void> deleteNotification(String token, String notificationId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  NotificationRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
  });

  @override
  Future<List<Map<String, dynamic>>> getNotifications(String token) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['notifications'] ?? data);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw ServerException(
          message: 'Failed to get notifications: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<void> markAsRead(String token, String notificationId) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Notification not found');
      } else {
        throw ServerException(
          message:
              'Failed to mark notification as read: ${response.statusCode}',
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
  Future<void> markAllAsRead(String token) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/notifications/read-all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw ServerException(
          message: 'Failed to mark all as read: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<void> deleteNotification(String token, String notificationId) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/notifications/$notificationId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Notification not found');
      } else {
        throw ServerException(
          message: 'Failed to delete notification: ${response.statusCode}',
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
