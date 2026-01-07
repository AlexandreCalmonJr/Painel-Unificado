import 'package:equatable/equatable.dart';

/// Entity de módulo/ativo no domain layer
class ModuleEntity extends Equatable {
  final String id;
  final String? assetTag;
  final String? serialNumber;
  final String? model;
  final String? manufacturer;
  final String? type; // Desktop, Notebook, Printer, Panel
  final String? status;
  final String? location;
  final String? sector;
  final String? floor;
  final String? unit;
  final String? ipAddress;
  final String? macAddress;
  final DateTime? lastSeen;
  final bool? isOnline;
  final Map<String, dynamic>? specifications;

  const ModuleEntity({
    required this.id,
    this.assetTag,
    this.serialNumber,
    this.model,
    this.manufacturer,
    this.type,
    this.status,
    this.location,
    this.sector,
    this.floor,
    this.unit,
    this.ipAddress,
    this.macAddress,
    this.lastSeen,
    this.isOnline,
    this.specifications,
  });

  @override
  List<Object?> get props => [
    id,
    assetTag,
    serialNumber,
    model,
    manufacturer,
    type,
    status,
    location,
    sector,
    floor,
    unit,
    ipAddress,
    macAddress,
    lastSeen,
    isOnline,
    specifications,
  ];
}
