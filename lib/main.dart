import 'package:flutter/material.dart';
import 'package:painel_windowns/dashboard_screen.dart';
import 'package:painel_windowns/home_screen.dart';
import 'package:painel_windowns/login_screen.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/server_config_service.dart';
import 'package:painel_windowns/totem/totem_dashboard_screen.dart';

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
    return MaterialApp(
      title: 'Painel Unificado',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      
      // A tela inicial agora é decidida aqui.
      // Se o utilizador estiver logado, vai para a HomeScreen (o hub).
      // Caso contrário, vai para a LoginScreen.
      home: authService.isLoggedIn
          ? HomeScreen(authService: authService)
          : LoginScreen(authService: authService),

      // As rotas são usadas para a navegação a partir do HomeScreen.
      routes: {
        '/home': (context) => HomeScreen(authService: authService),
        '/login': (context) => LoginScreen(authService: authService),
        // A rota '/dashboard' agora aponta para a sua tela original, que é o Módulo Mobile.
        '/dashboard': (context) => MDMDashboard(authService: authService),
        '/totem_dashboard': (context) => TotemDashboardScreen(authService: authService),
      },
    );
  }
}