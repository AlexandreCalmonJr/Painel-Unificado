// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:painel_windowns/core/di/app_module.dart' as _i836;
import 'package:painel_windowns/core/network/network_info.dart' as _i958;
import 'package:painel_windowns/data/datasources/local/device_local_datasource.dart'
    as _i1022;
import 'package:painel_windowns/data/datasources/remote/device_remote_datasource.dart'
    as _i1054;
import 'package:painel_windowns/data/datasources/remote/totem_remote_datasource.dart'
    as _i711;
import 'package:painel_windowns/domain/repositories/i_auth_repository.dart'
    as _i868;
import 'package:painel_windowns/domain/repositories/i_device_repository.dart'
    as _i576;
import 'package:painel_windowns/domain/repositories/i_totem_repository.dart'
    as _i888;
import 'package:painel_windowns/domain/usecases/auth/login_usecase.dart'
    as _i491;
import 'package:painel_windowns/domain/usecases/auth/logout_usecase.dart'
    as _i963;
import 'package:painel_windowns/domain/usecases/device/get_device_by_id_usecase.dart'
    as _i568;
import 'package:painel_windowns/domain/usecases/device/get_devices_usecase.dart'
    as _i848;
import 'package:painel_windowns/domain/usecases/device/send_command_usecase.dart'
    as _i849;
import 'package:painel_windowns/domain/usecases/device/update_device_usecase.dart'
    as _i138;
import 'package:painel_windowns/domain/usecases/totem/get_totem_by_id_usecase.dart'
    as _i567;
import 'package:painel_windowns/domain/usecases/totem/get_totems_usecase.dart'
    as _i407;
import 'package:painel_windowns/domain/usecases/totem/update_totem_usecase.dart'
    as _i1005;
import 'package:painel_windowns/presentation/bloc/auth/auth_bloc.dart' as _i931;
import 'package:painel_windowns/presentation/bloc/device/device_bloc.dart'
    as _i746;
import 'package:painel_windowns/presentation/bloc/totem/totem_bloc.dart'
    as _i738;
import 'package:painel_windowns/services/auth_service.dart' as _i474;
import 'package:painel_windowns/services/token_service.dart' as _i262;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.lazySingleton<_i474.AuthService>(() => appModule.authService);
    gh.lazySingleton<_i958.NetworkInfo>(() => appModule.networkInfo);
    gh.lazySingleton<_i1054.DeviceRemoteDataSource>(
      () => appModule.deviceRemoteDataSource,
    );
    gh.lazySingleton<_i1022.DeviceLocalDataSource>(
      () => appModule.deviceLocalDataSource,
    );
    gh.lazySingleton<_i711.TotemRemoteDataSource>(
      () => appModule.totemRemoteDataSource,
    );
    gh.lazySingleton<_i262.TokenService>(
      () => _i262.TokenService(gh<_i474.AuthService>()),
    );
    gh.lazySingleton<_i491.LoginUseCase>(
      () => _i491.LoginUseCase(gh<_i868.IAuthRepository>()),
    );
    gh.lazySingleton<_i963.LogoutUseCase>(
      () => _i963.LogoutUseCase(gh<_i868.IAuthRepository>()),
    );
    gh.lazySingleton<_i888.ITotemRepository>(
      () => appModule.totemRepository(
        gh<_i711.TotemRemoteDataSource>(),
        gh<_i958.NetworkInfo>(),
      ),
    );
    gh.factory<_i931.AuthBloc>(
      () => _i931.AuthBloc(
        loginUseCase: gh<_i491.LoginUseCase>(),
        logoutUseCase: gh<_i963.LogoutUseCase>(),
      ),
    );
    gh.lazySingleton<_i576.IDeviceRepository>(
      () => appModule.deviceRepository(
        gh<_i1054.DeviceRemoteDataSource>(),
        gh<_i1022.DeviceLocalDataSource>(),
        gh<_i958.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i568.GetDeviceByIdUseCase>(
      () => _i568.GetDeviceByIdUseCase(gh<_i576.IDeviceRepository>()),
    );
    gh.lazySingleton<_i849.SendCommandUseCase>(
      () => _i849.SendCommandUseCase(gh<_i576.IDeviceRepository>()),
    );
    gh.lazySingleton<_i138.UpdateDeviceUseCase>(
      () => _i138.UpdateDeviceUseCase(gh<_i576.IDeviceRepository>()),
    );
    gh.lazySingleton<_i407.GetTotemsUseCase>(
      () => _i407.GetTotemsUseCase(gh<_i888.ITotemRepository>()),
    );
    gh.lazySingleton<_i567.GetTotemByIdUseCase>(
      () => _i567.GetTotemByIdUseCase(gh<_i888.ITotemRepository>()),
    );
    gh.lazySingleton<_i1005.UpdateTotemUseCase>(
      () => _i1005.UpdateTotemUseCase(gh<_i888.ITotemRepository>()),
    );
    gh.lazySingleton<_i848.GetDevicesUseCase>(
      () => _i848.GetDevicesUseCase(
        gh<_i576.IDeviceRepository>(),
        gh<_i262.TokenService>(),
      ),
    );
    gh.factory<_i738.TotemBloc>(
      () => _i738.TotemBloc(getTotemsUseCase: gh<_i407.GetTotemsUseCase>()),
    );
    gh.factory<_i746.DeviceBloc>(
      () => _i746.DeviceBloc(getDevicesUseCase: gh<_i848.GetDevicesUseCase>()),
    );
    return this;
  }
}

class _$AppModule extends _i836.AppModule {}
