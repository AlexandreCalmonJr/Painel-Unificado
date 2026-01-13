import 'dart:convert';

import 'package:painel_windowns/core/error/exceptions.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Data Source local para cache genérico de assets
abstract class AssetCacheDataSource {
  Future<Map<String, dynamic>?> getCachedAsset(String assetId);
  Future<void> cacheAsset(String assetId, Map<String, dynamic> data);
  Future<void> clearAssetCache(String assetId);
  Future<void> clearAllAssets();
  Future<List<String>> getCachedAssetIds();
}

class AssetCacheDataSourceImpl implements AssetCacheDataSource {

  AssetCacheDataSourceImpl({required this.sharedPreferences});
  final SharedPreferences sharedPreferences;
  static const String ASSET_PREFIX = 'ASSET_CACHE_';
  static const String ASSET_TIMESTAMP_PREFIX = 'ASSET_TS_';
  static const int CACHE_DURATION_MINUTES = 30;

  @override
  Future<Map<String, dynamic>?> getCachedAsset(String assetId) async {
    try {
      final timestampKey = '$ASSET_TIMESTAMP_PREFIX$assetId';
      final timestamp = sharedPreferences.getInt(timestampKey);

      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final difference = DateTime.now().difference(cacheTime).inMinutes;
        if (difference > CACHE_DURATION_MINUTES) {
          await clearAssetCache(assetId);
          return null;
        }
      }

      final cacheKey = '$ASSET_PREFIX$assetId';
      final jsonString = sharedPreferences.getString(cacheKey);

      if (jsonString != null) {
        return json.decode(jsonString) as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      throw CacheException(message: 'Error reading cached asset: $e');
    }
  }

  @override
  Future<void> cacheAsset(String assetId, Map<String, dynamic> data) async {
    try {
      final cacheKey = '$ASSET_PREFIX$assetId';
      final timestampKey = '$ASSET_TIMESTAMP_PREFIX$assetId';

      await sharedPreferences.setString(cacheKey, json.encode(data));
      await sharedPreferences.setInt(
        timestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      throw CacheException(message: 'Error caching asset: $e');
    }
  }

  @override
  Future<void> clearAssetCache(String assetId) async {
    try {
      final cacheKey = '$ASSET_PREFIX$assetId';
      final timestampKey = '$ASSET_TIMESTAMP_PREFIX$assetId';

      await sharedPreferences.remove(cacheKey);
      await sharedPreferences.remove(timestampKey);
    } catch (e) {
      throw CacheException(message: 'Error clearing asset cache: $e');
    }
  }

  @override
  Future<void> clearAllAssets() async {
    try {
      final keys = sharedPreferences.getKeys();
      for (final key in keys) {
        if (key.startsWith(ASSET_PREFIX) ||
            key.startsWith(ASSET_TIMESTAMP_PREFIX)) {
          await sharedPreferences.remove(key);
        }
      }
    } catch (e) {
      throw CacheException(message: 'Error clearing all assets: $e');
    }
  }

  @override
  Future<List<String>> getCachedAssetIds() async {
    try {
      final keys = sharedPreferences.getKeys();
      final assetIds = <String>[];

      for (final key in keys) {
        if (key.startsWith(ASSET_PREFIX)) {
          final assetId = key.substring(ASSET_PREFIX.length);
          assetIds.add(assetId);
        }
      }

      return assetIds;
    } catch (e) {
      throw CacheException(message: 'Error getting cached asset IDs: $e');
    }
  }
}
