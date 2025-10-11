// File: lib/services/location_mapper_service.dart
import 'package:painel_windowns/models/bssid_mapping.dart';
import 'package:painel_windowns/models/totem.dart';
import 'package:painel_windowns/models/unit.dart';

/// Serviço universal para mapear localizações de dispositivos (totems e devices)
/// baseado em faixas de IP (Units) e endereços MAC (BSSID Mappings)
class LocationMapperService {
  /// Verifica se um IP está dentro de uma faixa de IP
  static bool isIpInRange(String ip, String startIp, String endIp) {
    try {
      final ipParts = ip.split('.').map(int.parse).toList();
      final startParts = startIp.split('.').map(int.parse).toList();
      final endParts = endIp.split('.').map(int.parse).toList();

      if (ipParts.length != 4 || startParts.length != 4 || endParts.length != 4) {
        return false;
      }

      // Converte IP para número único para comparação
      final ipNum = ipParts[0] * 16777216 + ipParts[1] * 65536 + ipParts[2] * 256 + ipParts[3];
      final startNum = startParts[0] * 16777216 + startParts[1] * 65536 + startParts[2] * 256 + startParts[3];
      final endNum = endParts[0] * 16777216 + endParts[1] * 65536 + endParts[2] * 256 + endParts[3];

      return ipNum >= startNum && ipNum <= endNum;
    } catch (e) {
      return false;
    }
  }

  /// Encontra a unidade correspondente ao IP do totem
  static Unit? findUnitByIp(String ip, List<Unit> units) {
    for (final unit in units) {
      if (isIpInRange(ip, unit.ipRangeStart, unit.ipRangeEnd)) {
        return unit;
      }
    }
    return null;
  }

  /// Encontra o mapeamento BSSID correspondente ao MAC do totem
  static BssidMapping? findBssidMapping(String macAddress, List<BssidMapping> mappings) {
    // Normaliza o MAC address (remove hífens, coloca em maiúsculo)
    final normalizedMac = macAddress.toUpperCase().replaceAll('-', ':');
    
    for (final mapping in mappings) {
      if (mapping.macAddressRadio.toUpperCase() == normalizedMac) {
        return mapping;
      }
    }
    return null;
  }

  /// Atualiza a localização do totem baseado nos mapeamentos
  static String getTotemLocation({
    required Totem totem,
    required List<Unit> units,
    required List<BssidMapping> bssidMappings,
  }) {
    // Tenta encontrar a unidade pelo IP
    final unit = findUnitByIp(totem.ip, units);
    
    // Tenta encontrar o mapeamento BSSID
    BssidMapping? bssidMapping;
    if (totem.macAddress.isNotEmpty) {
      bssidMapping = findBssidMapping(totem.macAddress, bssidMappings);
    }

    // Constrói a localização combinada
    String location = '';

    if (unit != null) {
      location = unit.name;
    }

    if (bssidMapping != null) {
      if (location.isNotEmpty) {
        location += ' - ${bssidMapping.sector} - ${bssidMapping.floor}';
      } else {
        location = '${bssidMapping.sector} - ${bssidMapping.floor}';
      }
    }

    // Se não encontrou nenhum mapeamento, retorna a localização original
    return location.isNotEmpty ? location : totem.location;
  }

  /// Atualiza a localização de uma lista de totems
  static List<Totem> updateTotemsLocation({
    required List<Totem> totems,
    required List<Unit> units,
    required List<BssidMapping> bssidMappings,
  }) {
    return totems.map((totem) {
      final newLocation = getTotemLocation(
        totem: totem,
        units: units,
        bssidMappings: bssidMappings,
      );

      // Usa o método copyWith para criar um novo totem com a localização atualizada
      return totem.copyWith(location: newLocation);
    }).toList();
  }
}