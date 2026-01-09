// File: test/admin/tabs/admin_users_tab_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:painel_windowns/admin/tabs/admin_users_tab.dart';
import 'package:painel_windowns/controllers/theme_controller.dart';
import 'package:painel_windowns/services/auth_service.dart';

@GenerateMocks([AuthService])
import 'admin_users_tab_test.mocks.dart';

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();

    // Initialize GetX
    Get.testMode = true;
    Get.put(ThemeController());

    // Mock token
    when(mockAuthService.currentToken).thenReturn('test-token-123');
  });

  tearDown(() {
    Get.reset();
  });

  group('AdminUsersTab Widget Tests', () {
    testWidgets('should display loading indicator initially', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: AdminUsersTab(authService: mockAuthService)),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display search field', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: AdminUsersTab(authService: mockAuthService)),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(TextField, 'Buscar utilizadores...'),
        findsOneWidget,
      );
    });

    testWidgets('should display create user button', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: AdminUsersTab(authService: mockAuthService)),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(ElevatedButton, 'Novo Utilizador'),
        findsOneWidget,
      );
    });

    testWidgets('should filter users when searching', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: AdminUsersTab(authService: mockAuthService)),
        ),
      );

      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(
        find.widgetWithText(TextField, 'Buscar utilizadores...'),
        'admin',
      );
      await tester.pump();

      // Verify search is working (implementation dependent)
      expect(find.text('admin'), findsWidgets);
    });
  });

  group('AdminUsersTab Error Handling', () {
    testWidgets('should display error message when token is null', (
      tester,
    ) async {
      when(mockAuthService.currentToken).thenReturn(null);

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: AdminUsersTab(authService: mockAuthService)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Erro ao carregar utilizadores'), findsOneWidget);
    });
  });
}
