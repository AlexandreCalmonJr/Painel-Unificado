import 'package:painel_windowns/data/models/bssid_mapping.dart';
import 'package:painel_windowns/data/models/unit_model.dart';

/// Classe para armazenar dados de localização mapeados
class LocationData {
  LocationData({
    required this.unitName,
    required this.sector,
    required this.floor,
    required this.locationName,
  });
  final String unitName;
  final String sector;
  final String floor;
  final String locationName;
}

class LocationMapperService {
  /// Normaliza o MAC Address (remove separadores e converte para uppercase)
  static String? normalizeMac(String? mac) {
    if (mac == null || mac.isEmpty || mac == 'N/A') return null;

    // Remove tudo que não for hex
    String normalized =
        mac.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '').toUpperCase();

    // Se tiver 12 caracteres, formata com :
    if (normalized.length == 12) {
      final buffer = StringBuffer();
      for (int i = 0; i < 12; i += 2) {
        buffer.write(normalized.substring(i, i + 2));
        if (i < 10) buffer.write(':');
      }
      return buffer.toString();
    }

    return null; // Formato inválido
  }

  /// Obtém o prefixo do MAC (primeiros 14 caracteres: AA:BB:CC:DD)
  static String? getMacPrefix(String? mac) {
    final normalized = normalizeMac(mac);
    if (normalized == null) return null;

    // Retorna os primeiros 14 caracteres (4 octetos + 3 separadores)
    if (normalized.length >= 14) {
      return normalized.substring(0, 14);
    }
    return null;
  }

  /// Mapeia a localização de um dispositivo baseado em BSSID ou IP
  static LocationData mapLocation({
    required List<Unit> units,
    required List<BssidMapping> bssidMappings,
    required String ip,
    required String macAddress,
    required String originalLocation,
  }) {
    String? unitName;
    String? sector;
    String? floor;

    // 1️⃣ Tentar mapear por BSSID (WiFi MAC Address)
    final normalizedMac = normalizeMac(macAddress);
    final macPrefix = getMacPrefix(macAddress);

    if (normalizedMac != null) {
      // Tenta busca exata primeiro
      BssidMapping? match;

      try {
        match = bssidMappings.firstWhere(
          (mapping) => normalizeMac(mapping.macAddressRadio) == normalizedMac,
        );
      } catch (_) {
        // Não encontrou exato
      }

      // Se não encontrou exato, tenta por prefixo
      if (match == null && macPrefix != null) {
        try {
          match = bssidMappings.firstWhere((mapping) {
            final mappingPrefix = getMacPrefix(mapping.macAddressRadio);
            return mappingPrefix == macPrefix;
          });
        } catch (_) {
          // Não encontrou por prefixo
        }
      }

      if (match != null) {
        unitName = match.unitName.isNotEmpty ? match.unitName : null;
        sector = match.sector.isNotEmpty ? match.sector : null;
        floor = match.floor.isNotEmpty ? match.floor : null;
      }
    }

    // 2️⃣ Se BSSID não funcionou, tentar mapear por IP
    if (unitName == null && ip.isNotEmpty && ip != 'N/A') {
      for (final unit in units) {
        if (_isIpInRangeStatic(ip, unit.ipRanges)) {
          unitName = unit.name;
          break;
        }
      }
    }

    // 3️⃣ Construir a string de localização
    final locationName = _buildLocationStringStatic(
      unitName: unitName,
      sector: sector,
      floor: floor,
      fallback: originalLocation,
    );

    return LocationData(
      unitName: unitName ?? 'Desconhecido',
      sector: sector ?? 'Desconhecido',
      floor: floor ?? 'Desconhecido',
      locationName: locationName,
    );
  }

  /// Constrói a string de localização formatada (versão estática)
  static String _buildLocationStringStatic({
    String? unitName,
    String? sector,
    String? floor,
    String? fallback,
  }) {
    final List<String> parts = [];

    if (unitName != null && unitName.isNotEmpty) {
      parts.add(unitName);
    }

    if (sector != null && sector.isNotEmpty) {
      parts.add(sector);
    }

    if (floor != null && floor.isNotEmpty) {
      parts.add(floor);
    }

    if (parts.isEmpty) {
      return fallback ?? 'N/D';
    }

    return parts.join(' - ');
  }

  /// Verifica se um IP está dentro de uma faixa (versão estática)
  static bool _isIpInRangeStatic(String ip, List<IpRange> ranges) {
    try {
      final ipNum = _ipToIntStatic(ip);
      for (final range in ranges) {
        final startNum = _ipToIntStatic(range.start);
        final endNum = _ipToIntStatic(range.end);
        if (ipNum >= startNum && ipNum <= endNum) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Converte IP string para inteiro (versão estática)
  static int _ipToIntStatic(String ip) {
    final parts = ip.split('.').map(int.parse).toList();
    return (parts[0] << 24) + (parts[1] << 16) + (parts[2] << 8) + parts[3];
  }
}
