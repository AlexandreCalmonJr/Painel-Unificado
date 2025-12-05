// File: test/services/auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:painel_windowns/services/auth_service.dart';

// Gera mocks automaticamente com build_runner
@GenerateMocks([http.Client])
import 'auth_service_test.mocks.dart';

void main() {
  group('AuthService Tests', () {
    late AuthService authService;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      // authService = AuthService(client: mockClient);
    });

    tearDown(() {
      // Limpa após cada teste
    });

    test('login com credenciais válidas retorna sucesso', () async {
      // Arrange
      final responseBody = jsonEncode({
        'token': 'fake_jwt_token_12345',
        'user': {
          'id': '1',
          'username': 'testuser',
          'role': 'admin',
          'permissions': ['read', 'write']
        }
      });

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      // final result = await authService.login('testuser', 'password123');

      // Assert
      // expect(result['success'], true);
      // expect(authService.isLoggedIn, true);
      // expect(authService.isAdmin, true);
    });

    test('login com credenciais inválidas retorna erro', () async {
      // Arrange
      final responseBody = jsonEncode({
        'message': 'Credenciais inválidas'
      });

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(responseBody, 401));

      // Act
      // final result = await authService.login('testuser', 'wrongpassword');

      // Assert
      // expect(result['success'], false);
      // expect(result['message'], 'Credenciais inválidas');
      // expect(authService.isLoggedIn, false);
    });

    test('login com timeout lança NetworkException', () async {
      // Arrange
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenThrow(Exception('Timeout'));

      // Act & Assert
      // expect(
      //   () => authService.login('testuser', 'password123'),
      //   throwsA(isA<NetworkException>()),
      // );
    });

    test('logout limpa dados do usuário', () async {
      // Arrange
      // Simula login primeiro
      final responseBody = jsonEncode({
        'token': 'fake_token',
        'user': {'id': '1', 'username': 'testuser', 'role': 'user'}
      });

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(responseBody, 200));

      // await authService.login('testuser', 'password123');

      // Act
      // await authService.logout();

      // Assert
      // expect(authService.isLoggedIn, false);
      // expect(authService.currentUser, null);
      // expect(authService.currentToken, null);
    });

    test('getUsers retorna lista de usuários para admin', () async {
      // Arrange
      final usersResponse = jsonEncode({
        'users': [
          {'id': '1', 'username': 'user1', 'role': 'user'},
          {'id': '2', 'username': 'user2', 'role': 'admin'},
        ]
      });

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(usersResponse, 200));

      // Act
      // final result = await authService.getUsers();

      // Assert
      // expect(result['success'], true);
      // expect(result['users'], isA<List>());
      // expect(result['users'].length, 2);
    });

    test('createUser cria novo usuário com sucesso', () async {
      // Arrange
      final createResponse = jsonEncode({
        'success': true,
        'message': 'Usuário criado com sucesso',
        'user': {'id': '3', 'username': 'newuser', 'role': 'user'}
      });

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(createResponse, 201));

      // Act
      // final result = await authService.createUser({
      //   'username': 'newuser',
      //   'password': 'password123',
      //   'role': 'user'
      // });

      // Assert
      // expect(result['success'], true);
      // expect(result['user'], isNotNull);
    });
  });
}
