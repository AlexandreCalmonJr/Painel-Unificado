// File: lib/models/notebook.dart

import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/models/bssid_mapping.dart';
import 'package:painel_windowns/models/unit.dart';
import 'package:painel_windowns/services/location_mapper_service.dart'; // Importar o modelo Unit

class LocationData {
  final String? locationName;
  final Unit? unit;
  final String? sector;
  final String? floor;

  LocationData({
    this.locationName,
    this.unit,
    this.sector,
    this.floor, required String ip, required String macAddress, required String originalLocation, String? bssid,
  });
}

class LocationMapper {
  static LocationData mapLocation({
    required List<Unit> units,
    String? locationName,
    String? bssid,
    required String ip,
    required String macAddress,
    required String originalLocation,
    required String unit,
    
  }) {
    final Unit? matchedUnit = units.isNotEmpty ? units.first : null;

    
    return LocationData(
      originalLocation: originalLocation,
      macAddress: macAddress,
      ip: ip,
      locationName: originalLocation,
      unit: matchedUnit,
      sector: matchedUnit?.sector,
      floor: matchedUnit?.floor,
      bssid: bssid,
      
    );
  }
}

/// Modelo para Notebooks
class Notebook extends ManagedAsset {
  final String hostname;
  final String model;
  final String manufacturer;
  final String processor;
  final String ram;
  final String storage;
  final String operatingSystem;
  final String osVersion;
  final String ipAddress;
  final String macAddress;
  final int? batteryLevel;
  final String? batteryHealth;
  final List<String> installedSoftware;
  final bool antivirusStatus;
  final String? antivirusVersion;
  final DateTime? lastUpdateCheck;
  final Map<String, dynamic>? hardwareInfo;
  final bool isEncrypted;

  Notebook({
    required super.id,
    required super.assetName,
    required super.serialNumber,
    required super.status,
    required super.lastSeen,
    super.location,
    super.assignedTo,
    super.customData,
    // --- Campos de localização da classe base ---
    super.unit,
    super.sector,
    super.floor,
    // --- Campos específicos ---
    required this.hostname,
    required this.model,
    required this.manufacturer,
    required this.processor,
    required this.ram,
    required this.storage,
    required this.operatingSystem,
    required this.osVersion,
    required this.ipAddress,
    required this.macAddress,
    this.batteryLevel,
    this.batteryHealth,
    this.installedSoftware = const [],
    this.antivirusStatus = false,
    this.antivirusVersion,
    this.lastUpdateCheck,
    this.hardwareInfo,
    this.isEncrypted = false,
  }) : super(assetType: 'notebook');

factory Notebook.fromJson(Map<String, dynamic> json, List<Unit> units, List<BssidMapping> bssidMappings) {
    
    // --- LÓGICA DE MAPEAMENTO DE LOCALIZAÇÃO ---
    final locationData = LocationMapperService.mapLocation(
    units: units,
    bssidMappings: bssidMappings,
    ip: json['ip_address'] ?? 'N/A',
    macAddress: json['mac_address_radio'] ?? json['mac_address'] ?? 'N/A',
    originalLocation: json['location'] ?? 'N/D',
  );
    // --- FIM DA LÓGICA ---

    return Notebook(
      id: json['_id'] ?? json['id'],
      assetName: json['asset_name'] ?? json['hostname'],
      serialNumber: json['serial_number'],
      status: json['status'] ?? 'offline',
      lastSeen: DateTime.parse(json['last_seen']),
      location: locationData.locationName, // Nome da localização (ex: "SALA TI")
      assignedTo: json['assigned_to'],
      customData: json['custom_data'] != null ? Map<String, dynamic>.from(json['custom_data']) : {},
      
      // --- Campos de localização preenchidos ---
      unit: locationData.unitName,
      sector: locationData.sector,
      floor: locationData.floor,

      // --- Campos específicos do Notebook ---
      hostname: json['hostname'] ?? 'N/A',
      model: json['model'] ?? 'N/A',
      manufacturer: json['manufacturer'] ?? 'N/A',
      processor: json['processor'] ?? 'N/A',
      ram: json['ram'] ?? 'N/A',
      storage: json['storage'] ?? 'N/A',
      operatingSystem: json['operating_system'] ?? 'N/A',
      osVersion: json['os_version'] ?? 'N/A',
      ipAddress: json['ip_address'] ?? 'N/A',
      macAddress: json['mac_address'] ?? 'N/A',
      batteryLevel: json['battery_level'],
      batteryHealth: json['battery_health'],
      installedSoftware: json['installed_software'] != null
          ? List<String>.from(json['installed_software'])
          : [],
      antivirusStatus: json['antivirus_status'] ?? false,
      antivirusVersion: json['antivirus_version'],
      lastUpdateCheck: json['last_update_check'] != null
          ? DateTime.parse(json['last_update_check'])
          : null,
      hardwareInfo: json['hardware_info'] != null
          ? Map<String, dynamic>.from(json['hardware_info'])
          : null,
      isEncrypted: json['is_encrypted'] ?? false,
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
    // --- Campos de localização preenchidos ---
      'unit': unit,
      'sector': sector,
      'floor': floor,
      
      // --- Campos específicos ---
      'hostname': hostname,
      'model': model,
      'manufacturer': manufacturer,
      'processor': processor,
      'ram': ram,
      'storage': storage,
      'operating_system': operatingSystem,
      'os_version': osVersion,
      'ip_address': ipAddress,
      'mac_address': macAddress,
      'battery_level': batteryLevel,
      'battery_health': batteryHealth,
      'installed_software': installedSoftware,
      'antivirus_status': antivirusStatus,
      'antivirus_version': antivirusVersion,
      'last_update_check': lastUpdateCheck?.toIso8601String(),
      'hardware_info': hardwareInfo,
      'is_encrypted': isEncrypted,
    };
  }
}