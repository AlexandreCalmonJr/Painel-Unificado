import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/exceptions.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/data/datasources/local/config_local_datasource.dart';
import 'package:painel_windowns/domain/repositories/i_config_repository.dart';

/// Implementação do repositório de configurações
class ConfigRepositoryImpl implements IConfigRepository {

  ConfigRepositoryImpl({required this.localDataSource});
  final ConfigLocalDataSource localDataSource;

  @override
  Future<Either<Failure, String>> getServerUrl() async {
    try {
      final url = await localDataSource.getServerUrl();
      if (url == null || url.isEmpty) {
        return const Left(CacheFailure(message: 'Server URL not configured'));
      }
      return Right(url);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveServerUrl(String url) async {
    try {
      await localDataSource.saveServerUrl(url);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getApiKey() async {
    try {
      final apiKey = await localDataSource.getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        return const Left(CacheFailure(message: 'API key not configured'));
      }
      return Right(apiKey);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveApiKey(String apiKey) async {
    try {
      await localDataSource.saveApiKey(apiKey);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAllSettings() async {
    try {
      final settings = await localDataSource.getAllSettings();
      return Right(settings);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveSetting(String key, dynamic value) async {
    try {
      await localDataSource.saveSetting(key, value);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, dynamic>> getSetting(String key) async {
    try {
      final value = await localDataSource.getSetting(key);
      if (value == null) {
        return Left(CacheFailure(message: 'Setting not found: $key'));
      }
      return Right(value);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearAllSettings() async {
    try {
      await localDataSource.clearAllSettings();
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }
}
