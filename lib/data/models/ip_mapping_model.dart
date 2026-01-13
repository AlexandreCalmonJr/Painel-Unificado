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
      id: json['_id'] as String,
      location: json['location'] as String,
      ipStart: json['ipStart'] as String,
      ipEnd: json['ipEnd'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'location': location,
      'ipStart': ipStart,
      'ipEnd': ipEnd,
    };
  }

  static List<IpMapping> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => IpMapping.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
