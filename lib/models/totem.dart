// Ficheiro: lib/models/totem.dart
// DESCRIÇÃO: Modelo de dados unificado e exclusivo para os totens.

class Totem {
  final String id;
  final String hostname;
  final String serialNumber;
  final String model;
  final String serviceTag;
  final String ip;
  final String macAddress; // ADICIONADO: Endereço MAC para mapeamento de localização
  final String location;
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
    required this.macAddress, // ADICIONADO
    required this.location,
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
      macAddress: json['macAddress'] ?? '', // ADICIONADO: Pode vir da API ou ficar vazio
      location: json['unitRoutes'] ?? 'Desconhecida',
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

  // ADICIONADO: Método copyWith para facilitar atualizações
  // 1. CORRIGIDO: Removidos parâmetros extras (unit, sector, floor)
  Totem copyWith({
    String? id,
    String? hostname,
    String? serialNumber,
    String? model,
    String? serviceTag,
    String? ip,
    String? macAddress,
    String? location,
    List<String>? installedPrograms,
    String? printerStatus,
    DateTime? lastSeen,
    String? status,
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
      hostname: hostname ?? this.hostname,
      serialNumber: serialNumber ?? this.serialNumber,
      model: model ?? this.model,
      serviceTag: serviceTag ?? this.serviceTag,
      ip: ip ?? this.ip,
      macAddress: macAddress ?? this.macAddress,
      location: location ?? this.location,
      installedPrograms: installedPrograms ?? this.installedPrograms,
      printerStatus: printerStatus ?? this.printerStatus,
      lastSeen: lastSeen ?? this.lastSeen,
      status: status ?? this.status,
      biometricReaderStatus: biometricReaderStatus ?? this.biometricReaderStatus,
      totemType: totemType ?? this.totemType,
      ram: ram ?? this.ram,
      hdType: hdType ?? this.hdType,
      hdStorage: hdStorage ?? this.hdStorage,
      zebraStatus: zebraStatus ?? this.zebraStatus,
      bematechStatus: bematechStatus ?? this.bematechStatus,
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

  // 2. CORRIGIDO: Removida linha desnecessária
  // get ipAddress => null; 
}