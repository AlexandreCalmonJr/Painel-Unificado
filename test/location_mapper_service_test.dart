import 'package:flutter_test/flutter_test.dart';
import 'package:painel_windowns/data/models/bssid_mapping.dart';
import 'package:painel_windowns/data/models/unit_model.dart';
import 'package:painel_windowns/services/location_mapper_service.dart';

void main() {
  group('LocationMapperService Tests', () {
    late List<Unit> testUnits;
    late List<BssidMapping> testBssidMappings;

    setUp(() {
      // Configurar unidades de teste com faixas de IP
      testUnits = [
        Unit(
          id: '1',
          name: 'Unidade Centro',
          ipRanges: [IpRange(start: '192.168.1.1', end: '192.168.1.255')],
        ),
        Unit(
          id: '2',
          name: 'Unidade Norte',
          ipRanges: [IpRange(start: '192.168.2.1', end: '192.168.2.255')],
        ),
      ];

      // Configurar mapeamentos BSSID de teste
      testBssidMappings = [
        BssidMapping(
          macAddressRadio: 'AA:BB:CC:DD:EE:FF',
          sector: 'TI',
          floor: '3º Andar',
          unitName: 'Unidade Centro',
        ),
        BssidMapping(
          macAddressRadio: '11:22:33:44:55:66',
          sector: 'RH',
          floor: '2º Andar',
          unitName: 'Unidade Norte',
        ),
      ];
    });

    test('Deve mapear localização por BSSID corretamente', () {
      final result = LocationMapperService.mapLocation(
        units: testUnits,
        bssidMappings: testBssidMappings,
        ip: '192.168.1.100',
        macAddress: 'AA:BB:CC:DD:EE:FF',
        originalLocation: 'N/D',
      );

      expect(result.unitName, equals('Unidade Centro'));
      expect(result.sector, equals('TI'));
      expect(result.floor, equals('3º Andar'));
      expect(result.locationName, contains('Unidade Centro'));
      expect(result.locationName, contains('TI'));
      expect(result.locationName, contains('3º Andar'));
    });

    test('Deve mapear localização por IP quando BSSID não está disponível', () {
      final result = LocationMapperService.mapLocation(
        units: testUnits,
        bssidMappings: testBssidMappings,
        ip: '192.168.2.50',
        macAddress: 'N/A',
        originalLocation: 'N/D',
      );

      expect(result.unitName, equals('Unidade Norte'));
      expect(result.sector, equals('Desconhecido'));
      expect(result.floor, equals('Desconhecido'));
    });

    test('Deve retornar valores padrão quando não encontrar mapeamento', () {
      final result = LocationMapperService.mapLocation(
        units: testUnits,
        bssidMappings: testBssidMappings,
        ip: '10.0.0.1',
        macAddress: 'FF:FF:FF:FF:FF:FF',
        originalLocation: 'Localização Original',
      );

      expect(result.unitName, equals('Desconhecido'));
      expect(result.sector, equals('Desconhecido'));
      expect(result.floor, equals('Desconhecido'));
      expect(result.locationName, equals('Localização Original'));
    });

    test('Deve ser case-insensitive ao comparar MAC addresses', () {
      final result = LocationMapperService.mapLocation(
        units: testUnits,
        bssidMappings: testBssidMappings,
        ip: '192.168.1.100',
        macAddress: 'aa:bb:cc:dd:ee:ff', // lowercase
        originalLocation: 'N/D',
      );

      expect(result.unitName, equals('Unidade Centro'));
      expect(result.sector, equals('TI'));
    });

    test('Deve priorizar BSSID sobre IP quando ambos estão disponíveis', () {
      final result = LocationMapperService.mapLocation(
        units: testUnits,
        bssidMappings: testBssidMappings,
        ip: '192.168.2.100', // IP da Unidade Norte
        macAddress: 'AA:BB:CC:DD:EE:FF', // BSSID da Unidade Centro
        originalLocation: 'N/D',
      );

      // Deve usar o BSSID (Unidade Centro), não o IP (Unidade Norte)
      expect(result.unitName, equals('Unidade Centro'));
      expect(result.sector, equals('TI'));
    });

    test('Deve construir locationName formatado corretamente', () {
      final result = LocationMapperService.mapLocation(
        units: testUnits,
        bssidMappings: testBssidMappings,
        ip: '192.168.1.100',
        macAddress: '11:22:33:44:55:66',
        originalLocation: 'N/D',
      );

      expect(result.locationName, equals('Unidade Norte - RH - 2º Andar'));
    });
  });
}
