class AuditLog {
  final String id;
  final String assetId;
  final String assetName;
  final String action; // 'created', 'updated', 'deleted', 'status_changed'
  final String? field;
  final String? oldValue;
  final String? newValue;
  final String userId;
  final String username;
  final DateTime timestamp;
  
  AuditLog({
    required this.id,
    required this.assetId,
    required this.assetName,
    required this.action,
    this.field,
    this.oldValue,
    this.newValue,
    required this.userId,
    required this.username,
    required this.timestamp,
  });
  
  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['_id'],
      assetId: json['asset_id'],
      assetName: json['asset_name'],
      action: json['action'],
      field: json['field'],
      oldValue: json['old_value'],
      newValue: json['new_value'],
      userId: json['user_id'],
      username: json['username'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

