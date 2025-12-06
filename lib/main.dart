import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:painel_windowns/admin/admin_dashboard_screen.dart';
import 'package:painel_windowns/controllers/theme_controller.dart';
import 'package:painel_windowns/devices/dashboard_screen.dart';
import 'package:painel_windowns/screen/home_screen.dart';
import 'package:painel_windowns/screen/login_screen.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/server_config_service.dart';
import 'package:painel_windowns/services/websocket_service.dart';
import 'package:painel_windowns/totem/totem_dashboard_screen.dart';
import 'package:painel_windowns/utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServerConfigService.instance.initialize();

  final authService = AuthService();
  await authService.initializeFromStorage();

  // Inicializa WebSocketService
  final logger = Logger();
  final wsService = WebSocketService(logger);
  Get.put(wsService);

  // Conecta WebSocket se possível
  final config = ServerConfigService.instance.loadConfig();
  final baseUrl = 'http://${config['ip']}:${config['port']}';
  wsService.connect(baseUrl);

  runApp(MyApp(authService: authService));
}

class MyApp extends StatefulWidget {
  final AuthService authService;

  const MyApp({super.key, required this.authService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // App está sendo fechado (shutdown)
      final wsService = Get.find<WebSocketService>();
      wsService.sendShutdownSignal();
    }
  }

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
          widget.authService.isLoggedIn
              ? HomeScreen(authService: widget.authService)
              : LoginScreen(authService: widget.authService),

      // As rotas são usadas para a navegação a partir do HomeScreen.
      routes: {
        '/home': (context) => HomeScreen(authService: widget.authService),
        '/login': (context) => LoginScreen(authService: widget.authService),
        // A rota '/dashboard' agora aponta para a sua tela original, que é o Módulo Mobile.
        '/dashboard':
            (context) => MDMDashboard(authService: widget.authService),
        '/totem_dashboard':
            (context) => TotemDashboardScreen(authService: widget.authService),
        '/admin_dashboard':
            (context) => AdminDashboardScreen(authService: widget.authService),
      },

      // GetX bindings
      initialBinding: BindingsBuilder(() {
        Get.put(ThemeController());
      }),
    );
  }
}
