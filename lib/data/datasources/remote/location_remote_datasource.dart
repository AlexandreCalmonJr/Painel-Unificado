import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:painel_windowns/core/error/exceptions.dart';

/// Data Source remoto para localizações
abstract class LocationRemoteDataSource {
  Future<List<Map<String, dynamic>>> getLocations(String token);
  Future<Map<String, dynamic>> getLocationById(String token, String locationId);
  Future<Map<String, dynamic>> createLocation(
    String token,
    Map<String, dynamic> location,
  );
  Future<void> updateLocation(
    String token,
    String locationId,
    Map<String, dynamic> location,
  );
  Future<void> deleteLocation(String token, String locationId);
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  LocationRemoteDataSourceImpl({required this.client, required this.baseUrl});

  @override
  Future<List<Map<String, dynamic>>> getLocations(String token) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/locations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['locations'] ?? data);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw ServerException(
          message: 'Failed to load locations: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getLocationById(
    String token,
    String locationId,
  ) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/locations/$locationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Location not found');
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw ServerException(
          message: 'Failed to load location: ${response.statusCode}',
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
  Future<Map<String, dynamic>> createLocation(
    String token,
    Map<String, dynamic> location,
  ) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/locations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(location),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw ServerException(
          message: 'Failed to create location: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<void> updateLocation(
    String token,
    String locationId,
    Map<String, dynamic> location,
  ) async {
    try {
      final response = await client.put(
        Uri.parse('$baseUrl/locations/$locationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(location),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Location not found');
      } else {
        throw ServerException(
          message: 'Failed to update location: ${response.statusCode}',
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
  Future<void> deleteLocation(String token, String locationId) async {
    try {
      final response = await client.delete(
        Uri.parse('$baseUrl/locations/$locationId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Location not found');
      } else {
        throw ServerException(
          message: 'Failed to delete location: ${response.statusCode}',
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
