// File: lib/models/location.dart
import 'package:painel_windowns/models/unit.dart';

class Location {
  final String name;
  final List<IpRange> ipRanges;
  final String? description;
  final int deviceCount;
  final bool isOnline;
  final DateTime? lastSeen;

  Location({
    required this.name,
    List<IpRange>? ipRanges,
    this.description,
    this.deviceCount = 0,
    this.isOnline = false,
    this.lastSeen,
  }) : ipRanges = ipRanges ?? [];

  factory Location.fromJson(Map<String, dynamic> json) {
    // Parse múltiplas faixas de IP
    List<IpRange> ranges = [];

    // Primeiro tenta ler o array 'ip_ranges'
    if (json['ip_ranges'] != null && json['ip_ranges'] is List) {
      ranges =
          (json['ip_ranges'] as List)
              .map((i) => IpRange.fromJson(i as Map<String, dynamic>))
              .toList();
    }
    // Fallback para formato antigo (ip_range_start/end)
    else if (json['ip_range_start'] != null && json['ip_range_end'] != null) {
      ranges.add(
        IpRange(
          start: json['ip_range_start'] as String,
          end: json['ip_range_end'] as String,
        ),
      );
    }
    // Fallback para campo único 'ip_range'
    else if (json['ip_range'] != null || json['ipRange'] != null) {
      final ipRange = json['ip_range'] ?? json['ipRange'];
      ranges.add(IpRange(start: ipRange, end: ipRange));
    }

    return Location(
      name: json['name'] ?? json['unit_name'] ?? '',
      ipRanges: ranges,
      description: json['description'],
      deviceCount: json['device_count'] ?? json['deviceCount'] ?? 0,
      isOnline: json['is_online'] ?? json['isOnline'] ?? false,
      lastSeen:
          json['last_seen'] != null
              ? DateTime.tryParse(json['last_seen'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ip_ranges': ipRanges.map((r) => r.toJson()).toList(),
      'description': description,
      'device_count': deviceCount,
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
    };
  }

  /// Retorna uma string formatada com todas as faixas de IP
  String get ipRangesDisplay {
    if (ipRanges.isEmpty) return 'Nenhuma faixa de IP';
    if (ipRanges.length == 1) {
      final range = ipRanges.first;
      return range.start == range.end
          ? range.start
          : '${range.start} - ${range.end}';
    }
    return '${ipRanges.length} faixas de IP';
  }

  /// Retorna a primeira faixa de IP (para compatibilidade)
  String? get ipRange {
    if (ipRanges.isEmpty) return null;
    final range = ipRanges.first;
    return range.start == range.end
        ? range.start
        : '${range.start} - ${range.end}';
  }

  Location copyWith({
    String? name,
    List<IpRange>? ipRanges,
    String? description,
    int? deviceCount,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return Location(
      name: name ?? this.name,
      ipRanges: ipRanges ?? this.ipRanges,
      description: description ?? this.description,
      deviceCount: deviceCount ?? this.deviceCount,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
