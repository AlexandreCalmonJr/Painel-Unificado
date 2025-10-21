// File: lib/models/painel.dart
import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/models/unit.dart';

/// Modelo completo para Painéis/TVs/Monitores
class Panel extends ManagedAsset {
  // Identificação básica
  final String hostname;
  final String model;
  final String manufacturer;
  
  // Especificações de Display
  final String screenSize;
  final String resolution;
  
  // Rede
  final String ipAddress;
  final String macAddress;
  
  // Sistema
  final String firmwareVersion;
  final bool isOnline;
  
  // Conteúdo
  final String? currentContent;
  final DateTime? contentLastUpdated;
  
  // Configurações de Display
  final Map<String, dynamic>? displaySettings;
  final int? brightness;
  final int? volume;
  
  // Conectividade
  final String? hdmiInput; // HDMI 1, HDMI 2, etc.
  
  // Periféricos (caso aplicável)
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
    // Mapeamento de localização
    final locationData = LocationMapperService.mapLocation(
      units: units,
      ip: json['ip_address'],
      macAddress: json['mac_address'],
      originalLocation: json['location'],
    );

    return Panel(
      id: json['_id'] ?? json['id'],
      assetName: json['asset_name'] ?? json['hostname'],
      serialNumber: json['serial_number'],
      status: json['status'] ?? 'offline',
      lastSeen: DateTime.parse(json['last_seen']),
      location: locationData.locationName,
      assignedTo: json['assigned_to'],
      customData: json['custom_data'] != null 
          ? Map<String, dynamic>.from(json['custom_data']) 
          : {},
      
      // Localização mapeada
      unit: locationData.unitName,
      sector: locationData.sector ?? json['sector'],
      floor: locationData.floor ?? json['floor'],
      
      // Identificação
      hostname: json['hostname'] ?? 'N/A',
      model: json['model'] ?? 'N/A',
      manufacturer: json['manufacturer'] ?? 'N/A',
      
      // Display
      screenSize: json['screen_size'] ?? 'N/A',
      resolution: json['resolution'] ?? 'N/A',
      
      // Rede
      ipAddress: json['ip_address'] ?? 'N/A',
      macAddress: json['mac_address'] ?? 'N/A',
      
      // Sistema
      firmwareVersion: json['firmware_version'] ?? 'N/A',
      isOnline: json['is_online'] ?? false,
      
      // Conteúdo
      currentContent: json['current_content'],
      contentLastUpdated: json['content_last_updated'] != null
          ? DateTime.parse(json['content_last_updated'])
          : null,
      
      // Configurações
      displaySettings: json['display_settings'] != null
          ? Map<String, dynamic>.from(json['display_settings'])
          : null,
      brightness: json['brightness'],
      volume: json['volume'],
      hdmiInput: json['hdmi_input'],
      
      // Periféricos
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
      
      // Identificação
      'hostname': hostname,
      'model': model,
      'manufacturer': manufacturer,
      
      // Display
      'screen_size': screenSize,
      'resolution': resolution,
      
      // Rede
      'ip_address': ipAddress,
      'mac_address': macAddress,
      
      // Sistema
      'firmware_version': firmwareVersion,
      'is_online': isOnline,
      
      // Conteúdo
      'current_content': currentContent,
      'content_last_updated': contentLastUpdated?.toIso8601String(),
      
      // Configurações
      'display_settings': displaySettings,
      'brightness': brightness,
      'volume': volume,
      'hdmi_input': hdmiInput,
      
      // Periféricos
      'connected_devices': connectedDevices,
    };
  }
}

class LocationMapperService {
  // Existing code

  static LocationData mapLocation({
    required List<Unit> units,
    required String ip,
    required String macAddress,
    required String originalLocation,
  }) {
    // Implement the logic to map location based on the provided parameters.
    // This is a placeholder implementation.
    return LocationData(
      locationName: originalLocation,
      unitName: 'Default Unit',
      sector: 'Default Sector',
      floor: 'Default Floor',
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