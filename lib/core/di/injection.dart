import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:painel_windowns/core/di/injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Initialize injectable services (all services are now registered via app_module.dart)
  await getIt.init();
}
