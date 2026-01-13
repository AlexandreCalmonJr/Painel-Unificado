// File: lib/models/printer.dart
// IMPORTANTE: Adicionar 'printer' ao enum AssetModuleType em asset_module_base.dart:
// printer('Módulo Impressoras', 'printer', 'print'),
import 'package:painel_windowns/data/models/asset_module_base_model.dart';
import 'package:painel_windowns/data/models/bssid_mapping.dart';
import 'package:painel_windowns/data/models/unit_model.dart';
import 'package:painel_windowns/services/location_mapper_service.dart';
import 'package:painel_windowns/domain/entities/module_entity.dart';

/// Modelo completo para Impressoras
class Printer extends ManagedAsset {

  Printer({
    required super.id,
    required super.assetName,
    required super.serialNumber,
    required super.status,
    required super.lastSeen,
    required this.hostname, required this.model, required this.manufacturer, required this.connectionType, required this.printerStatus, super.location,
    super.assignedTo,
    super.customData,
    super.unit,
    super.sector,
    super.floor,
    this.ipAddress,
    this.macAddress,
    this.usbPort,
    this.errorMessage,
    this.totalPageCount,
    this.colorPageCount,
    this.blackWhitePageCount,
    this.tonerLevels,
    this.paperLevel,
    this.isDuplex,
    this.isColor,
    this.supportedPaperSizes,
    this.hostComputerName,
    this.hostComputerIp,
    this.firmwareVersion,
    this.driverVersion,
    this.lastMaintenanceDate,
    this.maintenanceInfo,
    this.maintenanceStatus = false,
    this.maintenanceTicket,
    this.maintenanceReason,
    this.maintenanceHistory,
  }) : super(assetType: 'printer');

  factory Printer.fromJson(
    Map<String, dynamic> json,
    List<Unit> units, [
    List<BssidMapping>? bssidMappings,
  ]) {
    // ✅ PRIORIZA DADOS DO SERVIDOR
    String? unit = json['unit'] as String?;
    String? sector = json['sector'] as String?;
    String? floor = json['floor'] as String?;
    String? location = json['location'] as String?;

    // IP efetivo: impressora de rede ou host (USB)
    final effectiveIp =
        (json['ip_address'] ?? json['host_computer_ip'] ?? '') as String;

    // 🔥 SÓ MAPEIA SE AUSENTE OU INVÁLIDO
    final bool shouldMap =
        (unit == null || unit == 'N/A' || unit == 'Desconhecido') ||
        (sector == null || sector == 'Desconhecido') ||
        (floor == null || floor == 'Desconhecido');

    if (shouldMap) {
      print('⚠️ Printer ${json['serial_number']}: Mapeando localização...');

      final locationData = LocationMapperService.mapLocation(
        units: units,
        bssidMappings: bssidMappings ?? [],
        ip: effectiveIp,
        macAddress: (json['mac_address'] ?? '') as String,
        originalLocation: location ?? 'N/D',
      );

      unit ??= locationData.unitName;
      sector ??= locationData.sector;
      floor ??= locationData.floor;
      location ??= locationData.locationName;

      print('✅ Mapeamento: Unit=$unit | Sector=$sector | Floor=$floor');
    }

    return Printer(
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
      ipAddress: json['ip_address'] as String?,
      macAddress: json['mac_address'] as String?,
      connectionType: (json['connection_type'] ?? 'network') as String,
      usbPort: json['usb_port'] as String?,
      printerStatus: (json['printer_status'] ?? 'unknown') as String,
      errorMessage: json['error_message'] as String?,
      totalPageCount: json['total_page_count'] as int?,
      colorPageCount: json['color_page_count'] as int?,
      blackWhitePageCount: json['black_white_page_count'] as int?,
      tonerLevels:
          json['toner_levels'] != null
              ? Map<String, dynamic>.from(json['toner_levels'] as Map)
              : null,
      paperLevel: json['paper_level'] as int?,
      isDuplex: json['is_duplex'] as bool?,
      isColor: json['is_color'] as bool?,
      supportedPaperSizes:
          json['supported_paper_sizes'] != null
              ? List<String>.from(json['supported_paper_sizes'] as List)
              : null,
      hostComputerName: json['host_computer_name'] as String?,
      hostComputerIp: json['host_computer_ip'] as String?,
      firmwareVersion: json['firmware_version'] as String?,
      driverVersion: json['driver_version'] as String?,
      lastMaintenanceDate:
          json['last_maintenance_date'] != null
              ? DateTime.parse(json['last_maintenance_date'] as String)
              : null,
      maintenanceInfo:
          json['maintenance_info'] != null
              ? Map<String, dynamic>.from(json['maintenance_info'] as Map)
              : null,
      maintenanceStatus: (json['maintenance_status'] ?? false) as bool,
      maintenanceTicket: json['maintenance_ticket'] as String?,
      maintenanceReason: json['maintenance_reason'] as String?,
      maintenanceHistory:
          json['maintenance_history'] != null
              ? List<Map<String, dynamic>>.from(
                json['maintenance_history'] as List,
              )
              : null,
    );
  }

  /// Cria Printer model a partir de ModuleEntity
  factory Printer.fromEntity(ModuleEntity entity) {
    return Printer(
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
      connectionType: 'network',
      printerStatus: 'unknown',
    );
  }
  final String hostname;
  final String model;
  final String manufacturer;
  final String? ipAddress;
  final String? macAddress;
  final String connectionType;
  final String? usbPort;
  final String printerStatus;
  final String? errorMessage;
  final int? totalPageCount;
  final int? colorPageCount;
  final int? blackWhitePageCount;
  final Map<String, dynamic>? tonerLevels;
  final int? paperLevel;
  final bool? isDuplex;
  final bool? isColor;
  final List<String>? supportedPaperSizes;
  final String? hostComputerName;
  final String? hostComputerIp;
  final String? firmwareVersion;
  final String? driverVersion;
  final DateTime? lastMaintenanceDate;
  final Map<String, dynamic>? maintenanceInfo;
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
      'ip_address': ipAddress,
      'mac_address': macAddress,
      'connection_type': connectionType,
      'usb_port': usbPort,
      'printer_status': printerStatus,
      'error_message': errorMessage,
      'total_page_count': totalPageCount,
      'color_page_count': colorPageCount,
      'black_white_page_count': blackWhitePageCount,
      'toner_levels': tonerLevels,
      'paper_level': paperLevel,
      'is_duplex': isDuplex,
      'is_color': isColor,
      'supported_paper_sizes': supportedPaperSizes,
      'host_computer_name': hostComputerName,
      'host_computer_ip': hostComputerIp,
      'firmware_version': firmwareVersion,
      'driver_version': driverVersion,
      'last_maintenance_date': lastMaintenanceDate?.toIso8601String(),
      'maintenance_info': maintenanceInfo,
      'maintenance_status': maintenanceStatus,
      'maintenance_ticket': maintenanceTicket,
      'maintenance_reason': maintenanceReason,
      'maintenance_history': maintenanceHistory,
    };
  }

  String getTonerStatusSummary() {
    if (tonerLevels == null || tonerLevels!.isEmpty) return 'N/D';
    return tonerLevels!.entries.map((e) => '${e.key}: ${e.value}%').join(', ');
  }

  bool get hasLowToner {
    if (tonerLevels == null) return false;
    return tonerLevels!.values.any((level) => level is int && level < 20);
  }

  /// Converte Printer model para ModuleEntity (domain layer)
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
