import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:painel_windowns/core/di/injection.config.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/device_service.dart';
import 'package:painel_windowns/services/module_management_service.dart';
import 'package:painel_windowns/services/totem_service.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Register core services manually

  // Auth Service (singleton - mantém estado de autenticação)
  getIt.registerLazySingleton<AuthService>(() => AuthService());

  // Module Management Service (depende de AuthService)
  getIt.registerLazySingleton<ModuleManagementService>(
    () => ModuleManagementService(authService: getIt<AuthService>()),
  );

  // Device Service
  getIt.registerLazySingleton<DeviceService>(() => DeviceService());


  // Totem Service
  getIt.registerLazySingleton<TotemService>(() => TotemService());

  // Initialize injectable services (BLoCs, etc)
  await getIt.init();
}
