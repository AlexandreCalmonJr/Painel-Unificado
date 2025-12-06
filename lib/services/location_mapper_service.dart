import 'package:painel_windowns/models/bssid_mapping.dart';
import 'package:painel_windowns/models/unit.dart';

/// Classe para armazenar dados de localização mapeados
class LocationData {
  final String unitName;
  final String sector;
  final String floor;
  final String locationName;

  LocationData({
    required this.unitName,
    required this.sector,
    required this.floor,
    required this.locationName,
  });
}

class LocationMapperService {
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

    // 1️⃣ Tentar mapear por BSSID (WiFi MAC Address) primeiro
    if (macAddress.isNotEmpty && macAddress != 'N/A') {
      final bssidMatch = bssidMappings.firstWhere(
        (mapping) =>
            mapping.macAddressRadio.toLowerCase() == macAddress.toLowerCase(),
        orElse:
            () => BssidMapping(
              macAddressRadio: '',
              sector: '',
              floor: '',
              unitName: '',
            ),
      );

      if (bssidMatch.macAddressRadio.isNotEmpty) {
        unitName = bssidMatch.unitName.isNotEmpty ? bssidMatch.unitName : null;
        sector = bssidMatch.sector.isNotEmpty ? bssidMatch.sector : null;
        floor = bssidMatch.floor.isNotEmpty ? bssidMatch.floor : null;
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
