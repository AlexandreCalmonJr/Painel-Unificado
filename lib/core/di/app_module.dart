import 'package:injectable/injectable.dart';
import 'package:painel_windowns/core/network/network_info.dart';
import 'package:painel_windowns/data/datasources/local/device_local_datasource.dart';
import 'package:painel_windowns/data/datasources/remote/device_remote_datasource.dart';
import 'package:painel_windowns/data/datasources/remote/totem_remote_datasource.dart';
import 'package:painel_windowns/data/repositories/device_repository_impl.dart';
import 'package:painel_windowns/data/repositories/totem_repository_impl.dart';
import 'package:painel_windowns/domain/repositories/i_device_repository.dart';
import 'package:painel_windowns/domain/repositories/i_totem_repository.dart';
import 'package:painel_windowns/services/auth_service.dart';

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

  /// Provides DeviceRemoteDataSource
  @lazySingleton
  DeviceRemoteDataSource get deviceRemoteDataSource => DeviceRemoteDataSource();

  /// Provides DeviceLocalDataSource
  @lazySingleton
  DeviceLocalDataSource get deviceLocalDataSource => DeviceLocalDataSource();

  /// Provides TotemRemoteDataSource
  @lazySingleton
  TotemRemoteDataSource get totemRemoteDataSource => TotemRemoteDataSource();

  /// Provides IDeviceRepository implementation
  @lazySingleton
  IDeviceRepository deviceRepository(
    DeviceRemoteDataSource remoteDataSource,
    DeviceLocalDataSource localDataSource,
    NetworkInfo networkInfo,
  ) => DeviceRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    networkInfo: networkInfo,
  );

  /// Provides ITotemRepository implementation
  @lazySingleton
  ITotemRepository totemRepository(
    TotemRemoteDataSource remoteDataSource,
    NetworkInfo networkInfo,
  ) => TotemRepositoryImpl(
    remoteDataSource: remoteDataSource,
    networkInfo: networkInfo,
  );
}
