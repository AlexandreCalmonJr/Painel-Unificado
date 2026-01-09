import 'dart:convert';
import 'package:painel_windowns/core/error/exceptions.dart';
import 'package:painel_windowns/data/models/totem_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Data Source local para totems (cache)
abstract class TotemLocalDataSource {
  Future<List<Totem>> getCachedTotems();
  Future<void> cacheTotems(List<Totem> totems);
  Future<void> clearCache();
}

class TotemLocalDataSourceImpl implements TotemLocalDataSource {

  TotemLocalDataSourceImpl({required this.sharedPreferences});
  final SharedPreferences sharedPreferences;
  static const String CACHED_TOTEMS = 'CACHED_TOTEMS';
  static const String CACHE_TIMESTAMP = 'TOTEMS_CACHE_TIMESTAMP';
  static const int CACHE_DURATION_MINUTES = 15;

  @override
  Future<List<Totem>> getCachedTotems() async {
    try {
      final timestamp = sharedPreferences.getInt(CACHE_TIMESTAMP);
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final difference = DateTime.now().difference(cacheTime).inMinutes;
        if (difference > CACHE_DURATION_MINUTES) {
          throw const CacheException(message: 'Cache expired');
        }
      }

      final jsonString = sharedPreferences.getString(CACHED_TOTEMS);
      if (jsonString != null) {
        final jsonList = json.decode(jsonString) as List<dynamic>;
        return jsonList
            .map((json) => Totem.fromJson(json as Map<String, dynamic>, [], []))
            .toList();
      } else {
        throw const CacheException(message: 'No cached totems found');
      }
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Error reading cache: $e');
    }
  }

  @override
  Future<void> cacheTotems(List<Totem> totems) async {
    try {
      final jsonList =
          totems
              .map(
                (totem) => {
                  '_id': totem.id,
                  'status': totem.status,
                  'location': totem.location,
                  'last_seen': totem.lastSeen.toIso8601String(),
                },
              )
              .toList();

      await sharedPreferences.setString(CACHED_TOTEMS, json.encode(jsonList));
      await sharedPreferences.setInt(
        CACHE_TIMESTAMP,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      throw CacheException(message: 'Error writing cache: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(CACHED_TOTEMS);
      await sharedPreferences.remove(CACHE_TIMESTAMP);
    } catch (e) {
      throw CacheException(message: 'Error clearing cache: $e');
    }
  }
}
