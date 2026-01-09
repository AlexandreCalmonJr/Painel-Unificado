// File: lib/models/totem.dart
// CORRIGIDO: Agora herda de ManagedAsset para compatibilidade total

import 'package:painel_windowns/data/models/asset_module_base_model.dart';
import 'package:painel_windowns/data/models/bssid_mapping.dart';
import 'package:painel_windowns/data/models/unit_model.dart';
import 'package:painel_windowns/services/location_mapper_service.dart';
import 'package:painel_windowns/domain/entities/totem_entity.dart';

/// Modelo Totem que herda de ManagedAsset
class Totem extends ManagedAsset {
  // Campos específicos de Totem
  final String hostname;
  final String model;
  final String serviceTag;
  final String ip;
  final String macAddress;
  final String macAddressRadio;
  final List<String> installedPrograms;
  final String printerStatus;
  final String biometricReaderStatus;
  final String totemType;
  final String ram;
  final String hdType;
  final String hdStorage;
  final String zebraStatus;
  final String bematechStatus;

  Totem({
    required super.id,
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
    required this.serviceTag,
    required this.ip,
    required this.macAddress,
    required this.macAddressRadio,
    required this.installedPrograms,
    required this.printerStatus,
    required this.biometricReaderStatus,
    required this.totemType,
    required this.ram,
    required this.hdType,
    required this.hdStorage,
    required this.zebraStatus,
    required this.bematechStatus,
  }) : super(assetName: hostname, assetType: totemType);

  /// Factory com MAPEAMENTO DE LOCALIZAÇÃO
  factory Totem.fromJson(
    Map<String, dynamic> json,
    List<Unit> units,
    List<BssidMapping> bssidMappings,
  ) {
    DateTime parsedDate =
        DateTime.tryParse(json['lastSeen'] ?? '') ?? DateTime.now();

    // ⚡ MAPEAMENTO DE LOCALIZAÇÃO
    // ✅ CORRIGIDO: Aceitar tanto 'unit' (novo) quanto 'unitRoutes' (legado)
    final originalLocation =
        json['unit'] ?? json['unitRoutes'] ?? 'Desconhecida';

    // ✅ CORRIGIDO: Aceitar tanto 'macAddress' quanto 'mac_address'
    final macAddress = json['macAddress'] ?? json['mac_address'] ?? 'N/A';
    final macAddressRadio =
        json['macAddressRadio'] ?? json['mac_address_radio'] ?? 'N/A';

    final locationData = LocationMapperService.mapLocation(
      units: units,
      bssidMappings: bssidMappings,
      ip: json['ip'] ?? 'N/A',
      macAddress: macAddress,
      originalLocation: originalLocation,
    );

    return Totem(
      id: json['_id'] ?? '',
      serialNumber: json['serialNumber'] ?? 'N/A',
      status: json['status'] ?? 'Offline',
      lastSeen: parsedDate.toLocal(),
      location: locationData.locationName,
      assignedTo: null, // Totems geralmente não têm assignedTo
      customData: {},
      unit: locationData.unitName,
      sector: locationData.sector,
      floor: locationData.floor,
      hostname: json['hostname'] ?? 'N/A',
      model: json['model'] ?? 'N/A',
      serviceTag: json['serviceTag'] ?? 'N/A',
      ip: json['ip'] ?? 'N/A',
      macAddress: macAddress,
      macAddressRadio: macAddressRadio,
      installedPrograms: List<String>.from(json['installedPrograms'] ?? []),
      printerStatus: json['printerStatus'] ?? 'N/A',
      biometricReaderStatus: json['biometricReaderStatus'] ?? 'N/A',
      totemType: json['totemType'] ?? 'N/A',
      ram: json['ram'] ?? 'N/A',
      hdType: json['hdType'] ?? 'N/A',
      hdStorage: json['hdStorage'] ?? 'N/A',
      zebraStatus: json['zebraStatus'] ?? 'Não detectado',
      bematechStatus: json['bematechStatus'] ?? 'Não detectado',
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

      // Campos específicos
      'hostname': hostname,
      'model': model,
      'serviceTag': serviceTag,
      'ip': ip,
      'macAddress': macAddress,
      'macAddressRadio': macAddressRadio,
      'installedPrograms': installedPrograms,
      'printerStatus': printerStatus,
      'biometricReaderStatus': biometricReaderStatus,
      'totemType': totemType,
      'ram': ram,
      'hdType': hdType,
      'hdStorage': hdStorage,
      'zebraStatus': zebraStatus,
      'bematechStatus': bematechStatus,
    };
  }

  // ✅ Getters mantidos para compatibilidade
  String get mozillaVersion {
    final regex = RegExp(r'Mozilla Firefox ([\d\.]+)');
    for (var program in installedPrograms) {
      final match = regex.firstMatch(program);
      if (match != null) return match.group(1) ?? 'N/A';
    }
    return 'N/A';
  }

  String get javaVersion {
    final patterns = [
      RegExp(r'Java.*? ([\d\._]+)'),
      RegExp(r'OpenJDK.*? ([\d\._]+)'),
    ];
    for (var program in installedPrograms) {
      for (var pattern in patterns) {
        final match = pattern.firstMatch(program);
        if (match != null) return match.group(1) ?? 'N/A';
      }
    }
    return 'N/A';
  }

  /// Converte Totem model para TotemEntity (domain layer)
  TotemEntity toEntity() {
    return TotemEntity(
      id: id ?? '',
      name: hostname,
      status: status,
      location: location,
      unit: unit,
      sector: sector,
      floor: floor,
      model: model,
      serialNumber: serialNumber,
      ipAddress: ip,
      macAddress: macAddress,
      lastSeen: lastSeen,
    );
  }

  /// Cria Totem model a partir de TotemEntity
  factory Totem.fromEntity(TotemEntity entity) {
    return Totem(
      id: entity.id,
      serialNumber: entity.serialNumber ?? 'N/A',
      status: entity.status ?? 'Offline',
      lastSeen: entity.lastSeen ?? DateTime.now(),
      location: entity.location,
      unit: entity.unit,
      sector: entity.sector,
      floor: entity.floor,
      hostname: entity.name ?? 'N/A',
      model: entity.model ?? 'N/A',
      serviceTag: 'N/A',
      ip: entity.ipAddress ?? 'N/A',
      macAddress: entity.macAddress ?? 'N/A',
      macAddressRadio: 'N/A',
      installedPrograms: [],
      printerStatus: 'N/A',
      biometricReaderStatus: 'N/A',
      totemType: 'N/A',
      ram: 'N/A',
      hdType: 'N/A',
      hdStorage: 'N/A',
      zebraStatus: 'Não detectado',
      bematechStatus: 'Não detectado',
    );
  }

  /// Cria uma cópia do Totem com campos atualizados
  Totem copyWith({
    String? id,
    String? serialNumber,
    String? status,
    DateTime? lastSeen,
    String? location,
    String? assignedTo,
    Map<String, dynamic>? customData,
    String? unit,
    String? sector,
    String? floor,
    String? hostname,
    String? model,
    String? serviceTag,
    String? ip,
    String? macAddress,
    String? macAddressRadio,
    List<String>? installedPrograms,
    String? printerStatus,
    String? biometricReaderStatus,
    String? totemType,
    String? ram,
    String? hdType,
    String? hdStorage,
    String? zebraStatus,
    String? bematechStatus,
  }) {
    return Totem(
      id: id ?? this.id,
      serialNumber: serialNumber ?? this.serialNumber,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
      location: location ?? this.location,
      assignedTo: assignedTo ?? this.assignedTo,
      customData: customData ?? this.customData,
      unit: unit ?? this.unit,
      sector: sector ?? this.sector,
      floor: floor ?? this.floor,
      hostname: hostname ?? this.hostname,
      model: model ?? this.model,
      serviceTag: serviceTag ?? this.serviceTag,
      ip: ip ?? this.ip,
      macAddress: macAddress ?? this.macAddress,
      macAddressRadio: macAddressRadio ?? this.macAddressRadio,
      installedPrograms: installedPrograms ?? this.installedPrograms,
      printerStatus: printerStatus ?? this.printerStatus,
      biometricReaderStatus:
          biometricReaderStatus ?? this.biometricReaderStatus,
      totemType: totemType ?? this.totemType,
      ram: ram ?? this.ram,
      hdType: hdType ?? this.hdType,
      hdStorage: hdStorage ?? this.hdStorage,
      zebraStatus: zebraStatus ?? this.zebraStatus,
      bematechStatus: bematechStatus ?? this.bematechStatus,
    );
  }
}
