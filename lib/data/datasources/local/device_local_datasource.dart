import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:painel_windowns/core/error/exceptions.dart';
import 'package:painel_windowns/data/models/device_model.dart';

/// Data Source local para dispositivos
///
/// Responsável por cache de dispositivos usando SharedPreferences
abstract class DeviceLocalDataSource {
  /// Busca dispositivos do cache
  Future<List<Device>> getCachedDevices();

  /// Salva dispositivos no cache
  Future<void> cacheDevices(List<Device> devices);

  /// Busca um dispositivo específico do cache
  Future<Device?> getCachedDeviceById(String deviceId);

  /// Limpa o cache de dispositivos
  Future<void> clearCache();
}

class DeviceLocalDataSourceImpl implements DeviceLocalDataSource {

  DeviceLocalDataSourceImpl({required this.sharedPreferences});
  final SharedPreferences sharedPreferences;

  static const String CACHED_DEVICES = 'CACHED_DEVICES';
  static const String CACHE_TIMESTAMP = 'DEVICES_CACHE_TIMESTAMP';
  static const int CACHE_DURATION_MINUTES = 15;

  @override
  Future<List<Device>> getCachedDevices() async {
    try {
      // Verifica se o cache expirou
      final timestamp = sharedPreferences.getInt(CACHE_TIMESTAMP);
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();
        final difference = now.difference(cacheTime).inMinutes;

        if (difference > CACHE_DURATION_MINUTES) {
          throw const CacheException(message: 'Cache expired');
        }
      }

      final jsonString = sharedPreferences.getString(CACHED_DEVICES);
      if (jsonString != null) {
        final jsonList = json.decode(jsonString) as List<dynamic>;
        return jsonList
            .map((json) => Device.fromJson(json as Map<String, dynamic>, []))
            .toList();
      } else {
        throw const CacheException(message: 'No cached devices found');
      }
    } catch (e) {
      if (e is CacheException) {
        rethrow;
      }
      throw CacheException(message: 'Error reading cache: $e');
    }
  }

  @override
  Future<void> cacheDevices(List<Device> devices) async {
    try {
      // Converte devices para JSON (precisamos adicionar toJson ao Device)
      final jsonList =
          devices
              .map(
                (device) => {
                  '_id': device.id,
                  'device_id': device.deviceId,
                  'device_name': device.deviceName,
                  'device_model': device.deviceModel,
                  'battery': device.battery,
                  'ip_address': device.ipAddress,
                  'network': device.network,
                  'serial_number': device.serialNumber,
                  'imei': device.imei,
                  'mac_address': device.macAddress,
                  'mac_address_radio': device.macAddressRadio,
                  'last_seen': device.lastSeen,
                  'last_sync': device.lastSync,
                  'sector': device.sector,
                  'floor': device.floor,
                  'location': device.location,
                  'maintenance_status': device.maintenanceStatus,
                  'maintenance_ticket': device.maintenanceTicket,
                  'maintenance_reason': device.maintenanceReason,
                  'unit': device.unit,
                  'status': device.status,
                  'is_online': device.isOnline,
                },
              )
              .toList();

      await sharedPreferences.setString(CACHED_DEVICES, json.encode(jsonList));
      await sharedPreferences.setInt(
        CACHE_TIMESTAMP,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      throw CacheException(message: 'Error writing cache: $e');
    }
  }

  @override
  Future<Device?> getCachedDeviceById(String deviceId) async {
    try {
      final devices = await getCachedDevices();
      return devices.firstWhere(
        (device) => device.id == deviceId || device.deviceId == deviceId,
        orElse:
            () => throw const NotFoundException(message: 'Device not found in cache'),
      );
    } catch (e) {
      if (e is NotFoundException) {
        return null;
      }
      throw CacheException(message: 'Error reading device from cache: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(CACHED_DEVICES);
      await sharedPreferences.remove(CACHE_TIMESTAMP);
    } catch (e) {
      throw CacheException(message: 'Error clearing cache: $e');
    }
  }
}
