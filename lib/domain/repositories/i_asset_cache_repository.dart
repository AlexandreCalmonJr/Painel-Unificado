import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/failures.dart';

/// Interface do repositório de cache de assets
abstract class IAssetCacheRepository {
  Future<Either<Failure, Map<String, dynamic>>> getCachedAsset(String assetId);
  Future<Either<Failure, Unit>> cacheAsset(
    String assetId,
    Map<String, dynamic> data,
  );
  Future<Either<Failure, Unit>> clearAssetCache(String assetId);
  Future<Either<Failure, Unit>> clearAllAssets();
  Future<Either<Failure, List<String>>> getCachedAssetIds();
}
