class BssidMapping {
  final String macAddressRadio;
  final String sector;
  final String floor;
  // AJUSTE: Adiciona o campo que faltava
  final String unitName;

  BssidMapping({
    required this.macAddressRadio,
    required this.sector,
    required this.floor,
    required this.unitName,
  });

  Map<String, dynamic> toJson() => {
    'mac_address_radio': macAddressRadio,
    'sector': sector,
    'floor': floor,
    // AJUSTE: Adiciona ao JSON
    'unitName': unitName,
  };

  factory BssidMapping.fromJson(Map<String, dynamic> json) => BssidMapping(
    macAddressRadio: json['mac_address_radio'] as String? ?? '00:00:00:00:00:00',
    sector: json['sector'] as String? ?? 'N/D',
    floor: json['floor'] as String? ?? 'N/D',
     // AJUSTE: Lê o campo do JSON, com um padrão para segurança
    unitName: json['unitName'] as String? ?? '',
  );

  // Removido: get unitName => null;
}