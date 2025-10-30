// File: lib/models/painel.dart
import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/models/unit.dart';

/// Modelo completo para Painéis/TVs/Monitores
class Panel extends ManagedAsset {
  final String hostname;
  final String model;
  final String manufacturer;
  final String screenSize;
  final String resolution;
  final String ipAddress;
  final String macAddress;
  final String firmwareVersion;
  final bool isOnline;
  final String? currentContent;
  final DateTime? contentLastUpdated;
  final Map<String, dynamic>? displaySettings;
  final int? brightness;
  final int? volume;
  final String? hdmiInput;
  final List<String>? connectedDevices;

  Panel({
    required super.id,
    required super.assetName,
    required super.serialNumber,
    required super.status,
    required super.lastSeen,
    super.location,
    super.assignedTo,
    super.customData,
    super.unit,
    super.sector,
    super.floor,
    required this.hostname,
    required this.model,
    required this.manufacturer,
    required this.screenSize,
    required this.resolution,
    required this.ipAddress,
    required this.macAddress,
    required this.firmwareVersion,
    this.isOnline = false,
    this.currentContent,
    this.contentLastUpdated,
    this.displaySettings,
    this.brightness,
    this.volume,
    this.hdmiInput,
    this.connectedDevices,
  }) : super(assetType: 'panel');

  factory Panel.fromJson(Map<String, dynamic> json, List<Unit> units) {
    // PRIORIZA DADOS DO SERVIDOR
    String? unit = json['unit'];
    String? sector = json['sector'];
    String? floor = json['floor'];

    // SÓ MAPEIA SE AUSENTE OU INVÁLIDO
    final bool shouldMapLocation = (unit == null || unit == 'N/A' || unit == 'Desconhecido') ||
        (sector == null || sector == 'Desconhecido') ||
        (floor == null || floor == 'Desconhecido');

    LocationData? locationData;
    if (shouldMapLocation) {
      locationData = LocationMapperService.mapLocation(
        units: units,
        ip: json['ip_address'] ?? '',
        macAddress: json['mac_address'] ?? '',
        originalLocation: json['location'],
      );
      unit ??= locationData.unitName;
      sector ??= locationData.sector;
      floor ??= locationData.floor;
    }

    return Panel(
      id: json['_id'] ?? json['id'],
      assetName: json['asset_name'] ?? json['hostname'],
      serialNumber: json['serial_number'],
      status: json['status'] ?? 'offline',
      lastSeen: DateTime.parse(json['last_seen']),
      location: json['location'],
      assignedTo: json['assigned_to'],
      customData: json['custom_data'] != null 
          ? Map<String, dynamic>.from(json['custom_data']) 
          : {},

      unit: unit,
      sector: sector,
      floor: floor,

      hostname: json['hostname'] ?? 'N/A',
      model: json['model'] ?? 'N/A',
      manufacturer: json['manufacturer'] ?? 'N/A',
      screenSize: json['screen_size'] ?? 'N/A',
      resolution: json['resolution'] ?? 'N/A',
      ipAddress: json['ip_address'] ?? 'N/A',
      macAddress: json['mac_address'] ?? 'N/A',
      firmwareVersion: json['firmware_version'] ?? 'N/A',
      isOnline: json['is_online'] ?? false,
      currentContent: json['current_content'],
      contentLastUpdated: json['content_last_updated'] != null
          ? DateTime.parse(json['content_last_updated'])
          : null,
      displaySettings: json['display_settings'] != null
          ? Map<String, dynamic>.from(json['display_settings'])
          : null,
      brightness: json['brightness'],
      volume: json['volume'],
      hdmiInput: json['hdmi_input'],
      connectedDevices: json['connected_devices'] != null
          ? List<String>.from(json['connected_devices'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'asset_name': assetName,
      'asset_type': assetType,
      'serial_number': serialNumber,
      'status': status,
      'last_seen': lastSeen.toIso8601String(),
      'location': location,
      'assigned_to': assignedTo,
      'custom_data': customData,
      'unit': unit,
      'sector': sector,
      'floor': floor,
      'sector_floor': (sector != null || floor != null)
          ? '${sector ?? "N/D"} / ${floor ?? "N/D"}'
          : (location ?? 'N/D'),
      
      'hostname': hostname,
      'model': model,
      'manufacturer': manufacturer,
      'screen_size': screenSize,
      'resolution': resolution,
      'ip_address': ipAddress,
      'mac_address': macAddress,
      'firmware_version': firmwareVersion,
      'is_online': isOnline,
      'current_content': currentContent,
      'content_last_updated': contentLastUpdated?.toIso8601String(),
      'display_settings': displaySettings,
      'brightness': brightness,
      'volume': volume,
      'hdmi_input': hdmiInput,
      'connected_devices': connectedDevices,
    };
  }
}

class LocationMapperService {
  static LocationData mapLocation({
    required List<Unit> units,
    required String ip,
    required String macAddress,
    required String originalLocation,
  }) {
    return LocationData(
      locationName: originalLocation,
      unitName: units.isNotEmpty ? units.first.name : 'Unidade Desconhecida',
      sector: units.isNotEmpty ? units.first.sector : null,
      floor: units.isNotEmpty ? units.first.floor : null,
    );
  }
}

class LocationData {
  final String locationName;
  final String unitName;
  final String? sector;
  final String? floor;

  LocationData({
    required this.locationName,
    required this.unitName,
    this.sector,
    this.floor,
  });
}