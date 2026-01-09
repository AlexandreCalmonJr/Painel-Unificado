import 'package:painel_windowns/core/utils/helpers.dart';
import 'package:painel_windowns/data/models/unit_model.dart';
import 'package:painel_windowns/domain/entities/device_entity.dart';

// ADICIONADO: Enum para os tipos de status
enum DeviceStatusType {
  online,
  offline,
  maintenance,
  collectedByIT,
  unmonitored,
}

class Device {
  final String? id;
  final String? deviceId;
  final String? deviceName;
  final String? deviceModel;
  final num? battery;
  final String? ipAddress;
  final String? network;
  final String? serialNumber;
  final String? imei;
  final String? macAddress;
  final String?
  macAddressRadio; // ✅ NOVO: BSSID WiFi para mapeamento de localização
  final String? lastSeen;
  final String? lastSync;
  final String? sector;
  final String? floor;
  final String? location;
  final bool? maintenanceStatus;
  final String? maintenanceTicket;
  final String? maintenanceReason;
  final List<Map<String, dynamic>>? maintenanceHistory;
  final String? unit;
  final String? provisioningStatus;
  final String? provisioningToken;
  final String? enrollmentDate;
  final String? configurationProfile;
  final String? ownerOrganization;
  final String? complianceStatus;
  final List<Map<String, dynamic>>? installedApps;
  final Map<String, dynamic>? securityPolicies;
  final String status;
  final bool? isOnline; // ✅ NOVO: Status em tempo real

  Device({
    this.id,
    this.deviceId,
    this.deviceName,
    this.deviceModel,
    this.battery,
    this.ipAddress,
    this.network,
    this.serialNumber,
    this.imei,
    this.macAddress,
    this.macAddressRadio, // ✅ NOVO
    this.lastSeen,
    this.lastSync,
    this.sector,
    this.floor,
    this.location,
    this.maintenanceStatus,
    this.maintenanceTicket,
    this.maintenanceReason,
    this.maintenanceHistory,
    this.unit,
    this.provisioningStatus,
    this.provisioningToken,
    this.enrollmentDate,
    this.configurationProfile,
    this.ownerOrganization,
    this.complianceStatus,
    this.installedApps,
    this.securityPolicies,
    required this.status,
    this.isOnline, // ✅ NOVO
  });

  // ADICIONADO: Getter para centralizar a lógica de status
  DeviceStatusType get displayStatus {
    if (maintenanceStatus ?? false) {
      return maintenanceReason == 'collected_by_it'
          ? DeviceStatusType.collectedByIT
          : DeviceStatusType.maintenance;
    }
    switch (status) {
      case 'online':
        return DeviceStatusType.online;
      case 'Sem Monitorar':
        return DeviceStatusType.unmonitored;
      default:
        return DeviceStatusType.offline;
    }
  }

  factory Device.fromJson(Map<String, dynamic> json, List<Unit> units) {
    return Device(
      id: json['_id']?.toString(),
      deviceId: json['device_id']?.toString(),
      deviceName:
          json['device_name']?.toString() == 'N/A'
              ? null
              : json['device_name']?.toString(),
      deviceModel: json['device_model']?.toString(),
      battery: json['battery'] is num ? json['battery'] as num : null,
      ipAddress:
          json['ip_address']?.toString() == 'N/A'
              ? null
              : json['ip_address']?.toString(),
      network:
          json['network']?.toString() == 'N/A'
              ? null
              : json['network']?.toString(),
      serialNumber: json['serial_number']?.toString(),
      imei: json['imei']?.toString(),
      macAddress:
          json['mac_address']?.toString() == 'N/A'
              ? null
              : json['mac_address']?.toString(),
      macAddressRadio:
          json['mac_address_radio']?.toString() == 'N/A'
              ? null
              : json['mac_address_radio']?.toString(), // ✅ NOVO: BSSID
      lastSeen: json['last_seen']?.toString(),
      lastSync: json['last_sync']?.toString(),
      sector: json['sector']?.toString(),
      floor: json['floor']?.toString(),
      location: json['location']?.toString(),
      maintenanceStatus: (json['maintenance_status'] ?? false) as bool,
      maintenanceTicket: json["maintenance_ticket"]?.toString(),
      maintenanceReason: json["maintenance_reason"]?.toString(),
      maintenanceHistory:
          (json['maintenance_history'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>(),
      unit:
          json['unit']?.toString() ??
          getUnitFromIp(json['ip_address']?.toString(), units),
      provisioningStatus: json['provisioning_status']?.toString(),
      provisioningToken: json['provisioning_token']?.toString(),
      enrollmentDate: json['enrollment_date']?.toString(),
      configurationProfile: json['configuration_profile']?.toString(),
      ownerOrganization: json['owner_organization']?.toString(),
      complianceStatus: json['compliance_status']?.toString(),
      installedApps:
          (json['installed_apps'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>(),
      securityPolicies:
          json['security_policies'] is Map
              ? json['security_policies'] as Map<String, dynamic>
              : null,
      status: (json['status'] ?? 'offline') as String,
      isOnline: json['is_online'] is bool ? json['is_online'] as bool : null,
    ); // ✅ NOVO: Status em tempo real
  }

  /// Converte Model para Entity (Domain Layer)
  DeviceEntity toEntity() {
    return DeviceEntity(
      id: id ?? deviceId ?? '',
      deviceName: deviceName,
      serialNumber: serialNumber,
      imei: imei,
      phoneNumber: null, // Não disponível no model atual
      model: deviceModel,
      manufacturer: null, // Não disponível no model atual
      osVersion: null, // Não disponível no model atual
      lastSeen: lastSeen,
      battery: battery?.toInt(),
      status: status,
      location: location,
      sector: sector,
      floor: floor,
      unit: unit,
      isOnline: isOnline,
    );
  }

  /// Cria Model a partir de Entity
  factory Device.fromEntity(DeviceEntity entity) {
    return Device(
      id: entity.id,
      deviceId: entity.id,
      deviceName: entity.deviceName,
      deviceModel: entity.model,
      battery: entity.battery,
      serialNumber: entity.serialNumber,
      imei: entity.imei,
      lastSeen: entity.lastSeen,
      sector: entity.sector,
      floor: entity.floor,
      location: entity.location,
      unit: entity.unit,
      status: entity.status ?? 'offline',
      isOnline: entity.isOnline,
      ipAddress: null,
      network: null,
      macAddress: null,
      macAddressRadio: null,
      lastSync: null,
      maintenanceStatus: false,
      maintenanceTicket: null,
      maintenanceReason: null,
      maintenanceHistory: null,
      provisioningStatus: null,
      provisioningToken: null,
      enrollmentDate: null,
      configurationProfile: null,
      ownerOrganization: null,
      complianceStatus: null,
      installedApps: null,
      securityPolicies: null,
    );
  }

  /// Cria uma cópia do Device com campos atualizados
  Device copyWith({
    String? id,
    String? deviceId,
    String? deviceName,
    String? deviceModel,
    num? battery,
    String? ipAddress,
    String? network,
    String? serialNumber,
    String? imei,
    String? macAddress,
    String? macAddressRadio,
    String? lastSeen,
    String? lastSync,
    String? sector,
    String? floor,
    String? location,
    bool? maintenanceStatus,
    String? maintenanceTicket,
    String? maintenanceReason,
    List<Map<String, dynamic>>? maintenanceHistory,
    String? unit,
    String? provisioningStatus,
    String? provisioningToken,
    String? enrollmentDate,
    String? configurationProfile,
    String? ownerOrganization,
    String? complianceStatus,
    List<Map<String, dynamic>>? installedApps,
    Map<String, dynamic>? securityPolicies,
    String? status,
    bool? isOnline,
  }) {
    return Device(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      deviceModel: deviceModel ?? this.deviceModel,
      battery: battery ?? this.battery,
      ipAddress: ipAddress ?? this.ipAddress,
      network: network ?? this.network,
      serialNumber: serialNumber ?? this.serialNumber,
      imei: imei ?? this.imei,
      macAddress: macAddress ?? this.macAddress,
      macAddressRadio: macAddressRadio ?? this.macAddressRadio,
      lastSeen: lastSeen ?? this.lastSeen,
      lastSync: lastSync ?? this.lastSync,
      sector: sector ?? this.sector,
      floor: floor ?? this.floor,
      location: location ?? this.location,
      maintenanceStatus: maintenanceStatus ?? this.maintenanceStatus,
      maintenanceTicket: maintenanceTicket ?? this.maintenanceTicket,
      maintenanceReason: maintenanceReason ?? this.maintenanceReason,
      maintenanceHistory: maintenanceHistory ?? this.maintenanceHistory,
      unit: unit ?? this.unit,
      provisioningStatus: provisioningStatus ?? this.provisioningStatus,
      provisioningToken: provisioningToken ?? this.provisioningToken,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      configurationProfile: configurationProfile ?? this.configurationProfile,
      ownerOrganization: ownerOrganization ?? this.ownerOrganization,
      complianceStatus: complianceStatus ?? this.complianceStatus,
      installedApps: installedApps ?? this.installedApps,
      securityPolicies: securityPolicies ?? this.securityPolicies,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
