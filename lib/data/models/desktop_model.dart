// ========================================
// File: lib/models/desktop.dart (CORRIGIDO)
// ========================================
import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/models/bssid_mapping.dart';
import 'package:painel_windowns/models/unit.dart';
import 'package:painel_windowns/services/location_mapper_service.dart';
import 'package:painel_windowns/services/logger_service.dart';
import 'package:painel_windowns/domain/entities/module_entity.dart';

class Desktop extends ManagedAsset {
  final String hostname;
  final String model;
  final String manufacturer;
  @override
  final String? currentUser;
  @override
  final String? uptime;
  final DateTime? updatedAt;

  final String processor;
  final String ram;
  final String storage;
  final String storageType;

  final String operatingSystem;
  final String osVersion;

  final String ipAddress;
  final String macAddress;
  final String? macAddressRadio; // ✅ NOVO: BSSID WiFi para mapeamento
  final String? wifiSsid; // ✅ NOVO: Nome da rede WiFi
  final String connectionType; // ✅ NOVO: WiFi/Ethernet

  final String? biometricReader;
  final String? connectedPrinter;

  final List<String> installedSoftware;
  final List<String> installedPrograms;
  final String? javaVersion;
  final String? browserVersion;

  final bool antivirusStatus;
  final String? antivirusVersion;
  final DateTime? lastUpdateCheck;

  final Map<String, dynamic>? hardwareInfo;
  final bool isEncrypted; // ✅ NOVO: Status de criptografia

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
    this.macAddressRadio, // ✅ NOVO
    this.wifiSsid, // ✅ NOVO
    required this.connectionType, // ✅ NOVO
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
    this.isEncrypted = false, // ✅ NOVO
    this.currentUser,
    this.uptime,
    this.updatedAt,
  }) : super(assetType: 'desktop');

  factory Desktop.fromJson(
    Map<String, dynamic> json,
    List<Unit> units, [
    List<BssidMapping>? bssidMappings,
  ]) {
    String? unit = json['unit'];
    String? sector = json['sector'];
    String? floor = json['floor'];
    String? location = json['location'];

    // ✅ CORRIGIDO: Priorizar mac_address_radio (BSSID) para mapeamento
    final macAddressRadio = json['mac_address_radio'] ?? 'N/A';

    final bool shouldMap =
        (unit == null || unit == 'N/A' || unit == 'Desconhecido') ||
        (sector == null || sector == 'Desconhecido') ||
        (floor == null || floor == 'Desconhecido');

    if (shouldMap) {
      logger.info(
        'Desktop ${json['serial_number']}: Dados ausentes, mapeando localmente',
        tag: 'Desktop.fromJson',
      );

      final locationData = LocationMapperService.mapLocation(
        units: units,
        bssidMappings: bssidMappings ?? [],
        ip: json['ip_address'] ?? 'N/A',
        macAddress: macAddressRadio, // ✅ Usar BSSID em vez de MAC
        originalLocation: location ?? 'N/D',
      );

      unit ??= locationData.unitName;
      sector ??= locationData.sector;
      floor ??= locationData.floor;
      location ??= locationData.locationName;

      logger.debug(
        'Mapeamento local concluído - Unit: $unit, Sector: $sector, Floor: $floor',
        tag: 'Desktop.fromJson',
      );
    } else {
      logger.debug(
        'Desktop ${json['serial_number']}: Usando dados do servidor',
        tag: 'Desktop.fromJson',
      );
    }

    return Desktop(
      id: json['_id'] ?? json['id'],
      assetName: json['asset_name'] ?? json['hostname'],
      serialNumber: json['serial_number'],
      status: json['status'] ?? 'offline',
      lastSeen: DateTime.parse(json['last_seen']),
      location: location,
      assignedTo: json['assigned_to'],
      customData:
          json['custom_data'] != null
              ? Map<String, dynamic>.from(json['custom_data'])
              : {},

      // ✅ CAMPOS CORRIGIDOS
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : DateTime.parse(json['last_seen']),
      currentUser: json['current_user'],
      uptime: json['uptime'],

      unit: unit,
      sector: sector,
      floor: floor,

      hostname: json['hostname'] ?? 'N/A',
      model: json['model'] ?? 'N/A',
      manufacturer: json['manufacturer'] ?? 'N/A',

      processor: json['processor'] ?? 'N/A',
      ram: json['ram'] ?? 'N/A',
      storage: json['storage'] ?? 'N/A',
      storageType: json['storage_type'] ?? json['hd_type'] ?? 'N/A',

      operatingSystem: json['operating_system'] ?? 'N/A',
      osVersion: json['os_version'] ?? 'N/A',

      ipAddress: json['ip_address'] ?? 'N/A',
      macAddress: json['mac_address'] ?? 'N/A',
      macAddressRadio:
          macAddressRadio == 'N/A' ? null : macAddressRadio, // ✅ NOVO
      wifiSsid: json['wifi_ssid'], // ✅ NOVO
      connectionType: json['connection_type'] ?? 'Desconhecido', // ✅ NOVO

      biometricReader: json['biometric_reader'],
      connectedPrinter: json['connected_printer'],

      installedSoftware:
          json['installed_software'] != null
              ? List<String>.from(json['installed_software'])
              : [],
      installedPrograms:
          json['installed_programs'] != null
              ? List<String>.from(json['installed_programs'])
              : [],
      javaVersion: json['java_version'],
      browserVersion: json['browser_version'],

      antivirusStatus: json['antivirus_status'] ?? false,
      antivirusVersion: json['antivirus_version'],
      lastUpdateCheck:
          json['last_update_check'] != null
              ? DateTime.parse(json['last_update_check'])
              : null,
      hardwareInfo:
          json['hardware_info'] != null
              ? Map<String, dynamic>.from(json['hardware_info'])
              : null,
      isEncrypted: json['is_encrypted'] ?? false, // ✅ NOVO
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
      'sector_floor':
          (sector != null || floor != null)
              ? '${sector ?? "N/D"} / ${floor ?? "N/D"}'
              : (location ?? 'N/D'),

      // ✅ CAMPOS ADICIONADOS
      'updated_at': updatedAt?.toIso8601String(),
      'current_user': currentUser,
      'uptime': uptime,

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
      'mac_address_radio': macAddressRadio, // ✅ NOVO
      'wifi_ssid': wifiSsid, // ✅ NOVO
      'connection_type': connectionType, // ✅ NOVO

      'biometric_reader': biometricReader,
      'connected_printer': connectedPrinter,

      'installed_software': installedSoftware,
      'installed_programs': installedPrograms,
      'java_version': javaVersion,
      'browser_version': browserVersion,

      'antivirus_status': antivirusStatus,
      'antivirus_version': antivirusVersion,
      'last_update_check': lastUpdateCheck?.toIso8601String(),
      'hardware_info': hardwareInfo,
      'is_encrypted': isEncrypted, // ✅ NOVO
    };
  }

  /// Converte Desktop model para ModuleEntity (domain layer)
  ModuleEntity toEntity() {
    return ModuleEntity(
      id: id ?? '',
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

  /// Cria Desktop model a partir de ModuleEntity
  factory Desktop.fromEntity(ModuleEntity entity) {
    return Desktop(
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
    );
  }
}
