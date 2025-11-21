import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:painel_windowns/admin/admin_dashboard_screen.dart';
import 'package:painel_windowns/controllers/theme_controller.dart';
import 'package:painel_windowns/devices/dashboard_screen.dart';
import 'package:painel_windowns/screen/home_screen.dart';
import 'package:painel_windowns/screen/login_screen.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/server_config_service.dart';
import 'package:painel_windowns/totem/totem_dashboard_screen.dart';
import 'package:painel_windowns/utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServerConfigService.instance.initialize();

  final authService = AuthService();
  await authService.initializeFromStorage();

  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;

  const MyApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Painel Unificado',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,

      // A tela inicial agora é decidida aqui.
      // Se o utilizador estiver logado, vai para a HomeScreen (o hub).
      // Caso contrário, vai para a LoginScreen.
      home:
          authService.isLoggedIn
              ? HomeScreen(authService: authService)
              : LoginScreen(authService: authService),

      // As rotas são usadas para a navegação a partir do HomeScreen.
      routes: {
        '/home': (context) => HomeScreen(authService: authService),
        '/login': (context) => LoginScreen(authService: authService),
        // A rota '/dashboard' agora aponta para a sua tela original, que é o Módulo Mobile.
        '/dashboard': (context) => MDMDashboard(authService: authService),
        '/totem_dashboard':
            (context) => TotemDashboardScreen(authService: authService),
        '/admin_dashboard':
            (context) => AdminDashboardScreen(authService: authService),
      },

      // GetX bindings
      initialBinding: BindingsBuilder(() {
        Get.put(ThemeController());
      }),
    );
  }
}
