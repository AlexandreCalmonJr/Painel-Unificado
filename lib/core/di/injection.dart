import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:painel_windowns/core/di/injection.config.dart';

/// Global service locator instance.
final getIt = GetIt.instance;

/// Configures all dependencies using Injectable.
///
/// This function must be called before using any dependencies.
/// Typically called in main() before runApp().
///
/// Example:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await configureDependencies();
///   runApp(MyApp());
/// }
/// ```
@InjectableInit()
Future<void> configureDependencies() async => getIt.init();
