// File: lib/models/notebook.dart
import 'package:painel_windowns/data/models/asset_module_base_model.dart';
import 'package:painel_windowns/data/models/bssid_mapping.dart';
import 'package:painel_windowns/data/models/unit_model.dart';
import 'package:painel_windowns/domain/entities/module_entity.dart';
import 'package:painel_windowns/services/location_mapper_service.dart';
import 'package:painel_windowns/services/logger_service.dart';

class Notebook extends ManagedAsset {
  Notebook({
    required super.id,
    required super.assetName,
    required super.serialNumber,
    required super.status,
    required super.lastSeen,
    required this.hostname, required this.model, required this.manufacturer, required this.processor, required this.ram, required this.storage, required this.storageType, required this.operatingSystem, required this.osVersion, required this.ipAddress, required this.macAddress, required this.connectionType, required this.biometricReaderStatus, super.location,
    super.assignedTo,
    super.customData,
    super.unit,
    super.sector,
    super.floor,
    super.updatedAt,
    super.currentUser,
    super.uptime,
    this.macAddressRadio,
    this.wifiSsid,
    this.installedSoftware = const [],
    this.antivirusStatus = false,
    this.antivirusVersion,
    this.lastUpdateCheck,
    this.hardwareInfo,
    this.isEncrypted = false,
    this.batteryLevel,
    this.batteryHealth,
  }) : super(assetType: 'notebook');

  factory Notebook.fromJson(
    Map<String, dynamic> json,
    List<Unit> units, [
    List<BssidMapping>? bssidMappings,
  ]) {
    String? unit = json['unit'] as String?;
    String? sector = json['sector'] as String?;
    String? floor = json['floor'] as String?;
    String? location = json['location'] as String?;

    final serialNumber = (json['serial_number'] ?? 'N/A') as String;

    // Priorizar mac_address_radio (BSSID) para mapeamento
    final macAddressRadio = (json['mac_address_radio'] ?? 'N/A') as String;
    final macAddress = (json['mac_address'] ?? 'N/A') as String;

    logger.debug(
      'Notebook $serialNumber - BSSID: $macAddressRadio, MAC: $macAddress, IP: ${json['ip_address']}, Unit: $unit, Sector: $sector, Floor: $floor',
      tag: 'Notebook.fromJson',
    );

    final bool shouldMap =
        (unit == null || unit == 'N/A' || unit == 'Desconhecido') ||
        (sector == null || sector == 'Desconhecido') ||
        (floor == null || floor == 'Desconhecido');

    if (shouldMap) {
      logger.info(
        'Notebook $serialNumber: Mapeando localização localmente',
        tag: 'Notebook.fromJson',
      );

      final locationData = LocationMapperService.mapLocation(
        units: units,
        bssidMappings: bssidMappings ?? [],
        ip: (json['ip_address'] ?? 'N/A') as String,
        macAddress: macAddressRadio,
        originalLocation: location ?? 'N/D',
      );

      unit ??= locationData.unitName;
      sector ??= locationData.sector;
      floor ??= locationData.floor;
      location ??= locationData.locationName;

      logger.debug(
        'Mapeamento local concluído - Unit: $unit, Sector: $sector, Floor: $floor',
        tag: 'Notebook.fromJson',
      );
    } else {
      logger.debug(
        'Notebook $serialNumber: Usando dados do servidor',
        tag: 'Notebook.fromJson',
      );
    }

    return Notebook(
      id: (json['_id'] ?? json['id']) as String,
      assetName: (json['asset_name'] ?? json['hostname']) as String,
      serialNumber: json['serial_number'] as String,
      status: (json['status'] ?? 'offline') as String,
      lastSeen: DateTime.parse(json['last_seen'] as String),
      location: location,
      assignedTo: json['assigned_to'] as String?,
      customData:
          json['custom_data'] != null
              ? Map<String, dynamic>.from(json['custom_data'] as Map)
              : {},

      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : DateTime.parse(json['last_seen'] as String),
      currentUser: json['current_user'] as String?,
      uptime: json['uptime'] as String?,

      unit: unit,
      sector: sector,
      floor: floor,

      hostname: (json['hostname'] ?? 'N/A') as String,
      model: (json['model'] ?? 'N/A') as String,
      manufacturer: (json['manufacturer'] ?? 'N/A') as String,
      processor: (json['processor'] ?? 'N/A') as String,
      ram: (json['ram'] ?? 'N/A') as String,
      storage: (json['storage'] ?? 'N/A') as String,
      storageType: (json['storage_type'] ?? 'N/A') as String,
      operatingSystem: (json['operating_system'] ?? 'N/A') as String,
      osVersion: (json['os_version'] ?? 'N/A') as String,
      ipAddress: (json['ip_address'] ?? 'N/A') as String,
      macAddress: macAddress == 'N/A' ? 'N/A' : macAddress,
      macAddressRadio: macAddressRadio == 'N/A' ? null : macAddressRadio,
      wifiSsid: json['wifi_ssid'] as String?,
      connectionType: (json['connection_type'] ?? 'Desconhecido') as String,
      biometricReaderStatus:
          (json['biometric_reader'] ?? json['biometric_reader_status'] ?? 'N/A')
              as String,
      installedSoftware:
          json['installed_software'] != null
              ? List<String>.from(json['installed_software'] as List)
              : [],
      antivirusStatus: (json['antivirus_status'] ?? false) as bool,
      antivirusVersion: json['antivirus_version'] as String?,
      lastUpdateCheck:
          json['last_update_check'] != null
              ? DateTime.parse(json['last_update_check'] as String)
              : null,
      hardwareInfo:
          json['hardware_info'] != null
              ? Map<String, dynamic>.from(json['hardware_info'] as Map)
              : null,
      isEncrypted: (json['is_encrypted'] ?? false) as bool,
      batteryLevel: json['battery_level'] as int?,
      batteryHealth: json['battery_health'] as String?,
    );
  }

  /// Cria Notebook model a partir de ModuleEntity
  factory Notebook.fromEntity(ModuleEntity entity) {
    return Notebook(
      id: entity.id,
      assetName: entity.assetTag ?? 'N/A',
      serialNumber: entity.serialNumber ?? 'N/A',
      status: entity.status ?? 'offline',
      lastSeen: DateTime.now(),
      location: entity.location,
      unit: entity.unit,
      sector: entity.sector,
      floor: entity.floor,
      hostname: entity.assetTag ?? 'N/A',
      model: entity.model ?? 'N/A',
      manufacturer: entity.manufacturer ?? 'N/A',
      processor: 'N/A',
      ram: 'N/A',
      storage: 'N/A',
      storageType: 'N/A',
      operatingSystem: 'N/A',
      osVersion: 'N/A',
      ipAddress: entity.ipAddress ?? 'N/A',
      macAddress: entity.macAddress ?? 'N/A',
      connectionType: 'Desconhecido',
      biometricReaderStatus: 'N/A',
    );
  }
  final String hostname;
  final String model;
  final String manufacturer;
  final String processor;
  final String ram;
  final String storage;
  final String storageType;
  final String operatingSystem;
  final String osVersion;
  final String ipAddress;
  final String macAddress;
  final String? macAddressRadio;
  final String? wifiSsid;
  final String connectionType;
  final List<String> installedSoftware;
  final bool antivirusStatus;
  final String? antivirusVersion;
  final DateTime? lastUpdateCheck;
  final Map<String, dynamic>? hardwareInfo;
  final bool isEncrypted;
  final String biometricReaderStatus;

  // Battery fields
  final int? batteryLevel;
  final String? batteryHealth;

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

      'updated_at': updatedAt?.toIso8601String(),
      'current_user': currentUser,
      'uptime': uptime,

      'unit': unit,
      'sector': sector,
      'floor': floor,
      'sector_floor':
          (sector != null || floor != null)
              ? '${sector ?? "N/D"} / ${floor ?? "N/D"}'
              : (location ?? 'N/D'),
      'hostname': hostname,
      'model': model,
      'manufacturer': manufacturer,
      'processor': processor,
      'ram': ram,
      'storage': storage,
      'storage_type': storageType,
      'operating_system': operatingSystem,
      'os_version': osVersion,
      'ip_address': ipAddress,
      'mac_address': macAddress,
      'mac_address_radio': macAddressRadio,
      'wifi_ssid': wifiSsid,
      'connection_type': connectionType,
      'biometric_reader_status': biometricReaderStatus,
      'installed_software': installedSoftware,
      'antivirus_status': antivirusStatus,
      'antivirus_version': antivirusVersion,
      'last_update_check': lastUpdateCheck?.toIso8601String(),
      'hardware_info': hardwareInfo,
      'is_encrypted': isEncrypted,
      'battery_level': batteryLevel,
      'battery_health': batteryHealth,
    };
  }

  /// Converte Notebook model para ModuleEntity (domain layer)
  ModuleEntity toEntity() {
    return ModuleEntity(
      id: id,
      assetTag: serialNumber,
      serialNumber: serialNumber,
      model: model,
      manufacturer: manufacturer,
      type: assetType,
      status: status,
      location: location,
      sector: sector,
      floor: floor,
      unit: unit,
      ipAddress: ipAddress,
      macAddress: macAddress,
      isOnline: status.toLowerCase() == 'online',
    );
  }
}
