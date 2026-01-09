// File: lib/models/module.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/data/models/asset_module_base_model.dart';

/// Modelo simplificado de módulo para uso na UI administrativa
class Module {
  final String id;
  final String name;
  final String description;
  final AssetModuleType type;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<Map<String, dynamic>> tableColumns;

  Module({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.tableColumns = const [],
  });

  /// Cria um Module a partir de AssetModuleConfig
  factory Module.fromAssetModuleConfig(AssetModuleConfig config) {
    return Module(
      id: config.id,
      name: config.name,
      description: config.description,
      type: config.type,
      isActive: config.isActive,
      createdAt: config.createdAt,
      updatedAt: config.updatedAt,
      tableColumns: config.tableColumns.map((c) => c.toJson()).toList(),
    );
  }

  /// Converte para JSON para envio ao servidor
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'type': type.identifier,
      'is_active': isActive,
      'table_columns': tableColumns,
    };
  }

  /// Ícone do módulo baseado no tipo
  IconData get icon {
    switch (type) {
      case AssetModuleType.mobile:
        return Icons.phone_android;
      case AssetModuleType.totem:
        return Icons.desktop_windows;
      case AssetModuleType.desktop:
        return Icons.computer;
      case AssetModuleType.notebook:
        return Icons.laptop;
      case AssetModuleType.panel:
        return Icons.tv;
      case AssetModuleType.printer:
        return Icons.print;
      case AssetModuleType.scanner:
        return Icons.qr_code_scanner;
      case AssetModuleType.custom:
        return Icons.category;
    }
  }

  /// Status formatado
  String get statusText => isActive ? 'Ativo' : 'Inativo';

  /// Cria uma cópia com campos atualizados
  Module copyWith({
    String? id,
    String? name,
    String? description,
    AssetModuleType? type,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Map<String, dynamic>>? tableColumns,
  }) {
    return Module(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tableColumns: tableColumns ?? this.tableColumns,
    );
  }
}
