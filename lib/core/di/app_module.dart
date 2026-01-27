import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:painel_windowns/core/network/network_info.dart';
import 'package:painel_windowns/data/datasources/local/auth_local_datasource.dart';
import 'package:painel_windowns/data/datasources/local/mobile_local_datasource.dart';
import 'package:painel_windowns/data/datasources/local/totem_local_datasource.dart';
import 'package:painel_windowns/data/datasources/remote/auth_remote_datasource.dart';
import 'package:painel_windowns/data/datasources/remote/mobile_remote_datasource.dart';
import 'package:painel_windowns/data/datasources/remote/totem_remote_datasource.dart';
import 'package:painel_windowns/data/repositories/auth_repository_impl.dart';
import 'package:painel_windowns/data/repositories/device_repository_impl.dart';
import 'package:painel_windowns/data/repositories/totem_repository_impl.dart';
import 'package:painel_windowns/domain/repositories/i_auth_repository.dart';
import 'package:painel_windowns/domain/repositories/i_device_repository.dart';
import 'package:painel_windowns/domain/repositories/i_totem_repository.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/device_service.dart';
import 'package:painel_windowns/services/module_management_service.dart';
import 'package:painel_windowns/services/status_service.dart';
import 'package:painel_windowns/services/totem_service.dart';
import 'package:painel_windowns/services/websocket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Injectable module for registering dependencies that cannot use
/// constructor injection or need special initialization.
@module
abstract class AppModule {
  /// Provides AuthService as a singleton
  @lazySingleton
  AuthService get authService => AuthService();

  /// Provides NetworkInfo implementation
  @lazySingleton
  NetworkInfo get networkInfo => NetworkInfoImpl();

  /// Provides http.Client
  @lazySingleton
  http.Client get httpClient => http.Client();

  /// Provides SharedPreferences (async)
  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  /// Provides Logger
  @lazySingleton
  Logger get logger => Logger();

  /// Provides WebSocketService
  @lazySingleton
  WebSocketService websocketService(Logger logger) => WebSocketService(logger);

  /// Provides StatusService
  @lazySingleton
  StatusService get statusService => StatusService();

  /// Provides ModuleManagementService
  @lazySingleton
  ModuleManagementService moduleManagementService(AuthService authService) =>
      ModuleManagementService(authService: authService);

  /// Provides DeviceService
  @lazySingleton
  DeviceService get deviceService => DeviceService();

  /// Provides TotemService
  @lazySingleton
  TotemService get totemService => TotemService();

  /// Provides DeviceRemoteDataSource
  @lazySingleton
  DeviceRemoteDataSource deviceRemoteDataSource(
    http.Client client,
    SharedPreferences sharedPreferences,
  ) => DeviceRemoteDataSourceImpl(
    client: client,
    baseUrl: 'http://localhost:3000/api', // TODO: Move to config
  );

  /// Provides DeviceLocalDataSource
  @lazySingleton
  DeviceLocalDataSource deviceLocalDataSource(SharedPreferences prefs) =>
      DeviceLocalDataSourceImpl(sharedPreferences: prefs);

  /// Provides TotemRemoteDataSource
  @lazySingleton
  TotemRemoteDataSource totemRemoteDataSource(
    http.Client client,
    SharedPreferences sharedPreferences,
  ) => TotemRemoteDataSourceImpl(
    client: client,
    baseUrl: 'http://localhost:3000/api', // TODO: Move to config
  );

  /// Provides TotemLocalDataSource
  @lazySingleton
  TotemLocalDataSource totemLocalDataSource(SharedPreferences prefs) =>
      TotemLocalDataSourceImpl(sharedPreferences: prefs);

  /// Provides AuthRemoteDataSource
  @lazySingleton
  AuthRemoteDataSource authRemoteDataSource(
    http.Client client,
    SharedPreferences sharedPreferences,
  ) => AuthRemoteDataSourceImpl(
    client: client,
    baseUrl: 'http://localhost:3000/api', // TODO: Move to config
  );

  /// Provides AuthLocalDataSource
  @lazySingleton
  AuthLocalDataSource authLocalDataSource(SharedPreferences prefs) =>
      AuthLocalDataSourceImpl(sharedPreferences: prefs);

  /// Provides IAuthRepository implementation
  @lazySingleton
  IAuthRepository authRepository(
    AuthRemoteDataSource remoteDataSource,
    AuthLocalDataSource localDataSource,
  ) => AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );

  /// Provides IDeviceRepository implementation
  @lazySingleton
  IDeviceRepository deviceRepository(
    DeviceRemoteDataSource remoteDataSource,
    DeviceLocalDataSource localDataSource,
    NetworkInfo networkInfo,
    StatusService statusService,
  ) => DeviceRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    networkInfo: networkInfo,
    statusService: statusService,
  );

  /// Provides ITotemRepository implementation
  @lazySingleton
  ITotemRepository totemRepository(
    TotemRemoteDataSource remoteDataSource,
    TotemLocalDataSource localDataSource,
    NetworkInfo networkInfo,
    StatusService statusService,
  ) => TotemRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    networkInfo: networkInfo,
    statusService: statusService,
  );
}
