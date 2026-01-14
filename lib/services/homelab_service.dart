// File: lib/services/homelab_service.dart
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/device_service.dart';
import 'package:painel_windowns/services/totem_service.dart';

/// Service to aggregate homelab statistics and metrics
class HomelabService {
  HomelabService({required this.authService});

  final AuthService authService;
  final DeviceService _deviceService = DeviceService();
  final TotemService _totemService = TotemService();

  /// Get overall system statistics
  Future<HomelabStats> getSystemStats() async {
    try {
      final token = authService.currentToken;
      if (token == null) {
        return HomelabStats.empty();
      }

      // Fetch units first, then devices and totems
      final units = await _deviceService.fetchUnits(token);

      final results = await Future.wait([
        _deviceService.fetchDevices(token, units),
        _totemService.fetchTotems(token),
      ]);

      final devicesData = results[0] as Map<String, dynamic>;
      final devices = devicesData['devices'] as List;
      final totems = results[1] as List;

      final totalDevices = devices.length + totems.length;
      final onlineDevices =
          devices.where((d) => d.isOnline == true).length +
          totems.where((t) => t.status?.toLowerCase() == 'online').length;
      final offlineDevices = totalDevices - onlineDevices;

      // Count devices with low battery (< 20%)
      int alerts = 0;
      for (final device in devices) {
        try {
          final battery = device.battery;
          if (battery != null && battery is num && battery < 20) {
            alerts++;
          }
        } catch (_) {
          // Skip devices without battery property
        }
      }

      return HomelabStats(
        totalDevices: totalDevices,
        onlineDevices: onlineDevices,
        offlineDevices: offlineDevices,
        alerts: alerts,
        mobileDevices: devices.length,
        totems: totems.length,
      );
    } catch (e) {
      return HomelabStats.empty();
    }
  }

  /// Get recent system activity
  Future<List<ActivityEvent>> getRecentActivity({required int limit}) async {
    // Mock data for now - in production, this would fetch from a log service
    return [
      ActivityEvent(
        type: ActivityType.deviceOnline,
        message: 'Tablet-Emergencia-2 conectado',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ActivityEvent(
        type: ActivityType.deviceOffline,
        message: 'Totem-UTI-1 desconectado',
        timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      ActivityEvent(
        type: ActivityType.alert,
        message: 'Bateria baixa em Tablet-Pediatria-3',
        timestamp: DateTime.now().subtract(const Duration(minutes: 23)),
      ),
      ActivityEvent(
        type: ActivityType.info,
        message: 'Sistema atualizado com sucesso',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  /// Get system health metrics (mock data)
  SystemHealth getSystemHealth() {
    return SystemHealth(
      cpuUsage: 45.0,
      memoryUsage: 62.0,
      networkUsage: 28.0,
      uptime: Duration(hours: 72, minutes: 34),
    );
  }
}

/// System statistics model
class HomelabStats {
  const HomelabStats({
    required this.totalDevices,
    required this.onlineDevices,
    required this.offlineDevices,
    required this.alerts,
    required this.mobileDevices,
    required this.totems,
  });

  factory HomelabStats.empty() {
    return const HomelabStats(
      totalDevices: 0,
      onlineDevices: 0,
      offlineDevices: 0,
      alerts: 0,
      mobileDevices: 0,
      totems: 0,
    );
  }

  final int totalDevices;
  final int onlineDevices;
  final int offlineDevices;
  final int alerts;
  final int mobileDevices;
  final int totems;

  double get onlinePercentage =>
      totalDevices > 0 ? (onlineDevices / totalDevices) * 100 : 0;

  void operator [](String other) {}
}

/// Activity event model
class ActivityEvent {
  const ActivityEvent({
    required this.type,
    required this.message,
    required this.timestamp,
  });

  final ActivityType type;
  final String message;
  final DateTime timestamp;
}

enum ActivityType { deviceOnline, deviceOffline, alert, info }

/// System health model
class SystemHealth {
  const SystemHealth({
    required this.cpuUsage,
    required this.memoryUsage,
    required this.networkUsage,
    required this.uptime,
  });

  final double cpuUsage;
  final double memoryUsage;
  final double networkUsage;
  final Duration uptime;
}
