import 'package:equatable/equatable.dart';

/// Entity de totem no domain layer
class TotemEntity extends Equatable {

  const TotemEntity({
    required this.id,
    this.totemId,
    this.name,
    this.serialNumber,
    this.model,
    this.ipAddress,
    this.macAddress,
    this.location,
    this.sector,
    this.floor,
    this.unit,
    this.status,
    this.lastSeen,
    this.isOnline,
    this.softwareVersion,
    this.configuration,
  });
  final String id;
  final String? totemId;
  final String? name;
  final String? serialNumber;
  final String? model;
  final String? ipAddress;
  final String? macAddress;
  final String? location;
  final String? sector;
  final String? floor;
  final String? unit;
  final String? status;
  final DateTime? lastSeen;
  final bool? isOnline;
  final String? softwareVersion;
  final Map<String, dynamic>? configuration;

  @override
  List<Object?> get props => [
    id,
    totemId,
    name,
    serialNumber,
    model,
    ipAddress,
    macAddress,
    location,
    sector,
    floor,
    unit,
    status,
    lastSeen,
    isOnline,
    softwareVersion,
    configuration,
  ];
}
