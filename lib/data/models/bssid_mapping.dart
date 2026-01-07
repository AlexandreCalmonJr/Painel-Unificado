// File: lib/models/bssid_mapping.dart
class BssidMapping {
  final String macAddressRadio;
  final String sector;
  final String floor;
  final String unitName; // CAMPO ADICIONADO

  BssidMapping({
    required this.macAddressRadio,
    required this.sector,
    required this.floor,
    this.unitName = '', // Valor padrão vazio
  });

  /// Cria BssidMapping a partir de JSON
  factory BssidMapping.fromJson(Map<String, dynamic> json) {
    return BssidMapping(
      macAddressRadio: json['mac_address_radio'] ?? '',
      sector: json['sector'] ?? '',
      floor: json['floor'] ?? '',
      unitName: json['unitName'] ?? '', // NOVO CAMPO
    );
  }

  /// Converte BssidMapping para JSON
  Map<String, dynamic> toJson() {
    return {
      'mac_address_radio': macAddressRadio,
      'sector': sector,
      'floor': floor,
      'unitName': unitName, // NOVO CAMPO
    };
  }

  /// Cria uma cópia com valores alterados
  BssidMapping copyWith({
    String? macAddressRadio,
    String? sector,
    String? floor,
    String? unitName,
  }) {
    return BssidMapping(
      macAddressRadio: macAddressRadio ?? this.macAddressRadio,
      sector: sector ?? this.sector,
      floor: floor ?? this.floor,
      unitName: unitName ?? this.unitName,
    );
  }

  @override
  String toString() {
    return 'BssidMapping(mac: $macAddressRadio, sector: $sector, floor: $floor, unit: $unitName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BssidMapping &&
        other.macAddressRadio == macAddressRadio &&
        other.sector == sector &&
        other.floor == floor &&
        other.unitName == unitName;
  }

  @override
  int get hashCode {
    return macAddressRadio.hashCode ^
        sector.hashCode ^
        floor.hashCode ^
        unitName.hashCode;
  }
}