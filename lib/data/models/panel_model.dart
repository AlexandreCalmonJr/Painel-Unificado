// File: lib/models/painel.dart (VERSÃO CORRIGIDA)
import 'package:painel_windowns/data/models/asset_module_base_model.dart';
import 'package:painel_windowns/data/models/bssid_mapping.dart';
import 'package:painel_windowns/data/models/unit_model.dart';
import 'package:painel_windowns/services/location_mapper_service.dart';
import 'package:painel_windowns/services/logger_service.dart';
import 'package:painel_windowns/domain/entities/module_entity.dart';

/// Modelo completo para Painéis/TVs/Monitores
class Panel extends ManagedAsset {

  Panel({
    required super.id,
    required super.assetName,
    required super.serialNumber,
    required super.status,
    required super.lastSeen,
    required this.hostname, required this.model, required this.manufacturer, required this.screenSize, required this.resolution, required this.ipAddress, required this.macAddress, required this.firmwareVersion, super.location,
    super.assignedTo,
    super.customData,
    super.unit,
    super.sector,
    super.floor,
    this.isOnline = false,
    this.currentContent,
    this.contentLastUpdated,
    this.displaySettings,
    this.brightness,
    this.volume,
    this.hdmiInput,
    this.connectedDevices,
    this.maintenanceStatus = false, // ✅ NOVO
    this.maintenanceTicket, // ✅ NOVO
    this.maintenanceReason, // ✅ NOVO
    this.maintenanceHistory, // ✅ NOVO
  }) : super(assetType: 'panel');

  factory Panel.fromJson(
    Map<String, dynamic> json,
    List<Unit> units, [
    List<BssidMapping>? bssidMappings,
  ]) {
    // ✅ PRIORIZA DADOS DO SERVIDOR
    String? unit = json['unit'] as String?;
    String? sector = json['sector'] as String?;
    String? floor = json['floor'] as String?;
    String? location = json['location'] as String?;

    // 🔥 SÓ MAPEIA SE AUSENTE OU INVÁLIDO
    final bool shouldMap =
        (unit == null || unit == 'N/A' || unit == 'Desconhecido') ||
        (sector == null || sector == 'Desconhecido') ||
        (floor == null || floor == 'Desconhecido');

    if (shouldMap) {
      logger.info(
        'Panel ${json['serial_number']}: Mapeando localização localmente',
        tag: 'Panel.fromJson',
      );

      final locationData = LocationMapperService.mapLocation(
        units: units,
        bssidMappings: bssidMappings ?? [],
        ip: (json['ip_address'] ?? 'N/A') as String,
        macAddress: (json['mac_address'] ?? 'N/A') as String,
        originalLocation: location ?? 'N/D',
      );

      unit ??= locationData.unitName;
      sector ??= locationData.sector;
      floor ??= locationData.floor;
      location ??= locationData.locationName;

      logger.debug(
        'Mapeamento concluído - Unit: $unit, Sector: $sector, Floor: $floor',
        tag: 'Panel.fromJson',
      );
    }

    return Panel(
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

      unit: unit,
      sector: sector,
      floor: floor,

      hostname: (json['hostname'] ?? 'N/A') as String,
      model: (json['model'] ?? 'N/A') as String,
      manufacturer: (json['manufacturer'] ?? 'N/A') as String,
      screenSize: (json['screen_size'] ?? 'N/A') as String,
      resolution: (json['resolution'] ?? 'N/A') as String,
      ipAddress: (json['ip_address'] ?? 'N/A') as String,
      macAddress: (json['mac_address'] ?? 'N/A') as String,
      firmwareVersion: (json['firmware_version'] ?? 'N/A') as String,
      isOnline: (json['is_online'] ?? false) as bool,
      currentContent: json['current_content'] as String?,
      contentLastUpdated:
          json['content_last_updated'] != null
              ? DateTime.parse(json['content_last_updated'] as String)
              : null,
      displaySettings:
          json['display_settings'] != null
              ? Map<String, dynamic>.from(json['display_settings'] as Map)
              : null,
      brightness: json['brightness'] as int?,
      volume: json['volume'] as int?,
      hdmiInput: json['hdmi_input'] as String?,
      connectedDevices:
          json['connected_devices'] != null
              ? List<String>.from(json['connected_devices'] as List)
              : null,

      // ✅ NOVO: Campos de manutenção
      maintenanceStatus: (json['maintenance_status'] ?? false) as bool,
      maintenanceTicket: json['maintenance_ticket']?.toString(),
      maintenanceReason: json['maintenance_reason']?.toString(),
      maintenanceHistory:
          (json['maintenance_history'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>(),
    );
  }

  /// Cria Panel model a partir de ModuleEntity
  factory Panel.fromEntity(ModuleEntity entity) {
    return Panel(
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
      screenSize: 'N/A',
      resolution: 'N/A',
      ipAddress: entity.ipAddress ?? 'N/A',
      macAddress: entity.macAddress ?? 'N/A',
      firmwareVersion: 'N/A',
      isOnline: entity.isOnline ?? false,
    );
  }
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

  // ✅ NOVO: Campos de manutenção
  final bool maintenanceStatus;
  final String? maintenanceTicket;
  final String? maintenanceReason;
  final List<Map<String, dynamic>>? maintenanceHistory;

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

      // ✅ NOVO: Campos de manutenção
      'maintenance_status': maintenanceStatus,
      'maintenance_ticket': maintenanceTicket,
      'maintenance_reason': maintenanceReason,
      'maintenance_history': maintenanceHistory,
    };
  }

  /// Converte Panel model para ModuleEntity (domain layer)
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
      isOnline: isOnline,
    );
  }
}
