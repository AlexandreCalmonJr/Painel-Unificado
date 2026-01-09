/// Helper class para cache de status de dispositivos
///
/// Mantém histórico de mudanças de status para implementar debounce
/// e detectar oscilação excessiva.
class StatusCache {

  const StatusCache({
    required this.status,
    required this.timestamp,
    this.changeCount = 0,
    this.lastChangeTimestamp,
  });
  /// Status atual em cache
  final String status;

  /// Timestamp da última atualização
  final DateTime timestamp;

  /// Contador de mudanças de status (para detectar oscilação)
  final int changeCount;

  /// Timestamp da última mudança de status
  final DateTime? lastChangeTimestamp;

  /// Verifica se o status deve ser atualizado
  ///
  /// Considera:
  /// - Tempo desde última mudança (debounce)
  /// - Se o status realmente mudou
  /// - Se não está oscilando demais (mais de 3 mudanças em 5 minutos)
  bool shouldUpdate(String newStatus, Duration debounce) {
    // Se o status não mudou, não precisa atualizar
    if (status == newStatus) {
      return false;
    }

    final now = DateTime.now();

    // Verificar debounce: passou tempo suficiente desde a última mudança?
    if (lastChangeTimestamp != null) {
      final timeSinceLastChange = now.difference(lastChangeTimestamp!);
      if (timeSinceLastChange < debounce) {
        // Ainda no período de debounce, não atualizar
        return false;
      }
    }

    // Verificar oscilação excessiva
    // Se houve mais de 3 mudanças nos últimos 5 minutos, algo está errado
    if (changeCount >= 3) {
      final timeSinceFirstChange = now.difference(timestamp);
      if (timeSinceFirstChange < const Duration(minutes: 5)) {
        // Oscilando demais, manter status atual
        return false;
      }
    }

    return true;
  }

  /// Cria uma nova instância com status atualizado
  StatusCache copyWith({
    String? status,
    DateTime? timestamp,
    int? changeCount,
    DateTime? lastChangeTimestamp,
  }) {
    return StatusCache(
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      changeCount: changeCount ?? this.changeCount,
      lastChangeTimestamp: lastChangeTimestamp ?? this.lastChangeTimestamp,
    );
  }

  /// Atualiza o cache com novo status
  StatusCache update(String newStatus) {
    final now = DateTime.now();

    // Se o status mudou, incrementar contador e atualizar timestamp
    if (status != newStatus) {
      return StatusCache(
        status: newStatus,
        timestamp: now,
        changeCount: changeCount + 1,
        lastChangeTimestamp: now,
      );
    }

    // Status não mudou, apenas atualizar timestamp
    return copyWith(timestamp: now);
  }

  /// Reseta o contador de mudanças (após período de estabilidade)
  StatusCache resetChangeCount() {
    return copyWith(changeCount: 0);
  }

  @override
  String toString() {
    return 'StatusCache(status: $status, timestamp: $timestamp, changeCount: $changeCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StatusCache &&
        other.status == status &&
        other.timestamp == timestamp &&
        other.changeCount == changeCount &&
        other.lastChangeTimestamp == lastChangeTimestamp;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        timestamp.hashCode ^
        changeCount.hashCode ^
        (lastChangeTimestamp?.hashCode ?? 0);
  }
}
