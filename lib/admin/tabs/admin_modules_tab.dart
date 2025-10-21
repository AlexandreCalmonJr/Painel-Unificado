// File: lib/admin/tabs/admin_modules_tab.dart

import 'package:flutter/material.dart';
import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/module_management_service.dart';

class AdminModulesTab extends StatefulWidget {
  final AuthService authService;
  const AdminModulesTab({super.key, required this.authService});

  @override
  State<AdminModulesTab> createState() => _AdminModulesTabState();
}

class _AdminModulesTabState extends State<AdminModulesTab> {
  late final ModuleManagementService _moduleService;
  List<AssetModuleConfig> modules = [];
  bool isLoading = false;
  String? errorMessage;

  // Mapa de colunas padrão disponíveis
  final Map<String, String> _standardColumns = {
    'asset_name': 'Nome do Ativo',
    'serial_number': 'Serial',
    'status': 'Status',
    'location': 'Localização (Original)',
    'sector_floor': 'Setor / Andar', // Nosso campo combinado
    'ip_address': 'Endereço IP',
    'hostname': 'Hostname',
    'battery_level': 'Bateria %',
    'model': 'Modelo',
    'manufacturer': 'Fabricante',
  };

  @override
  void initState() {
    super.initState();
    _moduleService = ModuleManagementService(authService: widget.authService);
    _loadModules();
  }

  Future<void> _loadModules() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final loadedModules = await _moduleService.listModules();
      if (mounted) {
        setState(() {
          modules = loadedModules;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
        _showSnackbar('Erro ao carregar módulos: $e', isError: true);
      }
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _showCreateModuleDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    AssetModuleType selectedType = AssetModuleType.custom;
    
    // Estado para as colunas selecionadas
    Map<String, bool> selectedColumns = {
      'asset_name': true, // Pré-selecionados
      'serial_number': true,
      'status': true,
      'sector_floor': true,
    };
    
    final customColumnsController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.add_box, color: Colors.blue),
              const SizedBox(width: 8),
              const Text('Criar Novo Módulo'),
            ],
          ),
          content: SizedBox(
            width: 600, // Define uma largura maior para o dialog
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nome do Módulo',
                      hintText: 'Ex: Módulo de Scanners',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.label),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Descrição',
                      hintText: 'Descreva o propósito deste módulo...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<AssetModuleType>(
                    value: selectedType,
                    decoration: InputDecoration(
                      labelText: 'Tipo de Módulo',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.category),
                    ),
                    items: AssetModuleType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Icon(_getIconData(type.iconName), size: 20),
                            const SizedBox(width: 8),
                            Text(type.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedType = value!;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  const Divider(),
                  const Text('Configuração da Tabela', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    'Selecione as colunas padrão para exibir na tabela deste módulo:',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  // --- SELEÇÃO DE COLUNAS ---
                  Container(
                    height: 200, // Altura fixa para a lista
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView(
                      children: _standardColumns.entries.map((entry) {
                        final key = entry.key;
                        final label = entry.value;
                        return CheckboxListTile(
                          title: Text(label),
                          subtitle: Text('Chave: $key', style: TextStyle(fontSize: 10)),
                          controlAffinity: ListTileControlAffinity.leading,
                          value: selectedColumns[key] ?? false,
                          onChanged: (bool? value) {
                            setStateDialog(() {
                              selectedColumns[key] = value!;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: customColumnsController,
                    decoration: InputDecoration(
                      labelText: 'Colunas Customizadas (Opcional)',
                      hintText: 'chave:Label, outra_chave:Outro Label',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.add_circle_outline),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  _showSnackbar('O nome do módulo é obrigatório', isError: true);
                  return;
                }

                // --- PROCESSAR COLUNAS ---
                List<Map<String, String>> tableColumns = [];
                // Adiciona colunas padrão selecionadas
                selectedColumns.forEach((key, isSelected) {
                  if (isSelected) {
                    tableColumns.add({
                      'dataKey': key,
                      'label': _standardColumns[key]!,
                    });
                  }
                });
                // Adiciona colunas customizadas
                if (customColumnsController.text.trim().isNotEmpty) {
                  try {
                    final parts = customColumnsController.text.trim().split(',');
                    for (var part in parts) {
                      final pair = part.split(':');
                      if (pair.length == 2 && pair[0].trim().isNotEmpty && pair[1].trim().isNotEmpty) {
                        tableColumns.add({
                          'dataKey': pair[0].trim(),
                          'label': pair[1].trim(),
                        });
                      }
                    }
                  } catch (e) {
                    _showSnackbar('Formato das colunas customizadas inválido.', isError: true);
                    return;
                  }
                }
                
                // --- FIM DO PROCESSAMENTO ---

                try {
                  await _moduleService.createModule(
                    name: nameController.text.trim(),
                    description: descriptionController.text.trim(),
                    type: selectedType,
                    tableColumns: tableColumns, // Envia a configuração
                  );

                  Navigator.of(context).pop();
                  _showSnackbar('Módulo criado com sucesso!');
                  _loadModules();
                } catch (e) {
                  _showSnackbar('Erro ao criar módulo: $e', isError: true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Criar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // (Os métodos _showModuleDetailsDialog, _showEditModuleDialog, _confirmDeleteModule
  //  e build() permanecem, mas _showEditModuleDialog também precisará
  //  ser atualizado para carregar e salvar a configuração das colunas,
  //  o que é uma lógica mais complexa de "edição".)

  // ... (Restante do arquivo: _buildDetailRow, _formatDate, _getIconData, build, _buildModuleCard)
  // ...
    IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'phone_android':
        return Icons.phone_android;
      case 'desktop_windows':
        return Icons.desktop_windows;
      case 'computer':
        return Icons.computer;
      case 'laptop':
        return Icons.laptop;
      case 'tv':
        return Icons.tv;
      case 'print':
        return Icons.print;
      case 'qr_code_scanner':
        return Icons.qr_code_scanner;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple.shade50, Colors.blue.shade50],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.apps, color: Colors.blue, size: 28),
                    const SizedBox(width: 8),
                    const Text(
                      'Gerenciamento de Módulos',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _showCreateModuleDialog,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Criar Módulo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                ),
              )
            else if (errorMessage != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar módulos',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadModules,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                ),
              )
            else if (modules.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, color: Colors.grey, size: 64),
                      const SizedBox(height: 16),
                      const Text(
                        'Nenhum módulo cadastrado',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('Crie um novo módulo para começar'),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: modules.length,
                  itemBuilder: (context, index) {
                    final module = modules[index];
                    return _buildModuleCard(module);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // ... (build() e _buildModuleCard() e outros helpers inalterados)
  Widget _buildModuleCard(AssetModuleConfig module) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {}, // _showModuleDetailsDialog(module),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: module.isActive ? Colors.blue.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconData(module.type.iconName),
                      color: module.isActive ? Colors.blue : Colors.grey,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'edit') {
                        // _showEditModuleDialog(module);
                      } else if (value == 'delete') {
                        // _confirmDeleteModule(module);
                      } else if (value == 'toggle') {
                        _moduleService.updateModule(
                          moduleId: module.id,
                          isActive: !module.isActive,
                        ).then((_) {
                          _showSnackbar('Status do módulo atualizado!');
                          _loadModules();
                        }).catchError((e) {
                          _showSnackbar('Erro ao atualizar status: $e', isError: true);
                        });
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(
                              module.isActive ? Icons.visibility_off : Icons.visibility,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(module.isActive ? 'Desativar' : 'Ativar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Excluir'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                module.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                module.type.displayName,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                module.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: module.isActive
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      module.isActive ? 'Ativo' : 'Inativo',
                      style: TextStyle(
                        fontSize: 11,
                        color: module.isActive ? Colors.green.shade700 : Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (module.isCustom) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Custom',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.purple.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}