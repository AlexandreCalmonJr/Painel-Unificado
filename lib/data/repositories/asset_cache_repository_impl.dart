import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/exceptions.dart';
import 'package:painel_windowns/core/error/failures.dart';
import 'package:painel_windowns/data/datasources/local/asset_cache_datasource.dart';
import 'package:painel_windowns/domain/repositories/i_asset_cache_repository.dart';

/// Implementação do repositório de cache de assets
class AssetCacheRepositoryImpl implements IAssetCacheRepository {

  AssetCacheRepositoryImpl({required this.localDataSource});
  final AssetCacheDataSource localDataSource;

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCachedAsset(
    String assetId,
  ) async {
    try {
      final asset = await localDataSource.getCachedAsset(assetId);
      if (asset == null) {
        return const Left(CacheFailure(message: 'Asset not found in cache'));
      }
      return Right(asset);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> cacheAsset(
    String assetId,
    Map<String, dynamic> data,
  ) async {
    try {
      await localDataSource.cacheAsset(assetId, data);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearAssetCache(String assetId) async {
    try {
      await localDataSource.clearAssetCache(assetId);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearAllAssets() async {
    try {
      await localDataSource.clearAllAssets();
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCachedAssetIds() async {
    try {
      final ids = await localDataSource.getCachedAssetIds();
      return Right(ids);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error: $e'));
    }
  }
}
