import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:painel_windowns/presentation/features/admin/pages/admin_dashboard_page.dart';
import 'package:painel_windowns/presentation/features/auth/bloc/theme_controller.dart';
import 'package:painel_windowns/core/di/injection.dart';
import 'package:painel_windowns/presentation/features/devices/pages/devices_dashboard_page.dart';
import 'package:painel_windowns/presentation/bloc/auth/auth_bloc.dart';
import 'package:painel_windowns/presentation/features/home/pages/home_page.dart';
import 'package:painel_windowns/presentation/features/auth/pages/login_page.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/server_config_service.dart';
import 'package:painel_windowns/services/websocket_service.dart';
import 'package:painel_windowns/presentation/features/totem/pages/totem_dashboard_screen.dart';
import 'package:painel_windowns/presentation/shared/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar Dependency Injection (Fase 3)
  await configureDependencies();

  await ServerConfigService.instance.initialize();

  final authService = AuthService();
  await authService.initializeFromStorage();

  // Inicializa WebSocketService
  final logger = Logger();
  final wsService = WebSocketService(logger);
  Get.put(wsService);

  runApp(MyApp(authService: authService));
}

class MyApp extends StatefulWidget {

  const MyApp({super.key, required this.authService});
  final AuthService authService;

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
    return MultiBlocProvider(
      providers: [
        // AuthBloc global para gerenciar autenticação
        BlocProvider(create: (_) => getIt<AuthBloc>(), lazy: false),
      ],
      child: GetMaterialApp(
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
              (context) =>
                  DevicesDashboardPage(authService: widget.authService),
          '/totem_dashboard':
              (context) =>
                  TotemDashboardScreen(authService: widget.authService),
          '/admin_dashboard':
              (context) =>
                  AdminDashboardScreen(authService: widget.authService),
        },

        // GetX bindings
        // ignore: inference_failure_on_instance_creation
        initialBinding: BindingsBuilder(() {
          Get.put(ThemeController());
        }),
      ),
    );
  }
}
