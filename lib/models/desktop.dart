// File: lib/models/desktop.dart
import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/models/unit.dart';

/// Modelo completo para Desktops
class Desktop extends ManagedAsset {
  // Identificação básica
  final String hostname;
  final String model;
  final String manufacturer;
  
  // Especificações de Hardware
  final String processor;
  final String ram;
  final String storage;
  final String storageType; // HDD, SSD, etc.
  
  // Sistema Operacional
  final String operatingSystem;
  final String osVersion;
  
  // Rede
  final String ipAddress;
  final String macAddress;
  
  // Periféricos
  final String? biometricReader;
  final String? connectedPrinter;
  
  // Software
  final List<String> installedSoftware;
  final List<String> installedPrograms;

  final String? javaVersion;
  final String? browserVersion;
  
  // Segurança
  final bool antivirusStatus;
  final String? antivirusVersion;
  final DateTime? lastUpdateCheck;
  
  // Hardware adicional
  final Map<String, dynamic>? hardwareInfo;

  Desktop({
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
    required this.processor,
    required this.ram,
    required this.storage,
    required this.storageType,
    required this.operatingSystem,
    required this.osVersion,
    required this.ipAddress,
    required this.macAddress,
    this.biometricReader,
    this.connectedPrinter,
    this.installedSoftware = const [],
    this.installedPrograms = const [],
    this.javaVersion,
    this.browserVersion,
    this.antivirusStatus = false,
    this.antivirusVersion,
    this.lastUpdateCheck,
    this.hardwareInfo,
  }) : super(assetType: 'desktop');

  factory Desktop.fromJson(Map<String, dynamic> json, List<Unit> units) {
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

    return Desktop(
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

      // Localização com prioridade
      unit: unit,
      sector: sector,
      floor: floor,

      // Identificação
      hostname: json['hostname'] ?? 'N/A',
      model: json['model'] ?? 'N/A',
      manufacturer: json['manufacturer'] ?? 'N/A',
      
      // Hardware
      processor: json['processor'] ?? 'N/A',
      ram: json['ram'] ?? 'N/A',
      storage: json['storage'] ?? 'N/A',
      storageType: json['storage_type'] ?? json['hd_type'] ?? 'N/A',
      
      // Sistema
      operatingSystem: json['operating_system'] ?? 'N/A',
      osVersion: json['os_version'] ?? 'N/A',
      
      // Rede
      ipAddress: json['ip_address'] ?? 'N/A',
      macAddress: json['mac_address'] ?? 'N/A',
      
      // Periféricos
      biometricReader: json['biometric_reader'],
      connectedPrinter: json['connected_printer'],
      
      // Software
      installedSoftware: json['installed_software'] != null
          ? List<String>.from(json['installed_software'])
          : [],
      javaVersion: json['java_version'],
      browserVersion: json['browser_version'],
      installedPrograms: json['installed_programs'] != null
          ? List<String>.from(json['installed_programs'])
          : const [],
      
      // Segurança
      antivirusStatus: json['antivirus_status'] ?? false,
      antivirusVersion: json['antivirus_version'],
      lastUpdateCheck: json['last_update_check'] != null
          ? DateTime.parse(json['last_update_check'])
          : null,
      hardwareInfo: json['hardware_info'] != null
          ? Map<String, dynamic>.from(json['hardware_info'])
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
      
      // Hardware
      'processor': processor,
      'ram': ram,
      'storage': storage,
      'storage_type': storageType,
      
      // Sistema
      'operating_system': operatingSystem,
      'os_version': osVersion,
      
      // Rede
      'ip_address': ipAddress,
      'mac_address': macAddress,
      
      // Periféricos
      'biometric_reader': biometricReader,
      'connected_printer': connectedPrinter,
      
      // Software
      'installed_software': installedSoftware,
      'java_version': javaVersion,
      'browser_version': browserVersion,
      
      // Segurança
      'antivirus_status': antivirusStatus,
      'antivirus_version': antivirusVersion,
      'last_update_check': lastUpdateCheck?.toIso8601String(),
      'hardware_info': hardwareInfo,
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
    // Implementação real deve buscar por IP/MAC nas unidades
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