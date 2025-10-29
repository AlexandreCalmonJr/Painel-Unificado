// File: lib/models/asset_module_base.dart

/// Enum para os tipos de módulos disponíveis
enum AssetModuleType {
  mobile('Módulo Mobile', 'mobile', 'phone_android'),
  totem('Módulo Totem', 'totem', 'desktop_windows'),
  desktop('Módulo Desktop', 'desktop', 'computer'),
  notebook('Módulo Notebook', 'notebook', 'laptop'),
  panel('Módulo Painéis', 'panel', 'tv'),
  printer('Módulo Impressoras', 'printer', 'print'),
  scanner('Módulo Scanners', 'scanner', 'qr_code_scanner'),
  custom('Módulo Customizado', 'custom', 'category');

  final String displayName;
  final String identifier;
  final String iconName;

  const AssetModuleType(this.displayName, this.identifier, this.iconName);
}

/// Classe para configurar uma coluna da tabela dinâmica
class TableColumnConfig {
  final String dataKey; // A chave no JSON/Map (ex: "assetName", "serialNumber", "hostname")
  final String label;   // O texto do cabeçalho (ex: "Nome do Ativo", "Serial", "Hostname")

  TableColumnConfig({required this.dataKey, required this.label});

  factory TableColumnConfig.fromJson(Map<String, dynamic> json) {
    return TableColumnConfig(
      dataKey: json['dataKey'],
      label: json['label'],
    );
  }

  Map<String, String> toJson() {
    return {
      'dataKey': dataKey,
      'label': label,
    };
  }
}

/// Classe base para todos os módulos de ativos
abstract class AssetModuleConfig {
  final String id;
  final String name;
  final String description;
  final AssetModuleType type;
  final bool isActive;
  final bool isCustom;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> customFields;
  final Map<String, dynamic> settings;
  final List<TableColumnConfig> tableColumns; // <-- CAMPO ADICIONADO

  AssetModuleConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.isActive = true,
    this.isCustom = false,
    required this.createdAt,
    this.updatedAt,
    this.customFields = const {},
    this.settings = const {},
    this.tableColumns = const [], // <-- CAMPO ADICIONADO
  });

  factory AssetModuleConfig.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    final type = AssetModuleType.values.firstWhere(
      (e) => e.identifier == typeStr,
      orElse: () => AssetModuleType.custom,
    );
    
    // Decodifica a lista de colunas
    final List<TableColumnConfig> columns = (json['table_columns'] as List? ?? [])
        .map((colJson) => TableColumnConfig.fromJson(Map<String, dynamic>.from(colJson)))
        .toList();

    return _ConcreteAssetModuleConfig(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      type: type,
      isActive: json['is_active'] ?? true,
      isCustom: json['is_custom'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      customFields: Map<String, dynamic>.from(json['custom_fields'] ?? {}),
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
      tableColumns: columns, // <-- CAMPO ADICIONADO
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'type': type.identifier,
      'is_active': isActive,
      'is_custom': isCustom,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'custom_fields': customFields,
      'settings': settings,
      'table_columns': tableColumns.map((col) => col.toJson()).toList(), 
    };
  }
}

/// Implementação concreta privada para o factory
class _ConcreteAssetModuleConfig extends AssetModuleConfig {
  _ConcreteAssetModuleConfig({
    required super.id,
    required super.name,
    required super.description,
    required super.type,
    required super.isActive,
    required super.isCustom,
    required super.createdAt,
    super.updatedAt,
    required super.customFields,
    required super.settings,
    required super.tableColumns, // <-- CAMPO ADICIONADO
  });
}

/// Tipos de campos customizados suportados
enum CustomFieldType {
  text,
  number,
  date,
  boolean,
  select,
  multiselect,
  textarea,
  email,
  phone,
  url,
}

/// Modelo base para ativos gerenciados por módulos
abstract class ManagedAsset {
  final String id;
  final String assetName;
  final String assetType;
  final String serialNumber;
  final String status;
  final DateTime lastSeen;
  final Map<String, dynamic> customData;
  final String? location; // O nome original da localização (ex: "SALA TI")
  final String? assignedTo;
  
  final String? unit;   // Nome da Unidade (ex: "HOSPITAL GERAL")
  final String? sector; // Setor (ex: "TI")
  final String? floor;  // Andar (ex: "3º ANDAR")

  ManagedAsset({
    required this.id,
    required this.assetName,
    required this.assetType,
    required this.serialNumber,
    required this.status,
    required this.lastSeen,
    this.customData = const {},
    this.location,
    this.assignedTo,
    this.unit,
    this.sector,
    this.floor,
  });

  Map<String, dynamic> toJson();
}

/// Permissões de módulo
class ModulePermission {
  final String moduleId;
  final bool canView;
  final bool canCreate;
  final bool canEdit;
  final bool canDelete;
  final bool canExport;
  final List<String> customPermissions;

  ModulePermission({
    required this.moduleId,
    this.canView = true,
    this.canCreate = false,
    this.canEdit = false,
    this.canDelete = false,
    this.canExport = false,
    this.customPermissions = const [],
  });

  factory ModulePermission.fromJson(Map<String, dynamic> json) {
    return ModulePermission(
      moduleId: json['module_id'],
      canView: json['can_view'] ?? true,
      canCreate: json['can_create'] ?? false,
      canEdit: json['can_edit'] ?? false,
      canDelete: json['can_delete'] ?? false,
      canExport: json['can_export'] ?? false,
      customPermissions: json['custom_permissions'] != null
          ? List<String>.from(json['custom_permissions'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'module_id': moduleId,
      'can_view': canView,
      'can_create': canCreate,
      'can_edit': canEdit,
      'can_delete': canDelete,
      'can_export': canExport,
      'custom_permissions': customPermissions,
    };
  }
}

/// Implementação genérica de ManagedAsset para casos não específicos
// ignore: unused_element
class _GenericAsset extends ManagedAsset {
  _GenericAsset({
    required super.id,
    required super.assetName,
    required super.assetType,
    required super.serialNumber,
    required super.status,
    required super.lastSeen,   // Adicionado
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'asset_name': assetName,
      'asset_type': assetType,
      'serial_number': serialNumber,
      'status': status,
      'last_seen': lastSeen.toIso8601String(),

      'custom_data': customData,
      'location': location,
      'assigned_to': assignedTo,
      'unit': unit,
      'sector': sector,
      'floor': floor,
      'sector_floor': (sector != null || floor != null)
          ? '${sector ?? "N/D"} / ${floor ?? "N/D"}'
          : (location ?? 'N/D'),
    };
  }
}