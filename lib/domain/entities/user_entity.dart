import 'package:equatable/equatable.dart';

/// Entity de usuário no domain layer
class UserEntity extends Equatable {

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.role, required this.isActive, this.fullName,
    this.createdAt,
    this.lastLogin,
  });
  final String id;
  final String username;
  final String email;
  final String? fullName;
  final String role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    fullName,
    role,
    isActive,
    createdAt,
    lastLogin,
  ];

  UserEntity copyWith({
    String? id,
    String? username,
    String? email,
    String? fullName,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
