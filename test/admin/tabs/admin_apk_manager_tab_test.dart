// File: test/admin/tabs/admin_apk_manager_tab_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:painel_windowns/presentation/features/admin/widgets/admin_apk_manager_tab.dart';
import 'package:painel_windowns/presentation/features/auth/bloc/theme_controller.dart';
import 'package:painel_windowns/services/auth_service.dart';

@GenerateMocks([AuthService])
import 'admin_apk_manager_tab_test.mocks.dart';

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

  group('AdminApkManagerTab Widget Tests', () {
    testWidgets('should display statistics cards', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: AdminApkManagerTab(authService: mockAuthService),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Total de APKs'), findsOneWidget);
      expect(find.text('Downloads Totais'), findsOneWidget);
      expect(find.text('Espaço Total'), findsOneWidget);
    });

    testWidgets('should display search field', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: AdminApkManagerTab(authService: mockAuthService),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextField, 'Buscar APKs...'), findsOneWidget);
    });

    testWidgets('should display upload APK button', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: AdminApkManagerTab(authService: mockAuthService),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.widgetWithText(ElevatedButton, 'Upload APK'), findsOneWidget);
    });

    testWidgets('should filter APKs when searching', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: AdminApkManagerTab(authService: mockAuthService),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(
        find.widgetWithText(TextField, 'Buscar APKs...'),
        'MDM',
      );
      await tester.pump();

      expect(find.text('MDM'), findsWidgets);
    });
  });

  group('AdminApkManagerTab APK Cards', () {
    testWidgets('should display APK information', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: AdminApkManagerTab(authService: mockAuthService),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for APK details
      expect(find.text('MDM Client'), findsOneWidget);
      expect(find.text('com.company.mdm.client'), findsOneWidget);
    });

    testWidgets('should display APK status badges', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: AdminApkManagerTab(authService: mockAuthService),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for status badges
      expect(find.text('Ativo'), findsWidgets);
    });

    testWidgets('should display action buttons on APK cards', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: AdminApkManagerTab(authService: mockAuthService),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for action buttons
      expect(find.byIcon(Icons.download), findsWidgets);
      expect(find.byIcon(Icons.info_outline), findsWidgets);
      expect(find.byIcon(Icons.delete), findsWidgets);
    });

    testWidgets('should display APK metadata chips', (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: AdminApkManagerTab(authService: mockAuthService),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for metadata icons
      expect(find.byIcon(Icons.tag), findsWidgets);
      expect(find.byIcon(Icons.storage), findsWidgets);
      expect(find.byIcon(Icons.calendar_today), findsWidgets);
    });
  });

  group('AdminApkManagerTab Interactions', () {
    testWidgets('should show snackbar when upload button is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: AdminApkManagerTab(authService: mockAuthService),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap upload button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Upload APK'));
      await tester.pumpAndSettle();

      expect(
        find.text('Funcionalidade de upload em desenvolvimento'),
        findsOneWidget,
      );
    });
  });
}
