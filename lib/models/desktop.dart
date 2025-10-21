import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/models/unit.dart';

/// Modelo para Desktops
class Desktop extends ManagedAsset {
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
  final List<String> installedSoftware;
  final bool antivirusStatus;
  final String? antivirusVersion;
  final DateTime? lastUpdateCheck;
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
    this.installedSoftware = const [],
    this.antivirusStatus = false,
    this.antivirusVersion,
    this.lastUpdateCheck,
    this.hardwareInfo,
  }) : super(assetType: 'desktop');

  factory Desktop.fromJson(Map<String, dynamic> json, List<Unit> units) {
    return Desktop(
      id: json['_id'] ?? json['id'],
      assetName: json['asset_name'] ?? json['hostname'],
      serialNumber: json['serial_number'],
      status: json['status'] ?? 'offline',
      lastSeen: DateTime.parse(json['last_seen']),
      location: json['location'],
      assignedTo: json['assigned_to'],
      customData: json['custom_data'] != null ? Map<String, dynamic>.from(json['custom_data']) : {},
      hostname: json['hostname'],
      model: json['model'],
      manufacturer: json['manufacturer'] ?? 'N/A',
      processor: json['processor'] ?? 'N/A',
      ram: json['ram'] ?? 'N/A',
      storage: json['storage'] ?? 'N/A',
      operatingSystem: json['operating_system'] ?? 'N/A',
      osVersion: json['os_version'] ?? 'N/A',
      ipAddress: json['ip_address'] ?? 'N/A',
      macAddress: json['mac_address'] ?? 'N/A',
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
      'installed_software': installedSoftware,
      'antivirus_status': antivirusStatus,
      'antivirus_version': antivirusVersion,
      'last_update_check': lastUpdateCheck?.toIso8601String(),
      'hardware_info': hardwareInfo,
    };
  }
}