// File: lib/services/location_mapper_service.dart
import 'package:painel_windowns/models/bssid_mapping.dart';
import 'package:painel_windowns/models/desktop.dart';
import 'package:painel_windowns/models/totem.dart';
import 'package:painel_windowns/models/unit.dart';

/// Classe de resultado para o mapeamento de localização.
class MappedLocationResult {
  final String? unitName;
  final String? sector;
  final String? floor;
  final String finalLocationString;

  MappedLocationResult({
    this.unitName,
    this.sector,
    this.floor,
    required this.finalLocationString,
  });
}

/// Serviço universal para mapear localizações baseado em faixas de IP (Units)
/// e endereços MAC (BSSID Mappings).
class LocationMapperService {
  static get units => null;

  
  /// Mapeia localização completa de um dispositivo
  static LocationData mapLocation({
    required List<Unit> C,
    required String ip,
    required String macAddress,
    required String originalLocation,
    required List<Unit> units,
    required List<BssidMapping> bssidMappings,
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
        
        // Se o BSSID tem unitName e não encontramos por IP, usa do BSSID
        if (unitName == null && bssidMapping.unitName.isNotEmpty) {
          unitName = bssidMapping.unitName;
        }
      }
    }

    // 3. Constrói string final de localização
    String finalLocation = _buildLocationString(
      unitName: unitName ?? '',
      sector: sector,
      floor: floor,
      fallback: originalLocation,
    );
    
    return LocationData(
      locationName: finalLocation,
      unitName: unitName ?? '',
      sector: sector,
      floor: floor,
    );
  }

  /// Encontra o BssidMapping correspondente a um endereço MAC
  static BssidMapping? _findBssidMapping(
    String macAddress, 
    List<BssidMapping> mappings,
  ) {
    if (macAddress.isEmpty) return null;
    
    final normalizedMac = macAddress
        .toUpperCase()
        .replaceAll('-', ':')
        .replaceAll('.', ':');
    
    for (final mapping in mappings) {
      final normalizedMappingMac = mapping.macAddressRadio
          .toUpperCase()
          .replaceAll('-', ':')
          .replaceAll('.', ':');
      
      if (normalizedMappingMac == normalizedMac) {
        return mapping;
      }
    }
    return null;
  }

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

  /// Encontra a Unit correspondente a um endereço IP
  static Unit? findUnitByIp(String? ip, List<Unit> units) {
    if (ip == null || ip.isEmpty || ip == 'N/A') return null;
    
    for (final unit in units) {
      if (_isIpInRange(ip, unit.ipRanges)) {
        return unit;
      }
    }
    return null;
  }

  /// Encontra o BssidMapping correspondente a um endereço MAC
  static BssidMapping? findBssidMapping(
    String? macAddress, 
    List<BssidMapping> mappings,
  ) {
    return _findBssidMapping(macAddress ?? '', mappings);
  }

  /// Determina a localização mapeada com base nos dados fornecidos
  static MappedLocationResult getMappedLocation({
    required List<Unit> units,
    required List<BssidMapping> bssidMappings,
    required String? ip,
    required String? macAddress,
    required String? originalLocation,
  }) {
    final unit = findUnitByIp(ip, units);
    final bssidMapping = findBssidMapping(macAddress, bssidMappings);

    String? mappedUnitName;
    String? mappedSector;
    String? mappedFloor;

    // Prioriza Unit por IP
    if (unit != null) {
      mappedUnitName = unit.name;
    }

    // Adiciona dados do BSSID
    if (bssidMapping != null) {
      // Se não achou Unit por IP, tenta usar do BSSID
      if (mappedUnitName == null && bssidMapping.unitName.isNotEmpty) {
        mappedUnitName = bssidMapping.unitName;
      }
      
      if (bssidMapping.sector.isNotEmpty) {
        mappedSector = bssidMapping.sector;
      }
      
      if (bssidMapping.floor.isNotEmpty) {
        mappedFloor = bssidMapping.floor;
      }
    }

    // Constrói localização final
    final finalLocationStr = _buildLocationString(
      unitName: mappedUnitName,
      sector: mappedSector,
      floor: mappedFloor,
      fallback: originalLocation,
    );

    return MappedLocationResult(
      unitName: mappedUnitName,
      sector: mappedSector,
      floor: mappedFloor,
      finalLocationString: finalLocationStr,
    );
  }

  /// Atualiza localizações de totems
  static List<Totem> updateTotemsLocation({
    required List<Totem> totems,
    required List<Unit> units,
    required List<BssidMapping> bssidMappings,
  }) {
    return totems.map((totem) {
      final locationData = mapLocation(
        units: units,
        bssidMappings: bssidMappings,
        ip: totem.ipAddress ?? 'N/A',
        macAddress: totem.macAddress ?? 'N/A',
        originalLocation: totem.location ?? 'N/D', C: [],
      );

      return totem.copyWith(
        location: locationData.locationName,
        unit: locationData.unitName,
        sector: locationData.sector,
        floor: locationData.floor,
      );
    }).toList();
  }
}