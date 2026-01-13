// File: test/admin/tabs/admin_locations_tab_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:painel_windowns/presentation/features/admin/widgets/admin_locations_tab.dart';
import 'package:painel_windowns/presentation/features/auth/bloc/theme_controller.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/device_service.dart';
import 'package:painel_windowns/services/location_service.dart';

@GenerateMocks([AuthService, LocationService, DeviceService])
import 'admin_locations_tab_test.mocks.dart';

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

  group('AdminLocationsTab Widget Tests', () {
    testWidgets('should display TabBar with two tabs', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: AdminLocationsTab(authService: mockAuthService)),
        ),
      );

      await tester.pumpAndSettle();

      // Check for tab labels
      expect(find.text('Localizações'), findsOneWidget);
      expect(find.text('Unidades'), findsOneWidget);
    });

    testWidgets('should display loading indicator initially', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: AdminLocationsTab(authService: mockAuthService)),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should switch between tabs', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: AdminLocationsTab(authService: mockAuthService)),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Unidades tab
      await tester.tap(find.text('Unidades'));
      await tester.pumpAndSettle();

      // Verify we're on Unidades tab
      expect(find.text('Buscar unidades...'), findsOneWidget);
    });

    testWidgets('should display create location button on Localizações tab', (
      tester,
    ) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: AdminLocationsTab(authService: mockAuthService)),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(ElevatedButton, 'Nova Localização'),
        findsOneWidget,
      );
    });

    testWidgets('should display refresh button', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: AdminLocationsTab(authService: mockAuthService)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.widgetWithIcon(IconButton, Icons.refresh), findsWidgets);
    });
  });

  group('AdminLocationsTab - Locations Tab', () {
    testWidgets('should display search field for locations', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: AdminLocationsTab(authService: mockAuthService)),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(TextField, 'Buscar localizações...'),
        findsOneWidget,
      );
    });

    testWidgets('should display export/import menu', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: AdminLocationsTab(authService: mockAuthService)),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the more options button
      final moreButton = find.widgetWithIcon(IconButton, Icons.more_vert);
      expect(moreButton, findsOneWidget);
    });
  });

  group('AdminLocationsTab - Units Tab', () {
    testWidgets('should display statistics cards on Units tab', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: AdminLocationsTab(authService: mockAuthService)),
        ),
      );

      await tester.pumpAndSettle();

      // Switch to Units tab
      await tester.tap(find.text('Unidades'));
      await tester.pumpAndSettle();

      // Check for stat cards
      expect(find.text('Total de Unidades'), findsOneWidget);
      expect(find.text('Total de BSSIDs'), findsOneWidget);
    });

    testWidgets('should display search field for units', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: AdminLocationsTab(authService: mockAuthService)),
        ),
      );

      await tester.pumpAndSettle();

      // Switch to Units tab
      await tester.tap(find.text('Unidades'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(TextField, 'Buscar unidades...'),
        findsOneWidget,
      );
    });
  });

  group('AdminLocationsTab Error Handling', () {
    testWidgets('should display error message when loading fails', (
      tester,
    ) async {
      when(mockAuthService.currentToken).thenReturn(null);

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(body: AdminLocationsTab(authService: mockAuthService)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Erro ao carregar dados'), findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, 'Tentar Novamente'),
        findsOneWidget,
      );
    });
  });
}
