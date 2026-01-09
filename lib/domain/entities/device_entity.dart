import 'package:equatable/equatable.dart';

/// Entity de dispositivo móvel no domain layer
///
/// Representa um dispositivo móvel puro, sem dependências de frameworks.
/// Imutável e contém apenas regras de negócio.
class DeviceEntity extends Equatable {

  const DeviceEntity({
    required this.id,
    this.deviceName,
    this.serialNumber,
    this.imei,
    this.phoneNumber,
    this.model,
    this.manufacturer,
    this.osVersion,
    this.lastSeen,
    this.battery,
    this.status,
    this.location,
    this.sector,
    this.floor,
    this.unit,
    this.isOnline,
  });
  final String id;
  final String? deviceName;
  final String? serialNumber;
  final String? imei;
  final String? phoneNumber;
  final String? model;
  final String? manufacturer;
  final String? osVersion;
  final String? lastSeen;
  final int? battery;
  final String? status;
  final String? location;
  final String? sector;
  final String? floor;
  final String? unit;
  final bool? isOnline;

  @override
  List<Object?> get props => [
    id,
    deviceName,
    serialNumber,
    imei,
    phoneNumber,
    model,
    manufacturer,
    osVersion,
    lastSeen,
    battery,
    status,
    location,
    sector,
    floor,
    unit,
    isOnline,
  ];

  /// Cria uma cópia com campos atualizados
  DeviceEntity copyWith({
    String? id,
    String? deviceName,
    String? serialNumber,
    String? imei,
    String? phoneNumber,
    String? model,
    String? manufacturer,
    String? osVersion,
    String? lastSeen,
    int? battery,
    String? status,
    String? location,
    String? sector,
    String? floor,
    String? unit,
    bool? isOnline,
  }) {
    return DeviceEntity(
      id: id ?? this.id,
      deviceName: deviceName ?? this.deviceName,
      serialNumber: serialNumber ?? this.serialNumber,
      imei: imei ?? this.imei,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      model: model ?? this.model,
      manufacturer: manufacturer ?? this.manufacturer,
      osVersion: osVersion ?? this.osVersion,
      lastSeen: lastSeen ?? this.lastSeen,
      battery: battery ?? this.battery,
      status: status ?? this.status,
      location: location ?? this.location,
      sector: sector ?? this.sector,
      floor: floor ?? this.floor,
      unit: unit ?? this.unit,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
