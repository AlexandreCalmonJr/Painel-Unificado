import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:painel_windowns/core/error/exceptions.dart';
import 'package:painel_windowns/data/models/user_model.dart';

/// Data Source remoto para usuários
abstract class UserRemoteDataSource {
  Future<List<User>> getUsers(String token);
  Future<User> getUserById(String token, String userId);
  Future<User> createUser(String token, User user);
  Future<void> updateUser(String token, User user);
  Future<void> deleteUser(String token, String userId);
  Future<void> changePassword(String token, String userId, String newPassword);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  UserRemoteDataSourceImpl({required this.client, required this.baseUrl});

  @override
  Future<List<User>> getUsers(String token) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final jsonList = (data['users'] ?? data) as List<dynamic>;
        return jsonList
            .map((json) => User.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else {
        throw ServerException(
          message: 'Failed to load users: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<User> getUserById(String token, String userId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return User.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'User not found');
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else {
        throw ServerException(
          message: 'Failed to load user: ${response.statusCode}',
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
  Future<User> createUser(String token, User user) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'username': user.username,
          'email': user.email,
          'password': user.password,
          'role': user.role,
          'isActive': user.isActive,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return User.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else {
        throw ServerException(
          message: 'Failed to create user: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<void> updateUser(String token, User user) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/users/${user.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'username': user.username,
          'email': user.email,
          'role': user.role,
          'isActive': user.isActive,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'User not found');
      } else {
        throw ServerException(
          message: 'Failed to update user: ${response.statusCode}',
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
  Future<void> deleteUser(String token, String userId) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'User not found');
      } else {
        throw ServerException(
          message: 'Failed to delete user: ${response.statusCode}',
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
  Future<void> changePassword(
    String token,
    String userId,
    String newPassword,
  ) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/users/$userId/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'newPassword': newPassword}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw const UnauthorizedException(message: 'Unauthorized access');
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'User not found');
      } else {
        throw ServerException(
          message: 'Failed to change password: ${response.statusCode}',
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
