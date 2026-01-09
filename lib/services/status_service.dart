import 'package:painel_windowns/core/cache/status_cache.dart';

/// Serviço para gerenciar e validar status de dispositivos
///
/// Implementa lógica de tolerância e debounce para evitar
/// alternância rápida de status online/offline.
class StatusService {
  /// Tolerância para considerar dispositivo online
  /// Se lastSeen foi há menos de 5 minutos, considera online
  static const Duration onlineTolerance = Duration(minutes: 5);

  /// Tempo de debounce para mudanças de status
  /// Evita mudanças muito rápidas (spam de alertas)
  static const Duration statusDebounce = Duration(seconds: 30);

  /// Cache de status por dispositivo (key = deviceId)
  final Map<String, StatusCache> _statusCache = {};

  /// Calcula o status validado de um dispositivo
  ///
  /// Lógica:
  /// 1. Valida lastSeen (se existe e é válido)
  /// 2. Calcula diferença com DateTime.now()
  /// 3. Aplica tolerância de 5 minutos
  /// 4. Compara com status anterior (debounce)
  /// 5. Retorna status validado
  ///
  /// [deviceId] - ID único do dispositivo
  /// [lastSeen] - String de data/hora do último contato
  /// [serverStatus] - Status reportado pelo servidor
  /// [forceUpdate] - Força atualização ignorando debounce
  String calculateStatus(
    String deviceId,
    String? lastSeen,
    String? serverStatus, {
    bool forceUpdate = false,
  }) {
    // 1. Calcular status baseado em lastSeen
    final calculatedStatus = _calculateStatusFromLastSeen(lastSeen);

    // 2. Se não conseguiu calcular, usar status do servidor
    final newStatus = calculatedStatus ?? serverStatus ?? 'offline';

    // 3. Verificar cache e aplicar debounce
    if (!forceUpdate && _statusCache.containsKey(deviceId)) {
      final cache = _statusCache[deviceId]!;

      // Verificar se deve atualizar (debounce)
      if (!cache.shouldUpdate(newStatus, statusDebounce)) {
        // Manter status atual (debounce ativo)
        return cache.status;
      }

      // Atualizar cache
      _statusCache[deviceId] = cache.update(newStatus);

      // Resetar contador se passou tempo suficiente sem mudanças
      final timeSinceLastChange = DateTime.now().difference(cache.timestamp);
      if (timeSinceLastChange > const Duration(minutes: 10)) {
        _statusCache[deviceId] = _statusCache[deviceId]!.resetChangeCount();
      }
    } else {
      // Primeira vez vendo este dispositivo, criar cache
      _statusCache[deviceId] = StatusCache(
        status: newStatus,
        timestamp: DateTime.now(),
        changeCount: 0,
      );
    }

    return newStatus;
  }

  /// Calcula status baseado apenas no lastSeen
  ///
  /// Retorna null se lastSeen for inválido
  String? _calculateStatusFromLastSeen(String? lastSeen) {
    if (lastSeen == null || lastSeen.isEmpty || lastSeen == 'N/A') {
      return null;
    }

    try {
      // Tentar parsear a data
      final lastSeenDate = DateTime.tryParse(lastSeen);
      if (lastSeenDate == null) {
        return null;
      }

      // Calcular diferença com agora
      final now = DateTime.now();
      final difference = now.difference(lastSeenDate);

      // Aplicar tolerância
      if (difference <= onlineTolerance) {
        return 'online';
      } else {
        return 'offline';
      }
    } catch (e) {
      // Erro ao parsear, retornar null
      return null;
    }
  }

  /// Limpa o cache de um dispositivo específico
  void clearCache(String deviceId) {
    _statusCache.remove(deviceId);
  }

  /// Limpa todo o cache
  void clearAllCache() {
    _statusCache.clear();
  }

  /// Obtém o cache de um dispositivo (para debug)
  StatusCache? getCache(String deviceId) {
    return _statusCache[deviceId];
  }

  /// Obtém estatísticas do cache (para monitoramento)
  Map<String, dynamic> getCacheStats() {
    final totalDevices = _statusCache.length;
    final oscillatingDevices =
        _statusCache.values.where((cache) => cache.changeCount >= 3).length;

    return {
      'total_devices': totalDevices,
      'oscillating_devices': oscillatingDevices,
      'cache_size': _statusCache.length,
    };
  }

  /// Valida se um dispositivo está oscilando demais
  bool isOscillating(String deviceId) {
    final cache = _statusCache[deviceId];
    if (cache == null) return false;

    return cache.changeCount >= 3;
  }
}
