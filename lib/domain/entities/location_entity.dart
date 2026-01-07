import 'package:equatable/equatable.dart';

/// Entity de localização no domain layer
class LocationEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final double? latitude;
  final double? longitude;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LocationEntity({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.city,
    this.state,
    this.country,
    this.latitude,
    this.longitude,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    address,
    city,
    state,
    country,
    latitude,
    longitude,
    isActive,
    createdAt,
    updatedAt,
  ];
}
