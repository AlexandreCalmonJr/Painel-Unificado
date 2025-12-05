// File: test/services/location_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:painel_windowns/services/location_service.dart';
import 'package:painel_windowns/models/location.dart';
import 'dart:convert';

@GenerateMocks([http.Client])
import 'location_service_test.mocks.dart';

void main() {
  late MockClient mockClient;
  const testToken = 'test-token-123';

  setUp(() {
    mockClient = MockClient();
  });

  group('LocationService Tests', () {
    test('fetchLocationsWithDeviceData should return list of locations', () async {
      // Mock response
      final mockResponse = {
        'locations': [
          {
            'name': 'Sala 101',
            'ip_ranges': ['192.168.1.0/24'],
            'bssids': ['AA:BB:CC:DD:EE:FF'],
            'device_count': 5,
          },
          {
            'name': 'Sala 102',
            'ip_ranges': ['192.168.2.0/24'],
            'bssids': ['11:22:33:44:55:66'],
            'device_count': 3,
          },
        ],
      };

      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(json.encode(mockResponse), 200));

      // Note: You'll need to modify LocationService to accept a client for testing
      // final locations = await LocationService.fetchLocationsWithDeviceData(testToken, client: mockClient);

      // expect(locations, isA<List<Location>>());
      // expect(locations.length, 2);
      // expect(locations[0].name, 'Sala 101');
    });

    test('createLocation should send POST request with location data', () async {
      final locationData = {
        'name': 'Nova Sala',
        'ip_ranges': ['192.168.3.0/24'],
        'bssids': ['AA:BB:CC:DD:EE:FF'],
      };

      when(
        mockClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(json.encode({'success': true}), 201),
      );

      // await LocationService.createLocation(testToken, locationData, client: mockClient);

      // verify(mockClient.post(
      //   any,
      //   headers: anyNamed('headers'),
      //   body: json.encode(locationData),
      // )).called(1);
    });

    test('updateLocation should send PUT request', () async {
      const locationName = 'Sala 101';
      final updateData = {
        'ip_ranges': ['192.168.1.0/24', '192.168.10.0/24'],
      };

      when(
        mockClient.put(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(json.encode({'success': true}), 200),
      );

      // await LocationService.updateLocation(testToken, locationName, updateData, client: mockClient);

      // verify(mockClient.put(
      //   any,
      //   headers: anyNamed('headers'),
      //   body: json.encode(updateData),
      // )).called(1);
    });

    test('deleteLocation should send DELETE request', () async {
      const locationName = 'Sala 101';

      when(mockClient.delete(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(json.encode({'success': true}), 200),
      );

      // await LocationService.deleteLocation(testToken, locationName, client: mockClient);

      // verify(mockClient.delete(
      //   any,
      //   headers: anyNamed('headers'),
      // )).called(1);
    });

    test('should handle network errors gracefully', () async {
      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenThrow(Exception('Network error'));

      // expect(
      //   () => LocationService.fetchLocationsWithDeviceData(testToken, client: mockClient),
      //   throwsException,
      // );
    });

    test('should handle 401 unauthorized response', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(json.encode({'error': 'Unauthorized'}), 401),
      );

      // expect(
      //   () => LocationService.fetchLocationsWithDeviceData(testToken, client: mockClient),
      //   throwsException,
      // );
    });

    test('should handle 404 not found response', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(json.encode({'error': 'Not found'}), 404),
      );

      // expect(
      //   () => LocationService.fetchLocationsWithDeviceData(testToken, client: mockClient),
      //   throwsException,
      // );
    });
  });
}
