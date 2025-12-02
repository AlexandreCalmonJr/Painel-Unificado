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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.module?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.module?.description ?? '',
    );
    _selectedType = widget.module?.type ?? AssetModuleType.notebook;
    _isActive = widget.module?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Gera as colunas padrão baseadas no tipo de módulo selecionado
  List<Map<String, String>> _generateDefaultColumns() {
    final columns = ModuleColumnDefaults.getColumnsForAssetType(
      _selectedType.identifier,
    );

    return columns.map((col) {
      return {'dataKey': col.key, 'label': col.label};
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
      };

      // Se estiver criando um novo módulo, adiciona as colunas padrão
      if (widget.module == null) {
        data['table_columns'] = _generateDefaultColumns();
      }

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
                              setState(() => _selectedType = value);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'As colunas da tabela serão configuradas automaticamente',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color:
                            isDark
                                ? AppColors.textSecondary
                                : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

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
                          activeColor: AppColors.success,
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
