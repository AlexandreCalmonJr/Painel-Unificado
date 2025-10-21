import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/models/unit.dart';


/// Modelo para Painéis/TVs
class Panel extends ManagedAsset {
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

  Panel({
    required super.id,
    required super.assetName,
    required super.serialNumber,
    required super.status,
    required super.lastSeen,
    super.location,
    super.assignedTo,
    super.customData,
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
  }) : super(assetType: 'panel');

  factory Panel.fromJson(Map<String, dynamic> json, List<Unit> units) {
    return Panel(
      id: json['_id'] ?? json['id'],
      assetName: json['asset_name'],
      serialNumber: json['serial_number'],
      status: json['status'] ?? 'offline',
      lastSeen: DateTime.parse(json['last_seen']),
      location: json['location'],
      assignedTo: json['assigned_to'],
      customData: json['custom_data'] != null ? Map<String, dynamic>.from(json['custom_data']) : {},
      model: json['model'],
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
    };
  }
}