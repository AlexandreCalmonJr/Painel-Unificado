// File: lib/models/printer.dart
// IMPORTANTE: Adicionar 'printer' ao enum AssetModuleType em asset_module_base.dart:
// printer('Módulo Impressoras', 'printer', 'print'),
import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/models/unit.dart';

/// Modelo completo para Impressoras
class Printer extends ManagedAsset {
  // Identificação básica
  final String hostname;
  final String model;
  final String manufacturer;
  
  // Conectividade
  final String? ipAddress; // Null se for USB
  final String? macAddress;
  final String connectionType; // 'network', 'usb', 'bluetooth'
  final String? usbPort; // Para impressoras USB
  
  // Status operacional
  final String printerStatus; // 'ready', 'printing', 'error', 'offline', 'paper_jam', etc.
  final String? errorMessage;
  
  // Contadores
  final int? totalPageCount;
  final int? colorPageCount;
  final int? blackWhitePageCount;
  
  // Níveis de consumíveis
  final Map<String, dynamic>? tonerLevels;
  final int? paperLevel;
  
  // Capacidades
  final bool? isDuplex;
  final bool? isColor;
  final List<String>? supportedPaperSizes;
  
  // Computador host (para impressoras USB/locais)
  final String? hostComputerName;
  final String? hostComputerIp;
  
  // Firmware e drivers
  final String? firmwareVersion;
  final String? driverVersion;
  
  // Informações adicionais
  final DateTime? lastMaintenanceDate;
  final Map<String, dynamic>? maintenanceInfo;

  Printer({
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
    this.ipAddress,
    this.macAddress,
    required this.connectionType,
    this.usbPort,
    required this.printerStatus,
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
  }) : super(assetType: 'printer');

  factory Printer.fromJson(Map<String, dynamic> json, List<Unit> units) {
    // PRIORIZA DADOS DO SERVIDOR
    String? unit = json['unit'];
    String? sector = json['sector'];
    String? floor = json['floor'];

    // IP efetivo: impressora de rede ou host (USB)
    final effectiveIp = json['ip_address'] ?? json['host_computer_ip'] ?? '';

    // SÓ MAPEIA SE AUSENTE OU INVÁLIDO
    final bool shouldMapLocation = (unit == null || unit == 'N/A' || unit == 'Desconhecido') ||
        (sector == null || sector == 'Desconhecido') ||
        (floor == null || floor == 'Desconhecido');

    LocationData? locationData;
    if (shouldMapLocation) {
      locationData = LocationMapperService.mapLocation(
        units: units,
        ip: effectiveIp,
        macAddress: json['mac_address'] ?? '',
        originalLocation: json['location'],
      );
      unit ??= locationData.unitName;
      sector ??= locationData.sector;
      floor ??= locationData.floor;
    }

    return Printer(
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

      // Identificação
      hostname: json['hostname'] ?? 'N/A',
      model: json['model'] ?? 'N/A',
      manufacturer: json['manufacturer'] ?? 'N/A',
      
      // Conectividade
      ipAddress: json['ip_address'],
      macAddress: json['mac_address'],
      connectionType: json['connection_type'] ?? 'network',
      usbPort: json['usb_port'],
      
      // Status
      printerStatus: json['printer_status'] ?? 'unknown',
      errorMessage: json['error_message'],
      
      // Contadores
      totalPageCount: json['total_page_count'],
      colorPageCount: json['color_page_count'],
      blackWhitePageCount: json['black_white_page_count'],
      
      // Consumíveis
      tonerLevels: json['toner_levels'] != null
          ? Map<String, dynamic>.from(json['toner_levels'])
          : null,
      paperLevel: json['paper_level'],
      
      // Capacidades
      isDuplex: json['is_duplex'],
      isColor: json['is_color'],
      supportedPaperSizes: json['supported_paper_sizes'] != null
          ? List<String>.from(json['supported_paper_sizes'])
          : null,
      
      // Host
      hostComputerName: json['host_computer_name'],
      hostComputerIp: json['host_computer_ip'],
      
      // Firmware
      firmwareVersion: json['firmware_version'],
      driverVersion: json['driver_version'],
      
      // Manutenção
      lastMaintenanceDate: json['last_maintenance_date'] != null
          ? DateTime.parse(json['last_maintenance_date'])
          : null,
      maintenanceInfo: json['maintenance_info'] != null
          ? Map<String, dynamic>.from(json['maintenance_info'])
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
    };
  }
  
  String getTonerStatusSummary() {
    if (tonerLevels == null || tonerLevels!.isEmpty) return 'N/D';
    return tonerLevels!.entries
        .map((e) => '${e.key}: ${e.value}%')
        .join(', ');
  }
  
  bool get hasLowToner {
    if (tonerLevels == null) return false;
    return tonerLevels!.values.any((level) => level is int && level < 20);
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