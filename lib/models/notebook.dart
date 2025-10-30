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
  }) : super(assetType: 'notebook');

  factory Notebook.fromJson(Map<String, dynamic> json, List<Unit> units, List<BssidMapping> bssidMappings) {
    
    // ✅ PRIORIZA DADOS DO SERVIDOR (se existirem)
    String? unit = json['unit'];
    String? sector = json['sector'];
    String? floor = json['floor'];
    String? location = json['location'];

    // 🔥 SÓ MAPEIA SE O SERVIDOR NÃO ENVIOU OS DADOS
    if ((unit == null || unit == 'N/A') || 
        (sector == null || sector == 'Desconhecido') ||
        (floor == null || floor == 'Desconhecido')) {
      
      print('⚠️ Notebook ${json['serial_number']}: Dados de localização ausentes, mapeando localmente...');
      
      final locationData = LocationMapperService.mapLocation(
        units: units,
        bssidMappings: bssidMappings,
        ip: json['ip_address'] ?? 'N/A',
        macAddress: json['mac_address_radio'] ?? json['mac_address'] ?? 'N/A',
        originalLocation: location ?? 'N/D',
      );

      // Usa os dados mapeados
      unit = locationData.unitName;
      sector = locationData.sector;
      floor = locationData.floor;
      location = locationData.locationName;
      
      print('✅ Mapeamento local: Unit=$unit | Sector=$sector | Floor=$floor');
    } else {
      print('✅ Notebook ${json['serial_number']}: Usando dados do servidor - Unit=$unit | Sector=$sector | Floor=$floor');
    }

    return Notebook(
      id: json['_id'] ?? json['id'],
      assetName: json['asset_name'] ?? json['hostname'],
      serialNumber: json['serial_number'],
      status: json['status'] ?? 'offline',
      lastSeen: DateTime.parse(json['last_seen']),
      location: location,
      assignedTo: json['assigned_to'],
      customData: json['custom_data'] != null 
          ? Map<String, dynamic>.from(json['custom_data']) 
          : {},
      
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
      'sector_floor': (sector != null || floor != null)
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
}