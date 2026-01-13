class AuditLog {

  AuditLog({
    required this.id,
    required this.assetId,
    required this.assetName,
    required this.action,
    required this.userId, required this.username, required this.timestamp, this.field,
    this.oldValue,
    this.newValue,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['_id'] as String,
      assetId: json['asset_id'] as String,
      assetName: json['asset_name'] as String,
      action: json['action'] as String,
      field: json['field'] as String?,
      oldValue: json['old_value'] as String?,
      newValue: json['new_value'] as String?,
      userId: json['user_id'] as String,
      username: json['username'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
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
}
