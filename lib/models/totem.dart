// File: lib/models/totem.dart
// CORRIGIDO: Agora herda de ManagedAsset para compatibilidade total

import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/models/bssid_mapping.dart';
import 'package:painel_windowns/models/unit.dart';
import 'package:painel_windowns/services/location_mapper_service.dart';

/// Modelo Totem que herda de ManagedAsset
class Totem extends ManagedAsset {
  // Campos específicos de Totem
  final String hostname;
  final String model;
  final String serviceTag;
  final String ip;
  final String macAddress;
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
    required this.installedPrograms,
    required this.printerStatus,
    required this.biometricReaderStatus,
    required this.totemType,
    required this.ram,
    required this.hdType,
    required this.hdStorage,
    required this.zebraStatus,
    required this.bematechStatus,
  }) : super(
          assetName: hostname,
          assetType: totemType,
        );

  /// Factory com MAPEAMENTO DE LOCALIZAÇÃO
  factory Totem.fromJson(
    Map<String, dynamic> json,
    List<Unit> units,
    List<BssidMapping> bssidMappings,
  ) {
    DateTime parsedDate =
        DateTime.tryParse(json['lastSeen'] ?? '') ?? DateTime.now();

    // ⚡ MAPEAMENTO DE LOCALIZAÇÃO
    final locationData = LocationMapperService.mapLocation(
      units: units,
      bssidMappings: bssidMappings,
      ip: json['ip'] ?? 'N/A',
      macAddress: json['macAddress'] ?? json['mac_address_radio'] ?? 'N/A',
      originalLocation: json['unitRoutes'] ?? 'Desconhecida',
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
      macAddress: json['macAddress'] ?? json['mac_address_radio'] ?? '',
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
      'sector_floor': (sector != null || floor != null)
          ? '${sector ?? "N/D"} / ${floor ?? "N/D"}'
          : (location ?? 'N/D'),
      
      // Campos específicos
      'hostname': hostname,
      'model': model,
      'serviceTag': serviceTag,
      'ip': ip,
      'macAddress': macAddress,
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
}