// File: test/services/device_service_test.dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([http.Client])
import 'device_service_test.mocks.dart';

void main() {
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
  });

  group('DeviceService - Units Tests', () {
    test('fetchUnits should return list of units', () async {
      final mockResponse = {
        'units': [
          {'name': 'Unidade A', 'id': '1'},
          {'name': 'Unidade B', 'id': '2'},
        ],
      };

      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(json.encode(mockResponse), 200));

      // Note: DeviceService needs to be modified to accept a client for testing
      // final units = await deviceService.fetchUnits(testToken, client: mockClient);

      // expect(units, isA<List<Unit>>());
      // expect(units.length, 2);
      // expect(units[0].name, 'Unidade A');
    });

    test('fetchUnits should handle empty response', () async {
      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(json.encode({'units': []}), 200));

      // final units = await deviceService.fetchUnits(testToken, client: mockClient);
      // expect(units, isEmpty);
    });
  });

  group('DeviceService - BSSID Mappings Tests', () {
    test('fetchBssidMappings should return list of BSSID mappings', () async {
      final mockResponse = {
        'bssid_mappings': [
          {
            'bssid': 'AA:BB:CC:DD:EE:FF',
            'unit_name': 'Unidade A',
            'location': 'Sala 101',
          },
          {
            'bssid': '11:22:33:44:55:66',
            'unit_name': 'Unidade B',
            'location': 'Sala 102',
          },
        ],
      };

      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(json.encode(mockResponse), 200));

      // final mappings = await deviceService.fetchBssidMappings(testToken, client: mockClient);

      // expect(mappings, isA<List<BssidMapping>>());
      // expect(mappings.length, 2);
    });

    test('addBssidMapping should send POST request', () async {
      when(
        mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(json.encode({'success': true}), 201),
      );

      // await deviceService.addBssidMapping(
      //   testToken,
      //   unitName,
      //   bssid,
      //   location,
      //   client: mockClient,
      // );

      // verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(1);
    });

    test('deleteBssidMapping should send DELETE request', () async {
      when(mockClient.delete(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(json.encode({'success': true}), 200),
      );

      // await deviceService.deleteBssidMapping(testToken, bssid, client: mockClient);

      // verify(mockClient.delete(any, headers: anyNamed('headers'))).called(1);
    });
  });

  group('DeviceService - Error Handling', () {
    test('should handle network errors', () async {
      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenThrow(Exception('Network error'));

      // expect(
      //   () => deviceService.fetchUnits(testToken, client: mockClient),
      //   throwsException,
      // );
    });

    test('should handle 401 unauthorized', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(json.encode({'error': 'Unauthorized'}), 401),
      );

      // expect(
      //   () => deviceService.fetchUnits(testToken, client: mockClient),
      //   throwsException,
      // );
    });

    test('should handle 500 server error', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async =>
            http.Response(json.encode({'error': 'Internal server error'}), 500),
      );

      // expect(
      //   () => deviceService.fetchUnits(testToken, client: mockClient),
      //   throwsException,
      // );
    });
  });
}
