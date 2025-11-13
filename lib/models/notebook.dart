// File: lib/models/notebook.dart (CORRIGIDO)
import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/models/bssid_mapping.dart';
import 'package:painel_windowns/models/unit.dart';
import 'package:painel_windowns/services/location_mapper_service.dart';

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
  final String biometricReaderStatus;
  final DateTime? lastSyncTime; // Última sincronização
  final String? currentUser; // Usuário logado no AD
  final int? uptimeSeconds;

  Notebook({
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
    required this.operatingSystem,
    required this.osVersion,
    required this.ipAddress,
    required this.macAddress,
    required this.biometricReaderStatus,
    this.batteryLevel,
    this.batteryHealth,
    this.installedSoftware = const [],
    this.antivirusStatus = false,
    this.antivirusVersion,
    this.lastUpdateCheck,
    this.hardwareInfo,
    this.isEncrypted = false,
    this.lastSyncTime,
    this.currentUser,
    this.uptimeSeconds,
  }) : super(assetType: 'notebook');

  // ===================================================================
  // ✅ CONSTRUTOR ATUALIZADO
  // ===================================================================
  factory Notebook.fromJson(
    Map<String, dynamic> json,
    List<Unit> units, [
    List<BssidMapping>? bssidMappings,
  ]) {
    // ✅ PRIORIZA DADOS DO SERVIDOR
    String? unit = json['unit'];
    String? sector = json['sector'];
    String? floor = json['floor'];
    String? location = json['location'];

    // ✅ LOGS DE DEBUG PARA DIAGNÓSTICO
    final serialNumber = json['serial_number'] ?? 'N/A';
    final macAddress =
        json['mac_address'] ?? json['mac_address_radio'] ?? 'N/A';

    print('🔍 Notebook $serialNumber:');
    print('   MAC Address: $macAddress');
    print('   IP: ${json['ip_address']}');
    print('   Unit (servidor): $unit');
    print('   Sector (servidor): $sector');
    print('   Floor (servidor): $floor');

    // 🔥 SÓ MAPEIA SE AUSENTE
    final bool shouldMap =
        (unit == null || unit == 'N/A' || unit == 'Desconhecido') ||
        (sector == null || sector == 'Desconhecido') ||
        (floor == null || floor == 'Desconhecido');

    if (shouldMap) {
      print('⚠️ Notebook $serialNumber: Mapeando localização localmente...');

      final locationData = LocationMapperService.mapLocation(
        units: units,
        bssidMappings: bssidMappings ?? [],
        ip: json['ip_address'] ?? 'N/A',
        macAddress: macAddress, // ✅ USA A VARIÁVEL JÁ PROCESSADA
        originalLocation: location ?? 'N/D',
      );

      unit ??= locationData.unitName;
      sector ??= locationData.sector;
      floor ??= locationData.floor;
      location ??= locationData.locationName;

      print('✅ Mapeamento local: Unit=$unit | Sector=$sector | Floor=$floor');
    } else {
      print('✅ Notebook $serialNumber: Usando dados do servidor');
    }

    // ===================================================================
    // FIM DA SEÇÃO ATUALIZADA
    // ===================================================================

    return Notebook(
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
      lastSyncTime:
          json['last_sync_time'] != null
              ? DateTime.parse(json['last_sync_time'])
              : null,
      currentUser: json['current_user'],
      uptimeSeconds: json['uptime_seconds'],
      // ✅ USA OS DADOS FINAIS (servidor ou mapeados)
      unit: unit,
      sector: sector,
      floor: floor,

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
      biometricReaderStatus: json['biometric_reader_status'] ?? 'N/A',
      installedSoftware:
          json['installed_software'] != null
              ? List<String>.from(json['installed_software'])
              : [],
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
      'last_sync_time': lastSyncTime?.toIso8601String(),
      'current_user': currentUser,
      'uptime_seconds': uptimeSeconds,
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
      'operating_system': operatingSystem,
      'os_version': osVersion,
      'ip_address': ipAddress,
      'mac_address': macAddress,
      'battery_level': batteryLevel,
      'battery_health': batteryHealth,
      'biometric_reader_status': biometricReaderStatus,
      'installed_software': installedSoftware,
      'antivirus_status': antivirusStatus,
      'antivirus_version': antivirusVersion,
      'last_update_check': lastUpdateCheck?.toIso8601String(),
      'hardware_info': hardwareInfo,
      'is_encrypted': isEncrypted,
    };
  }
  
  String get formattedUptime {
    if (uptimeSeconds == null) return 'N/D';
    
    final duration = Duration(seconds: uptimeSeconds!);
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    
    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
