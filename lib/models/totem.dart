import 'dart:convert';

import 'package:painel_windowns/models/device.dart';

// Ficheiro: lib/models/totem.dart
// DESCRIÇÃO: Modelo de dados unificado para os totens, baseado na sua especificação.

class Totem {
  final String id;
  final String hostname;
  final String serialNumber;
  final String model;
  final String serviceTag;
  final String ip;
  final String? unit;
  final List<String> installedPrograms;
  final String printerStatus;
  final DateTime lastSeen;
  final String status;
  final String biometricReaderStatus;
  final String totemType;
  final String ram;
  final String hdType;
  final String hdStorage;
  final String zebraStatus;
  final String bematechStatus;

  Totem({
    required this.id,
    required this.hostname,
    required this.serialNumber,
    required this.model,
    required this.serviceTag,
    required this.ip,
    required this.unit,
    required this.installedPrograms,
    required this.printerStatus,
    required this.lastSeen,
    required this.status,
    required this.biometricReaderStatus,
    required this.totemType,
    required this.ram,
    required this.hdType,
    required this.hdStorage,
    required this.zebraStatus,
    required this.bematechStatus,
  });

  factory Totem.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate =
        DateTime.tryParse(json['lastSeen'] ?? '') ?? DateTime.now();

    return Totem(
      id: json['_id'] ?? '',
      hostname: json['hostname'] ?? 'N/A',
      serialNumber: json['serialNumber'] ?? 'N/A',
      model: json['model'] ?? 'N/A',
      serviceTag: json['serviceTag'] ?? 'N/A',
      ip: json['ip'] ?? 'N/A',
      unit: json['unit'] ?? 'Desconhecida',
      installedPrograms: List<String>.from(json['installedPrograms'] ?? []),
      printerStatus: json['printerStatus'] ?? 'N/A',
      lastSeen: parsedDate.toLocal(),
      status: json['status'] ?? 'Offline',
      biometricReaderStatus: json['biometricReaderStatus'] ?? 'N/A',
      totemType: json['totemType'] ?? 'N/A',
      ram: json['ram'] ?? 'N/A',
      hdType: json['hdType'] ?? 'N/A',
      hdStorage: json['hdStorage'] ?? 'N/A',
      zebraStatus: json['zebraStatus'] ?? 'Não detectado',
      bematechStatus: json['bematechStatus'] ?? 'Não detectado',
    );
  }

  String get mozillaVersion {
    final regex = RegExp(r'Mozilla Firefox ([\d\.]+)');
    for (var program in installedPrograms) {
      final match = regex.firstMatch(program);
      if (match != null) {
        return match.group(1) ?? 'N/A';
      }
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
        if (match != null) {
          return match.group(1) ?? 'N/A';
        }
      }
    }
    return 'N/A';
  }

  static fromDevice(Device device) {}
}

List<Totem> totemFromJson(String str) =>
    List<Totem>.from(json.decode(str).map((x) => Totem.fromJson(x)));
