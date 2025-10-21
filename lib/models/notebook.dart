// File: lib/models/notebook.dart

import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/models/unit.dart'; // Importar o modelo Unit

// Fallback local LocationMapper implementation in case the external mapper is not available.
// This provides the minimal data used by this model (locationName, unit, sector, floor).
// If you have a proper implementation in utils/location_mapper.dart, you can remove this fallback
// and restore the import above.
class LocationData {
  final String? locationName;
  final Unit? unit;
  final String? sector;
  final String? floor;

  LocationData({
    this.locationName,
    this.unit,
    this.sector,
    this.floor,
  });
}

class LocationMapper {
  static LocationData mapLocation({
    required List<Unit> units,
    String? locationName,
    String? bssid,
  }) {
    // Simple best-effort mapping: if units list is provided, return the first unit as a match.
    // You can enhance this logic to match by name or BSSID based on your Unit model.
    final Unit? matchedUnit = units.isNotEmpty ? units.first : null;

    return LocationData(
      locationName: locationName ?? 'N/D',
      unit: matchedUnit,
      sector: null,
      floor: null,
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

  factory Notebook.fromJson(Map<String, dynamic> json, List<Unit> units) {
    
    // --- LÓGICA DE MAPEAMENTO DE LOCALIZAÇÃO ---
    final locationData = LocationMapper.mapLocation(
      units: units,
      locationName: json['location'],
      bssid: json['location_bssid'], // Supondo que o BSSID venha nesta chave
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
      unit: locationData.unit?.toString(),
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
      'unit': unit,
      'sector': sector,
      'floor': floor,
      // --- CAMPO COMBINADO ADICIONADO ---
      'sector_floor': (sector != null || floor != null)
          ? '${sector ?? "N/D"} / ${floor ?? "N/D"}'
          : (location ?? 'N/D'),
      
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