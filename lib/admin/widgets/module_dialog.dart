// File: lib/admin/widgets/module_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:painel_windowns/controllers/theme_controller.dart';
import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/models/module.dart';
import 'package:painel_windowns/utils/app_constants.dart';
import 'package:painel_windowns/utils/module_column_defaults.dart';

class ModuleDialog extends StatefulWidget {
  final Module? module; // null = create mode, non-null = edit mode
  final Function(Map<String, dynamic>) onSave;

  const ModuleDialog({super.key, this.module, required this.onSave});

  @override
  State<ModuleDialog> createState() => _ModuleDialogState();
}

class _ModuleDialogState extends State<ModuleDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late AssetModuleType _selectedType;
  late bool _isActive;
  bool _isLoading = false;

  // Gerenciamento de colunas
  List<String> _selectedColumnKeys = [];
  List<AssetColumnDefinition> _availableColumns = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.module?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.module?.description ?? '',
    );
    _selectedType = widget.module?.type ?? AssetModuleType.notebook;
    _isActive = widget.module?.isActive ?? true;

    _loadAvailableColumns();
    _initializeSelectedColumns();
  }

  void _loadAvailableColumns() {
    _availableColumns = ModuleColumnDefaults.getColumnsForAssetType(
      _selectedType.identifier,
    );
  }

  void _initializeSelectedColumns() {
    if (widget.module != null && widget.module!.tableColumns.isNotEmpty) {
      // Carrega colunas existentes do módulo
      _selectedColumnKeys =
          widget.module!.tableColumns
              .map((c) => c['dataKey'] as String)
              .toList();

      // Verifica se há novas colunas disponíveis que não estavam salvas e as adiciona se forem padrão?
      // Por enquanto, mantemos apenas o que estava salvo para respeitar a escolha do usuário.
      // Mas precisamos garantir que as chaves salvas ainda são válidas.
      final availableKeys = _availableColumns.map((c) => c.key).toSet();
      _selectedColumnKeys.removeWhere((key) => !availableKeys.contains(key));
    } else {
      // Carrega colunas padrão para novo módulo ou módulo sem colunas definidas
      _selectedColumnKeys = ModuleColumnDefaults.getDefaultVisibleColumns(
        _selectedType.identifier,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Gera a lista de colunas selecionadas para salvar
  List<Map<String, String>> _getSelectedColumnsData() {
    // Mapeia as chaves selecionadas para suas definições, preservando a ordem da lista _selectedColumnKeys
    return _selectedColumnKeys.map((key) {
      final colDef = _availableColumns.firstWhere(
        (col) => col.key == key,
        orElse: () => AssetColumnDefinition(key: key, label: key),
      );
      return {'dataKey': key, 'label': colDef.label};
    }).toList();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final data = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'type': _selectedType.identifier,
        'is_active': _isActive,
        'table_columns': _getSelectedColumnsData(),
      };

      try {
        await widget.onSave(data);
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: $e'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }

  void _showAddColumnDialog() {
    final themeController = ThemeController.to;
    final isDark = themeController.isDarkMode;

    // Filtra colunas que ainda não foram selecionadas
    final unselectedColumns =
        _availableColumns
            .where((col) => !_selectedColumnKeys.contains(col.key))
            .toList();

    if (unselectedColumns.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todas as colunas já foram selecionadas.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor:
                isDark ? AppColors.surface : AppColors.surfaceLightMode,
            title: Text(
              'Adicionar Colunas',
              style: TextStyle(
                color:
                    isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SizedBox(
              width: 400,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: unselectedColumns.length,
                itemBuilder: (context, index) {
                  final col = unselectedColumns[index];
                  return ListTile(
                    title: Text(
                      col.label,
                      style: TextStyle(
                        color:
                            isDark
                                ? AppColors.textPrimary
                                : AppColors.textPrimaryLight,
                      ),
                    ),
                    trailing: Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primary,
                    ),
                    onTap: () {
                      setState(() {
                        _selectedColumnKeys.add(col.key);
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeController = ThemeController.to;
      final isDark = themeController.isDarkMode;
      final isEditMode = widget.module != null;

      return AlertDialog(
        backgroundColor:
            isDark ? AppColors.surface : AppColors.surfaceLightMode,
        title: Text(
          isEditMode ? 'Editar Módulo' : 'Novo Módulo',
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: 500,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campo Nome
                  TextFormField(
                    controller: _nameController,
                    style: TextStyle(
                      color:
                          isDark
                              ? AppColors.textPrimary
                              : AppColors.textPrimaryLight,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Nome do Módulo *',
                      labelStyle: TextStyle(
                        color:
                            isDark
                                ? AppColors.textSecondary
                                : AppColors.textSecondaryLight,
                      ),
                      filled: true,
                      fillColor:
                          isDark
                              ? AppColors.background
                              : AppColors.surfaceLightVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              isDark ? AppColors.border : AppColors.borderLight,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              isDark ? AppColors.border : AppColors.borderLight,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nome é obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo Descrição
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    style: TextStyle(
                      color:
                          isDark
                              ? AppColors.textPrimary
                              : AppColors.textPrimaryLight,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Descrição',
                      labelStyle: TextStyle(
                        color:
                            isDark
                                ? AppColors.textSecondary
                                : AppColors.textSecondaryLight,
                      ),
                      filled: true,
                      fillColor:
                          isDark
                              ? AppColors.background
                              : AppColors.surfaceLightVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              isDark ? AppColors.border : AppColors.borderLight,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color:
                              isDark ? AppColors.border : AppColors.borderLight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Seletor de Tipo (apenas para criação)
                  if (!isEditMode) ...[
                    Text(
                      'Tipo de Módulo *',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            isDark
                                ? AppColors.textSecondary
                                : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? AppColors.background
                                : AppColors.surfaceLightVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isDark ? AppColors.border : AppColors.borderLight,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<AssetModuleType>(
                          value: _selectedType,
                          isExpanded: true,
                          dropdownColor:
                              isDark
                                  ? AppColors.surface
                                  : AppColors.surfaceLightMode,
                          style: TextStyle(
                            color:
                                isDark
                                    ? AppColors.textPrimary
                                    : AppColors.textPrimaryLight,
                          ),
                          items:
                              AssetModuleType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getIconForType(type),
                                        size: 20,
                                        color:
                                            isDark
                                                ? AppColors.textSecondary
                                                : AppColors.textSecondaryLight,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(type.displayName),
                                    ],
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedType = value;
                                _loadAvailableColumns();
                                _initializeSelectedColumns();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Configuração de Colunas
                  Text(
                    'Colunas da Tabela (Arraste para reordenar)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color:
                          isDark
                              ? AppColors.textPrimary
                              : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? AppColors.background
                              : AppColors.surfaceLightVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isDark ? AppColors.border : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      children: [
                        if (_selectedColumnKeys.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Nenhuma coluna selecionada',
                              style: TextStyle(
                                color:
                                    isDark
                                        ? AppColors.textSecondary
                                        : AppColors.textSecondaryLight,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        else
                          ReorderableListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _selectedColumnKeys.length,
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (oldIndex < newIndex) {
                                  newIndex -= 1;
                                }
                                final item = _selectedColumnKeys.removeAt(
                                  oldIndex,
                                );
                                _selectedColumnKeys.insert(newIndex, item);
                              });
                            },
                            itemBuilder: (context, index) {
                              final key = _selectedColumnKeys[index];
                              final colDef = _availableColumns.firstWhere(
                                (c) => c.key == key,
                                orElse:
                                    () => AssetColumnDefinition(
                                      key: key,
                                      label: key,
                                    ),
                              );

                              return ListTile(
                                key: ValueKey(key),
                                title: Text(
                                  colDef.label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        isDark
                                            ? AppColors.textPrimary
                                            : AppColors.textPrimaryLight,
                                  ),
                                ),
                                leading: Icon(
                                  Icons.drag_handle,
                                  color:
                                      isDark
                                          ? AppColors.textSecondary
                                          : AppColors.textSecondaryLight,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: AppColors.danger,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _selectedColumnKeys.removeAt(index);
                                    });
                                  },
                                ),
                              );
                            },
                          ),

                        Divider(
                          height: 1,
                          color:
                              isDark ? AppColors.border : AppColors.borderLight,
                        ),

                        // Botão para adicionar colunas
                        ListTile(
                          leading: Icon(Icons.add, color: AppColors.primary),
                          title: Text(
                            'Adicionar Coluna',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          onTap: _showAddColumnDialog,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Switch de Status (apenas para edição)
                  if (isEditMode) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status do Módulo',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark
                                    ? AppColors.textPrimary
                                    : AppColors.textPrimaryLight,
                          ),
                        ),
                        Switch(
                          value: _isActive,
                          onChanged: (value) {
                            setState(() => _isActive = value);
                          },
                          activeThumbColor: AppColors.success,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isActive
                          ? 'Módulo ativo e visível para usuários'
                          : 'Módulo inativo e oculto',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color:
                            isDark
                                ? AppColors.textSecondary
                                : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color:
                    isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : Text(isEditMode ? 'Salvar' : 'Criar'),
          ),
        ],
      );
    });
  }

  IconData _getIconForType(AssetModuleType type) {
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
}
