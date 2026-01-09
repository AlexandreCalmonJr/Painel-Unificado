import 'dart:convert';

class IpMapping {

  IpMapping({
    required this.id,
    required this.location,
    required this.ipStart,
    required this.ipEnd,
  });

  factory IpMapping.fromJson(Map<String, dynamic> json) {
    return IpMapping(
      id: (json['_id'] ?? '') as String,
      location: (json['location'] ?? 'N/A') as String,
      ipStart: (json['ipStart'] ?? 'N/A') as String,
      ipEnd: (json['ipEnd'] ?? 'N/A') as String,
    );
  }
  final String id;
  final String location;
  final String ipStart;
  final String ipEnd;
}

List<IpMapping> ipMappingFromJson(String str) => List<IpMapping>.from(
  (json.decode(str) as List).map(
    (x) => IpMapping.fromJson(Map<String, dynamic>.from(x as Map)),
  ),
);
