// File: lib/presentation/shared/widgets/dialogs/module_dialog.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/data/models/asset_module_base_model.dart';
import 'package:painel_windowns/data/models/module.dart';

class ModuleDialog extends StatefulWidget {
  const ModuleDialog({required this.onSave, super.key, this.module});

  final Module? module;
  final Future<void> Function(Map<String, dynamic> data) onSave;

  @override
  State<ModuleDialog> createState() => _ModuleDialogState();
}

class _ModuleDialogState extends State<ModuleDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late bool _isActive;
  late AssetModuleType _selectedType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.module?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.module?.description ?? '',
    );
    _isActive = widget.module?.isActive ?? true;
    _selectedType = widget.module?.type ?? AssetModuleType.custom;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final data = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'type': _selectedType.identifier,
        'is_active': _isActive,
        'table_columns': <Map<String, String>>[],
      };

      await widget.onSave(data);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.module != null;

    return AlertDialog(
      title: Text(isEditing ? 'Editar Módulo' : 'Novo Módulo'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Módulo',
                    hintText: 'Ex: Módulo Desktop',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nome é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    hintText: 'Descrição do módulo',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Descrição é obrigatória';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<AssetModuleType>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Módulo',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      AssetModuleType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              const Icon(Icons.category, size: 20),
                              const SizedBox(width: 8),
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
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Módulo Ativo'),
                  subtitle: const Text(
                    'Módulos inativos não aparecem no sistema',
                  ),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child:
              _isSaving
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : Text(isEditing ? 'Salvar' : 'Criar'),
        ),
      ],
    );
  }
}
