// File: test/admin/tabs/admin_modules_tab_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:painel_windowns/presentation/features/admin/widgets/admin_modules_tab.dart';
import 'package:painel_windowns/presentation/features/auth/bloc/theme_controller.dart';
import 'package:painel_windowns/services/auth_service.dart';

@GenerateMocks([AuthService])
import 'admin_modules_tab_test.mocks.dart';

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();

    Get.testMode = true;
    Get.put(ThemeController());

    when(mockAuthService.currentToken).thenReturn('test-token-123');
  });

  tearDown(() {
    Get.reset();
  });

  group('AdminModulesTab Widget Tests', () {
    testWidgets('should display loading indicator initially', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: AdminModulesTab(authService: mockAuthService)),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display search field', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: AdminModulesTab(authService: mockAuthService)),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(TextField, 'Buscar módulos...'),
        findsOneWidget,
      );
    });

    testWidgets('should display create module button', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: AdminModulesTab(authService: mockAuthService)),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(ElevatedButton, 'Novo Módulo'),
        findsOneWidget,
      );
    });

    testWidgets('should display refresh button', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: AdminModulesTab(authService: mockAuthService)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.widgetWithIcon(IconButton, Icons.refresh), findsOneWidget);
    });

    testWidgets('should filter modules when searching', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: AdminModulesTab(authService: mockAuthService)),
        ),
      );

      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(
        find.widgetWithText(TextField, 'Buscar módulos...'),
        'notebook',
      );
      await tester.pump();

      expect(find.text('notebook'), findsWidgets);
    });
  });

  group('AdminModulesTab Module Cards', () {
    testWidgets('should display module type icons', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: AdminModulesTab(authService: mockAuthService)),
        ),
      );

      await tester.pumpAndSettle();

      // Check for common module icons
      expect(find.byIcon(Icons.laptop), findsWidgets);
    });

    testWidgets('should display edit and delete buttons on module cards', (
      tester,
    ) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: AdminModulesTab(authService: mockAuthService)),
        ),
      );

      await tester.pumpAndSettle();

      // Look for action buttons
      expect(find.byIcon(Icons.edit), findsWidgets);
      expect(find.byIcon(Icons.delete), findsWidgets);
    });
  });

  group('AdminModulesTab Error Handling', () {
    testWidgets('should display error message when token is null', (
      tester,
    ) async {
      when(mockAuthService.currentToken).thenReturn(null);

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: AdminModulesTab(authService: mockAuthService)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Erro ao carregar módulos'), findsOneWidget);
    });

    testWidgets('should display retry button on error', (tester) async {
      when(mockAuthService.currentToken).thenReturn(null);

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: AdminModulesTab(authService: mockAuthService)),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(ElevatedButton, 'Tentar Novamente'),
        findsOneWidget,
      );
    });
  });
}
