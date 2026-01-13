// File: lib/services/asset_cache_service.dart

import 'package:painel_windowns/data/models/asset_module_base_model.dart'; // ? IMPORT ADICIONADO

class AssetCacheService {
  factory AssetCacheService() => _instance;
  AssetCacheService._internal();
  static final AssetCacheService _instance = AssetCacheService._internal();

  final Map<String, List<ManagedAsset>> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheDuration = const Duration(minutes: 5); // ? Adicionado 'const'

  /// Armazena assets em cache
  void cacheAssets(String moduleId, List<ManagedAsset> assets) {
    _cache[moduleId] = assets;
    _cacheTimestamps[moduleId] = DateTime.now();
  }

  /// Recupera assets do cache (se válido)
  List<ManagedAsset>? getCachedAssets(String moduleId) {
    if (!_cache.containsKey(moduleId)) return null;

    final timestamp = _cacheTimestamps[moduleId]!;
    if (DateTime.now().difference(timestamp) > _cacheDuration) {
      // Cache expirado
      _cache.remove(moduleId);
      _cacheTimestamps.remove(moduleId);
      return null;
    }

    return _cache[moduleId];
  }

  /// Invalida cache de um módulo específico
  void invalidate(String moduleId) {
    _cache.remove(moduleId);
    _cacheTimestamps.remove(moduleId);
  }

  /// Limpa todo o cache
  void clearAll() {
    _cache.clear();
    _cacheTimestamps.clear();
  }
}
