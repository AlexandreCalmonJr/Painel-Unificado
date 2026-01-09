// File: test/admin/admin_dashboard_integration_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:painel_windowns/admin/admin_dashboard_screen.dart';
import 'package:painel_windowns/controllers/theme_controller.dart';
import 'package:painel_windowns/services/auth_service.dart';

@GenerateMocks([AuthService])
import 'admin_dashboard_integration_test.mocks.dart';

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();

    Get.testMode = true;
    Get.put(ThemeController());

    when(mockAuthService.currentToken).thenReturn('test-token-123');
    when(
      mockAuthService.currentUser,
    ).thenReturn({'username': 'admin', 'role': 'admin'});
  });

  tearDown(() {
    Get.reset();
  });

  group('AdminDashboardScreen Integration Tests', () {
    testWidgets('should display admin dashboard with sidebar', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: AdminDashboardScreen(authService: mockAuthService),
        ),
      );

      await tester.pumpAndSettle();

      // Check for app bar
      expect(find.text('Painel Administrativo'), findsOneWidget);

      // Check for sidebar title
      expect(find.text('Administrativo'), findsOneWidget);
    });

    testWidgets('should display all menu items', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: AdminDashboardScreen(authService: mockAuthService),
        ),
      );

      await tester.pumpAndSettle();

      // Check for all menu items
      expect(find.text('Utilizadores'), findsOneWidget);
      expect(find.text('Localização'), findsOneWidget);
      expect(find.text('Módulos'), findsOneWidget);
      expect(find.text('Gestor de APKs'), findsOneWidget);
      expect(find.text('Voltar'), findsOneWidget);
    });

    testWidgets('should navigate to Users tab by default', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: AdminDashboardScreen(authService: mockAuthService),
        ),
      );

      await tester.pumpAndSettle();

      // Should show users tab content
      expect(find.text('Buscar utilizadores...'), findsOneWidget);
    });

    testWidgets('should navigate to Locations tab when clicked', (
      tester,
    ) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: AdminDashboardScreen(authService: mockAuthService),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Localização menu item
      await tester.tap(find.text('Localização'));
      await tester.pumpAndSettle();

      // Should show locations tab with sub-tabs
      expect(find.text('Localizações'), findsOneWidget);
      expect(find.text('Unidades'), findsOneWidget);
    });

    testWidgets('should navigate to Modules tab when clicked', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: AdminDashboardScreen(authService: mockAuthService),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Módulos menu item
      await tester.tap(find.text('Módulos'));
      await tester.pumpAndSettle();

      // Should show modules tab content
      expect(find.text('Buscar módulos...'), findsOneWidget);
    });

    testWidgets('should navigate to APK Manager tab when clicked', (
      tester,
    ) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: AdminDashboardScreen(authService: mockAuthService),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Gestor de APKs menu item
      await tester.tap(find.text('Gestor de APKs'));
      await tester.pumpAndSettle();

      // Should show APK manager tab content
      expect(find.text('Total de APKs'), findsOneWidget);
    });

    testWidgets('should toggle sidebar visibility', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: AdminDashboardScreen(authService: mockAuthService),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap menu button
      final menuButton = find.byIcon(Icons.menu);
      expect(menuButton, findsOneWidget);

      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      // Sidebar should be hidden (menu items not visible)
      expect(find.text('Administrativo'), findsNothing);

      // Tap again to show
      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      expect(find.text('Administrativo'), findsOneWidget);
    });

    testWidgets('should navigate back when Voltar is clicked', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const Scaffold(body: Center(child: Text('Home'))),
          routes: {
            '/admin':
                (context) => AdminDashboardScreen(authService: mockAuthService),
          },
        ),
      );

      // Navigate to admin
      Get.toNamed('/admin');
      await tester.pumpAndSettle();

      // Tap Voltar
      await tester.tap(find.text('Voltar'));
      await tester.pumpAndSettle();

      // Should navigate back
      expect(find.text('Home'), findsOneWidget);
    });
  });

  group('AdminDashboardScreen Theme Integration', () {
    testWidgets('should apply dark theme correctly', (tester) async {
      final themeController = Get.find<ThemeController>();
      themeController.toggleTheme();

      await tester.pumpWidget(
        GetMaterialApp(
          home: AdminDashboardScreen(authService: mockAuthService),
        ),
      );

      await tester.pumpAndSettle();

      // Verify dark theme is applied
      expect(themeController.isDarkMode, true);
    });
  });
}
