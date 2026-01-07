import 'dart:convert';

class IpMapping {
  final String id;
  final String location;
  final String ipStart;
  final String ipEnd;

  IpMapping({
    required this.id,
    required this.location,
    required this.ipStart,
    required this.ipEnd,
  });

  factory IpMapping.fromJson(Map<String, dynamic> json) {
    return IpMapping(
      id: json['_id'] ?? '',
      location: json['location'] ?? 'N/A',
      ipStart: json['ipStart'] ?? 'N/A',
      ipEnd: json['ipEnd'] ?? 'N/A',
    );
  }
}

List<IpMapping> ipMappingFromJson(String str) =>
    List<IpMapping>.from(json.decode(str).map((x) => IpMapping.fromJson(x)));
