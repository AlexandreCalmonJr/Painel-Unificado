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

  // State for columns
  List<Map<String, dynamic>> _columns = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.module?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.module?.description ?? '',
    );
    _isActive = widget.module?.isActive ?? true;
    _selectedType = widget.module?.type ?? AssetModuleType.custom;

    // Initialize columns from module or defaults
    if (widget.module != null) {
      _columns =
          widget.module!.tableColumns.map((c) {
            // Ensure width is preserved
            return {
              'label': c['label'],
              'dataKey': c['dataKey'],
              'width': c['width'],
              'isVisible': c['isVisible'],
            };
          }).toList();
    }
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
        'table_columns': _columns,
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

  Future<void> _showColumnDialog({
    Map<String, dynamic>? column,
    int? index,
  }) async {
    final labelController = TextEditingController(
      text: (column?['label'] as String?) ?? '',
    );
    final keyController = TextEditingController(
      text: (column?['dataKey'] as String?) ?? '',
    );
    final widthController = TextEditingController(
      text: column?['width']?.toString() ?? '',
    );

    await showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(column == null ? 'Nova Coluna' : 'Editar Coluna'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: labelController,
                  decoration: const InputDecoration(
                    labelText: 'Título da Coluna (Label)',
                    hintText: 'Ex: Nome do Ativo',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: keyController,
                  decoration: const InputDecoration(
                    labelText: 'Chave do JSON (Data Key)',
                    hintText: 'Ex: asset_name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: widthController,
                  decoration: const InputDecoration(
                    labelText: 'Largura (Opcional)',
                    hintText: 'Ex: 200',
                    border: OutlineInputBorder(),
                    suffixText: 'px',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (labelController.text.isEmpty ||
                      keyController.text.isEmpty) {
                    return;
                  }

                  final newColumn = {
                    'label': labelController.text,
                    'dataKey': keyController.text,
                    'width': double.tryParse(widthController.text),
                    'isVisible': true, // Default to true
                  };

                  setState(() {
                    if (column == null) {
                      _columns.add(newColumn);
                    } else if (index != null) {
                      _columns[index] = newColumn;
                    }
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.module != null;

    return DefaultTabController(
      length: 2,
      child: AlertDialog(
        title: Text(isEditing ? 'Editar Módulo' : 'Novo Módulo'),
        content: SizedBox(
          width: 600,
          height: 500,
          child: Column(
            children: [
              const TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primary,
                tabs: [Tab(text: 'Geral'), Tab(text: 'Colunas')],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  children: [
                    // TAB 1: GERAL
                    SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
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
                                          Icon(_getModuleIcon(type), size: 20),
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
                              onChanged:
                                  (value) => setState(() => _isActive = value),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // TAB 2: COLUNAS
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Configuração de Colunas',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _showColumnDialog(),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Adicionar'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child:
                              _columns.isEmpty
                                  ? const Center(
                                    child: Text(
                                      'Nenhuma coluna configurada.\nAdicione colunas para exibir dados na tabela.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  )
                                  : ReorderableListView.builder(
                                    itemCount: _columns.length,
                                    onReorder: (oldIndex, newIndex) {
                                      setState(() {
                                        if (newIndex > oldIndex) {
                                          newIndex -= 1;
                                        }
                                        final item = _columns.removeAt(
                                          oldIndex,
                                        );
                                        _columns.insert(newIndex, item);
                                      });
                                    },
                                    itemBuilder: (context, index) {
                                      final col = _columns[index];
                                      return Card(
                                        key: ValueKey(
                                          '${col['dataKey']}_$index',
                                        ),
                                        margin: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: ListTile(
                                          leading: const Icon(
                                            Icons.drag_handle,
                                          ),
                                          title: Text(
                                            (col['label'] as String?) ?? 'N/A',
                                          ),
                                          subtitle: Text(
                                            'Key: ${col['dataKey']} | Width: ${col['width'] ?? 'Auto'}',
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  color: Colors.blue,
                                                ),
                                                onPressed:
                                                    () => _showColumnDialog(
                                                      column: col,
                                                      index: index,
                                                    ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _columns.removeAt(index);
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed:
                _isSaving ? null : () => Navigator.of(context).pop(false),
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
      ),
    );
  }

  IconData _getModuleIcon(AssetModuleType type) {
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
