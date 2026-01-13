import 'package:painel_windowns/domain/entities/user_entity.dart';

/// Model de usuário para a camada de dados
class User {
  User({
    this.id,
    this.username,
    this.email,
    this.password,
    this.role,
    this.isActive,
    this.sector,
    this.permissions,
    this.createdAt,
    this.updatedAt,
  });

  /// Converte JSON para User model
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['_id'] ?? json['id']) as String?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
      isActive: (json['isActive'] ?? json['is_active'] ?? true) as bool,
      sector: json['sector'] as String?,
      permissions:
          json['permissions'] != null
              ? List<String>.from(json['permissions'] as Iterable)
              : null,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
    );
  }

  /// Cria User model a partir de UserEntity
  factory User.fromEntity(UserEntity entity) {
    return User(
      id: entity.id,
      username: entity.username,
      email: entity.email,
      role: entity.role,
      isActive: entity.isActive,
      // Note: Entity might not have sector/permissions yet, so we leave them null or add them to entity later
      createdAt: entity.createdAt,
    );
  }
  final String? id;
  final String? username;
  final String? email;
  final String? password; // Usado apenas para criação
  final String? role;
  final bool? isActive;
  final String? sector;
  final List<String>? permissions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Converte User model para JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (username != null) 'username': username,
      if (email != null) 'email': email,
      if (password != null) 'password': password,
      if (role != null) 'role': role,
      if (isActive != null) 'isActive': isActive,
      if (sector != null) 'sector': sector,
      if (permissions != null) 'permissions': permissions,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Converte User model para UserEntity (domain layer)
  UserEntity toEntity() {
    return UserEntity(
      id: id ?? '',
      username: username ?? '',
      email: email ?? '',
      role: role ?? 'user',
      isActive: isActive ?? true,
      createdAt: createdAt,
    );
  }

  /// Cria uma cópia do User com campos atualizados
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? password,
    String? role,
    bool? isActive,
    String? sector,
    List<String>? permissions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      sector: sector ?? this.sector,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
