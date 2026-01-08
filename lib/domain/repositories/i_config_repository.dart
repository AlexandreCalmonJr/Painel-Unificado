import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/failures.dart';

/// Interface do repositório de configurações
abstract class IConfigRepository {
  Future<Either<Failure, String>> getServerUrl();
  Future<Either<Failure, Unit>> saveServerUrl(String url);
  Future<Either<Failure, String>> getApiKey();
  Future<Either<Failure, Unit>> saveApiKey(String apiKey);
  Future<Either<Failure, Map<String, dynamic>>> getAllSettings();
  Future<Either<Failure, Unit>> saveSetting(String key, dynamic value);
  Future<Either<Failure, dynamic>> getSetting(String key);
  Future<Either<Failure, Unit>> clearAllSettings();
}
