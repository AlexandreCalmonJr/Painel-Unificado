// File: lib/services/location_mapper_service.dart
import 'package:painel_windowns/models/bssid_mapping.dart';
import 'package:painel_windowns/models/unit.dart';


class LocationData {
  final String locationName;
  final String? unitName;
  final String? sector;
  final String? floor;

  LocationData({
    required this.locationName,
    this.unitName,
    this.sector,
    this.floor,
  });
}

class LocationMapperService {
  /// Mapeia localização completa de um dispositivo
  static LocationData mapLocation({
    required List<Unit> units,
    required List<BssidMapping> bssidMappings,
    required String ip,
    required String macAddress,
    required String originalLocation,
  }) {
    // 1. Tenta mapear pela Unidade (IP)
    String? unitName;
    if (ip != 'N/A' && ip.isNotEmpty) {
      for (final unit in units) {
        if (_isIpInRange(ip, unit.ipRanges)) {
          unitName = unit.name;
          break;
        }
      }
    }

    // 2. Tenta mapear Setor e Andar pelo BSSID (MAC Address)
    String? sector;
    String? floor;

    if (macAddress != 'N/A' && macAddress.isNotEmpty) {
      final bssidMapping = _findBssidMapping(macAddress, bssidMappings);

      if (bssidMapping != null) {
        sector = bssidMapping.sector.isNotEmpty ? bssidMapping.sector : null;
        floor = bssidMapping.floor.isNotEmpty ? bssidMapping.floor : null;

        // Se não encontrou Unit por IP, usa do BSSID
        if (unitName == null && bssidMapping.unitName.isNotEmpty) {
          unitName = bssidMapping.unitName;
        }
      }
    }

    // 3. Constrói string final de localização
    String finalLocation = _buildLocationString(
      unitName: unitName,
      sector: sector,
      floor: floor,
      fallback: originalLocation,
    );

    return LocationData(
      locationName: finalLocation,
      unitName: unitName,
      sector: sector,
      floor: floor,
    );
  }

  // ===================================================================
  // ✅ FUNÇÃO ATUALIZADA (COM LOGS E NORMALIZAÇÃO ROBUSTA)
  // ===================================================================
  static BssidMapping? _findBssidMapping(
    String macAddress,
    List<BssidMapping> mappings,
  ) {
    if (macAddress.isEmpty || macAddress == 'N/A') {
      print('⚠️ MAC Address inválido: "$macAddress"');
      return null;
    }

    // ✅ NORMALIZAÇÃO ROBUSTA
    final normalizedMac = macAddress
        .toUpperCase()
        .replaceAll('-', ':')
        .replaceAll('.', ':')
        .replaceAll(' ', ''); // ✅ REMOVE ESPAÇOS

    print('🔍 Procurando BSSID: $normalizedMac');
    print('   Total de BSSIDs no banco: ${mappings.length}');

    for (final mapping in mappings) {
      final normalizedMappingMac = mapping.macAddressRadio
          .toUpperCase()
          .replaceAll('-', ':')
          .replaceAll('.', ':')
          .replaceAll(' ', '');

      if (normalizedMappingMac == normalizedMac) {
        print('✅ BSSID ENCONTRADO: ${mapping.macAddressRadio}');
        print(
            '   Setor: ${mapping.sector}, Andar: ${mapping.floor}, Unidade: ${mapping.unitName}');
        return mapping;
      }
    }

    print('❌ BSSID NÃO ENCONTRADO: $normalizedMac');
    print('   BSSIDs disponíveis:');
    for (var m in mappings.take(5)) {
      // Mostra apenas os 5 primeiros
      print('   - ${m.macAddressRadio}');
    }

    return null;
  }
  // ===================================================================
  // FIM DA SEÇÃO ATUALIZADA
  // ===================================================================

  /// Constrói a string de localização formatada
  static String _buildLocationString({
    String? unitName,
    String? sector,
    String? floor,
    String? fallback,
  }) {
    List<String> parts = [];

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

  /// Verifica se um IP está dentro de uma faixa
  static bool _isIpInRange(String ip, List<IpRange> ranges) {
    try {
      final ipNum = _ipToInt(ip);
      for (final range in ranges) {
        final startNum = _ipToInt(range.start);
        final endNum = _ipToInt(range.end);
        if (ipNum >= startNum && ipNum <= endNum) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Converte IP string para inteiro
  static int _ipToInt(String ip) {
    final parts = ip.split('.').map(int.parse).toList();
    return (parts[0] << 24) + (parts[1] << 16) + (parts[2] << 8) + parts[3];
  }
}