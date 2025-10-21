// File: lib/services/location_mapper_service.dart
import 'package:painel_windowns/models/bssid_mapping.dart'; // Ajuste o import se necessário
import 'package:painel_windowns/models/totem.dart';
import 'package:painel_windowns/models/unit.dart';       // Ajuste o import se necessário

/// Classe de resultado para o mapeamento de localização.
class MappedLocationResult {
  final String? unitName;
  final String? sector;
  final String? floor;
  final String finalLocationString; // A string formatada final

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
  /// Verifica se um endereço IP está dentro de uma faixa definida (início e fim).
  static bool isIpInRange(String ip, String startIp, String endIp) {
    try {
      // (Implementação da função isIpInRange permanece a MESMA da versão anterior)
      final ipParts = ip.split('.').map(int.parse).toList();
      final startParts = startIp.split('.').map(int.parse).toList();
      final endParts = endIp.split('.').map(int.parse).toList();

      if (ipParts.length != 4 || startParts.length != 4 || endParts.length != 4) {
         print('LocationMapperService: Formato de IP inválido - ip: $ip, start: $startIp, end: $endIp');
        return false;
      }
      if ([...ipParts, ...startParts, ...endParts].any((part) => part < 0 || part > 255)) {
         print('LocationMapperService: Valor de octeto inválido - ip: $ip, start: $startIp, end: $endIp');
         return false;
      }
      final ipNum = (ipParts[0] << 24) + (ipParts[1] << 16) + (ipParts[2] << 8) + ipParts[3];
      final startNum = (startParts[0] << 24) + (startParts[1] << 16) + (startParts[2] << 8) + startParts[3];
      final endNum = (endParts[0] << 24) + (endParts[1] << 16) + (endParts[2] << 8) + endParts[3];
      if (startNum > endNum) {
          print('LocationMapperService: IP inicial ($startIp) é maior que o IP final ($endIp)');
          return false;
      }
      return ipNum >= startNum && ipNum <= endNum;
    } catch (e) {
      print('LocationMapperService: Erro ao processar IPs ($ip, $startIp, $endIp): $e');
      return false;
    }
  }

  /// Encontra a `Unit` (Unidade) correspondente a um dado endereço IP.
  static Unit? findUnitByIp(String? ip, List<Unit> units) {
    // (Implementação da função findUnitByIp permanece a MESMA)
    if (ip == null || ip.isEmpty) return null;
    for (final unit in units) {
      if (isIpInRange(ip, unit.ipRangeStart, unit.ipRangeEnd)) {
        return unit;
      }
    }
    return null;
  }

  /// Encontra o `BssidMapping` correspondente a um endereço MAC.
  static BssidMapping? findBssidMapping(String? macAddress, List<BssidMapping> mappings) {
    // (Implementação da função findBssidMapping permanece a MESMA)
     if (macAddress == null || macAddress.isEmpty) return null;
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

  /// Determina a localização mapeada com base nos dados fornecidos.
  ///
  /// Retorna um objeto `MappedLocationResult` contendo os detalhes mapeados
  /// e a string final formatada.
  static MappedLocationResult getMappedLocation({
    required List<Unit> units,
    required List<BssidMapping> bssidMappings,
    required String? ip,
    required String? macAddress,
    required String? originalLocation, // A localização que veio do JSON
  }) {
    final unit = findUnitByIp(ip, units);
    final bssidMapping = findBssidMapping(macAddress, bssidMappings);

    List<String> locationParts = [];
    String? mappedUnitName;
    String? mappedSector;
    String? mappedFloor;

    if (unit != null) {
      locationParts.add(unit.name);
      mappedUnitName = unit.name;
      // Poderia adicionar unit.sector/floor aqui se fizer sentido na sua lógica
    }

    if (bssidMapping != null) {
      // Se a unidade já adicionou o nome, usamos o setor/andar do BSSID
      if (unit == null && bssidMapping.unitName.isNotEmpty) {
          locationParts.add(bssidMapping.unitName); // Usa o nome da unidade do BSSID se não achou por IP
          mappedUnitName = bssidMapping.unitName;
      }
      if (bssidMapping.sector.isNotEmpty) {
        locationParts.add(bssidMapping.sector);
        mappedSector = bssidMapping.sector;
      }
      if (bssidMapping.floor.isNotEmpty) {
        locationParts.add(bssidMapping.floor);
        mappedFloor = bssidMapping.floor;
      }
    }
    
    // Junta as partes ou usa a localização original como fallback
    String finalLocationStr = locationParts.isNotEmpty
        ? locationParts.join(' - ')
        : (originalLocation ?? 'N/D'); // Usa N/D se originalLocation for nulo

    return MappedLocationResult(
      unitName: mappedUnitName,
      sector: mappedSector,
      floor: mappedFloor,
      finalLocationString: finalLocationStr,
    );
  }

  static List<Totem> updateTotemsLocation({required List<Totem> totems, required List<Unit> units, required List<BssidMapping> bssidMappings}) {
    // Retorna a lista recebida para garantir que a função não retorne nulo.
    // Se desejar, aqui pode-se iterar sobre `totems` e atualizar propriedades
    // com base em `getMappedLocation(...)` antes de retornar a lista.
    return totems;
  }
}