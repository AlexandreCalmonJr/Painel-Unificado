import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:painel_windowns/core/network/network_info.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Register core dependencies
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // TODO: Add more dependencies as we create them
  // This will be expanded as we implement repositories, use cases, and blocs
}
