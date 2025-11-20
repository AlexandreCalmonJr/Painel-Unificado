// File: lib/admin/tabs/admin_modules_tab.dart (MELHORADO COM REORDER + CSV)

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
    'hostname': 'Hostname',
    'serial_number': 'Serial',
    'status': 'Status',
    'location': 'Localização (Original)',
    'ip_address': 'Endereço IP',
    'unit': 'Unidade',
    'sector_floor': 'Setor / Andar',
    'mac_address': 'MAC Address',
    'battery_level': 'Bateria %',
    'model': 'Modelo',
    'manufacturer': 'Fabricante',
    'current_user': 'Usuario Logado',
    'updated_at': 'Ultima sincronização',
    'uptime': 'Tempo Ligado',
    'processor': 'Processador',
    'ram': 'Memória RAM',
    'storage': 'Armazenamento',
    'storage_type': 'Tipo de HD',
    'operating_system': 'Sistema Operacional',
    'os_version': 'Versão do SO',
    'biometric_reader': 'Leitor Biométrico',
    'connected_printer': 'Impressora Conectada',
    'java_version': 'Versão Java',
    'browser_version': 'Navegador',
    'antivirus_status': 'Antivírus Ativo',
    'screen_size': 'Tamanho da Tela',
    'resolution': 'Resolução',
    'hdmi_input': 'Entrada HDMI',
    'firmware_version': 'Versão Firmware',
    'printer_status': 'Status da Impressora',
    'connection_type': 'Tipo de Conexão',
    'total_page_count': 'Total de Páginas',
    'toner_levels': 'Níveis de Toner',
    'host_computer_name': 'Computador Host',
  };

  final List<Map<String, String>> _desktopColumns = [
    {'dataKey': 'asset_name', 'label': 'Nome'},
    {'dataKey': 'hostname', 'label': 'Hostname'},
    {'dataKey': 'serial_number', 'label': 'Serial'},
    {'dataKey': 'status', 'label': 'Status'},
    {'dataKey': 'current_user', 'label': 'Usuário AD'},
    {'dataKey': 'updated_at', 'label': 'Última Sync'},
    {'dataKey': 'uptime', 'label': 'Tempo Ligado'},
    {'dataKey': 'ip_address', 'label': 'IP'},
    {'dataKey': 'sector_floor', 'label': 'Setor / Andar'},
    {'dataKey': 'processor', 'label': 'Processador'},
    {'dataKey': 'ram', 'label': 'Memória'},
    {'dataKey': 'storage', 'label': 'Armazenamento'},
    {'dataKey': 'storage_type', 'label': 'Tipo de HD'},
    {'dataKey': 'biometric_reader', 'label': 'Leitor Biométrico'},
    {'dataKey': 'connected_printer', 'label': 'Impressora'},
    {'dataKey': 'java_version', 'label': 'Java'},
    {'dataKey': 'browser_version', 'label': 'Navegador'},
  ];

  final List<Map<String, String>> _panelColumns = [
    {'dataKey': 'asset_name', 'label': 'Nome'},
    {'dataKey': 'hostname', 'label': 'Hostname'},
    {'dataKey': 'serial_number', 'label': 'Serial'},
    {'dataKey': 'status', 'label': 'Status'},
    {'dataKey': 'ip_address', 'label': 'IP'},
    {'dataKey': 'sector_floor', 'label': 'Setor / Andar'},
    {'dataKey': 'model', 'label': 'Modelo'},
    {'dataKey': 'screen_size', 'label': 'Tamanho'},
    {'dataKey': 'resolution', 'label': 'Resolução'},
    {'dataKey': 'hdmi_input', 'label': 'Entrada HDMI'},
    {'dataKey': 'firmware_version', 'label': 'Firmware'},
    {'dataKey': 'updated_at', 'label': 'Última Sync'},
  ];

  final List<Map<String, String>> _printerColumns = [
    {'dataKey': 'asset_name', 'label': 'Nome'},
    {'dataKey': 'hostname', 'label': 'Hostname'},
    {'dataKey': 'serial_number', 'label': 'Serial'},
    {'dataKey': 'status', 'label': 'Status'},
    {'dataKey': 'printer_status', 'label': 'Status da Impressora'},
    {'dataKey': 'connection_type', 'label': 'Conexão'},
    {'dataKey': 'ip_address', 'label': 'IP / USB'},
    {'dataKey': 'sector_floor', 'label': 'Setor / Andar'},
    {'dataKey': 'total_page_count', 'label': 'Total de Páginas'},
    {'dataKey': 'toner_levels', 'label': 'Níveis de Toner'},
    {'dataKey': 'host_computer_name', 'label': 'Computador Host'},
    {'dataKey': 'updated_at', 'label': 'Última Sync'},
  ];

  final List<Map<String, String>> _notebookColumns = [
    {'dataKey': 'asset_name', 'label': 'Nome'},
    {'dataKey': 'hostname', 'label': 'Hostname'},
    {'dataKey': 'serial_number', 'label': 'Serial'},
    {'dataKey': 'status', 'label': 'Status'},
    {'dataKey': 'ip_address', 'label': 'IP'},
    {'dataKey': 'sector_floor', 'label': 'Setor / Andar'},
    {'dataKey': 'battery_level', 'label': 'Bateria'},
    {'dataKey': 'model', 'label': 'Modelo'},
    {'dataKey': 'processor', 'label': 'Processador'},
    {'dataKey': 'ram', 'label': 'Memória'},
    {'dataKey': 'storage', 'label': 'Armazenamento'},
    {'dataKey': 'operating_system', 'label': 'Sistema Operacional'},
    {'dataKey': 'current_user', 'label': 'Usuário AD'},
    {'dataKey': 'updated_at', 'label': 'Última Sync'},
    {'dataKey': 'uptime', 'label': 'Tempo Ligado'},
  ];

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

  void _updateSelectedColumnsFromPreset(
    AssetModuleType type,
    Map<String, bool> selectedColumnsMap,
  ) {
    selectedColumnsMap.clear();

    List<Map<String, String>> preset = [];
    switch (type) {
      case AssetModuleType.notebook:
        preset = _notebookColumns;
        break;
      case AssetModuleType.desktop:
        preset = _desktopColumns;
        break;
      case AssetModuleType.panel:
        preset = _panelColumns;
        break;
      case AssetModuleType.printer:
        preset = _printerColumns;
        break;
      default:
        selectedColumnsMap['asset_name'] = true;
        selectedColumnsMap['serial_number'] = true;
        selectedColumnsMap['status'] = true;
        selectedColumnsMap['sector_floor'] = true;
        return;
    }

    for (var col in preset) {
      // Adiciona ao mapa apenas se a coluna existir no mapa padrão
      if (_standardColumns.containsKey(col['dataKey'])) {
        selectedColumnsMap[col['dataKey']!] = true;
      }
    }
  }

  // ✅ NOVO: Dialog com reordenação de colunas
  Future<void> _showCreateModuleDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    AssetModuleType selectedType = AssetModuleType.custom;

    // Lista ordenável de colunas
    List<String> selectedColumnKeys = [
      'asset_name',
      'serial_number',
      'status',
      'sector_floor',
    ];
    Map<String, bool> availableColumns = Map.from(
      _standardColumns.map((k, v) => MapEntry(k, false)),
    );

    // Marca as iniciais como selecionadas
    for (var key in selectedColumnKeys) {
      availableColumns[key] = true;
    }

    final customColumnsController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setStateDialog) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Row(
                    children: [
                      const Icon(Icons.add_box, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Criar Novo Módulo')),
                      IconButton(
                        icon: const Icon(
                          Icons.help_outline,
                          color: Colors.grey,
                        ),
                        tooltip: 'Arraste as colunas para reordenar',
                        onPressed: () {
                          _showSnackbar(
                            'Arraste as colunas selecionadas para mudar a ordem de exibição',
                          );
                        },
                      ),
                    ],
                  ),
                  content: SizedBox(
                    width: 650,
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.description),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<AssetModuleType>(
                            initialValue: selectedType,
                            decoration: InputDecoration(
                              labelText: 'Tipo de Módulo',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.category),
                            ),
                            items:
                                AssetModuleType.values.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Row(
                                      children: [
                                        Icon(
                                          _getIconData(type.iconName),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(type.displayName),
                                      ],
                                    ),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setStateDialog(() {
                                selectedType = value!;
                                // Atualiza colunas baseado no preset
                                _updateSelectedColumnsFromPreset(
                                  selectedType,
                                  availableColumns,
                                );
                                selectedColumnKeys =
                                    availableColumns.entries
                                        .where((e) => e.value)
                                        .map((e) => e.key)
                                        .toList();
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          const Divider(),

                          // ✅ SEÇÃO DE COLUNAS COM REORDENAÇÃO
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Colunas da Tabela',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  setStateDialog(() {
                                    availableColumns.updateAll(
                                      (key, value) => false,
                                    );
                                    selectedColumnKeys.clear();
                                  });
                                },
                                icon: const Icon(Icons.clear_all, size: 16),
                                label: const Text(
                                  'Limpar Seleção',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Lista de colunas disponíveis (checkboxes)
                          Container(
                            height: 180,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView(
                              children:
                                  _standardColumns.entries.map((entry) {
                                    final key = entry.key;
                                    final label = entry.value;
                                    return CheckboxListTile(
                                      dense: true,
                                      title: Text(
                                        label,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      subtitle: Text(
                                        'Chave: $key',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      value: availableColumns[key] ?? false,
                                      onChanged: (bool? value) {
                                        setStateDialog(() {
                                          availableColumns[key] = value!;
                                          if (value) {
                                            selectedColumnKeys.add(key);
                                          } else {
                                            selectedColumnKeys.remove(key);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ✅ LISTA REORDENÁVEL DE COLUNAS SELECIONADAS
                          if (selectedColumnKeys.isNotEmpty) ...[
                            Row(
                              children: const [
                                Icon(
                                  Icons.drag_handle,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Ordem de Exibição (arraste para reordenar)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                border: Border.all(color: Colors.blue[200]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ReorderableListView(
                                onReorder: (oldIndex, newIndex) {
                                  setStateDialog(() {
                                    if (newIndex > oldIndex) newIndex--;
                                    final item = selectedColumnKeys.removeAt(
                                      oldIndex,
                                    );
                                    selectedColumnKeys.insert(newIndex, item);
                                  });
                                },
                                children:
                                    selectedColumnKeys.asMap().entries.map((
                                      entry,
                                    ) {
                                      final index = entry.key;
                                      final key = entry.value;
                                      return ListTile(
                                        key: ValueKey(key),
                                        dense: true,
                                        leading: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.drag_indicator,
                                              size: 20,
                                              color: Colors.blue,
                                            ),
                                            const SizedBox(width: 4),
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: const BoxDecoration(
                                                color: Colors.blue,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${index + 1}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        title: Text(
                                          _standardColumns[key] ?? key,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            setStateDialog(() {
                                              selectedColumnKeys.remove(key);
                                              availableColumns[key] = false;
                                            });
                                          },
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),
                          TextField(
                            controller: customColumnsController,
                            decoration: InputDecoration(
                              labelText: 'Colunas Customizadas (Opcional)',
                              hintText: 'chave:Label, outra_chave:Outro Label',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                          _showSnackbar(
                            'O nome do módulo é obrigatório',
                            isError: true,
                          );
                          return;
                        }

                        // Processa colunas na ordem selecionada
                        List<Map<String, String>> tableColumns = [];
                        for (var key in selectedColumnKeys) {
                          tableColumns.add({
                            'dataKey': key,
                            'label': _standardColumns[key]!,
                          });
                        }

                        // Adiciona colunas customizadas
                        if (customColumnsController.text.trim().isNotEmpty) {
                          try {
                            final parts = customColumnsController.text
                                .trim()
                                .split(',');
                            for (var part in parts) {
                              final pair = part.split(':');
                              if (pair.length == 2 &&
                                  pair[0].trim().isNotEmpty &&
                                  pair[1].trim().isNotEmpty) {
                                tableColumns.add({
                                  'dataKey': pair[0].trim(),
                                  'label': pair[1].trim(),
                                });
                              }
                            }
                          } catch (e) {
                            _showSnackbar(
                              'Formato das colunas customizadas inválido.',
                              isError: true,
                            );
                            return;
                          }
                        }

                        try {
                          await _moduleService.createModule(
                            name: nameController.text.trim(),
                            description: descriptionController.text.trim(),
                            type: selectedType,
                            tableColumns: tableColumns,
                          );

                          Navigator.of(context).pop();
                          _showSnackbar('Módulo criado com sucesso!');
                          _loadModules();
                        } catch (e) {
                          _showSnackbar(
                            'Erro ao criar módulo: $e',
                            isError: true,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Criar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _showModuleDetailsDialog(AssetModuleConfig module) async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(_getIconData(module.type.iconName), color: Colors.blue),
                const SizedBox(width: 8),
                Text(module.name),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Descrição', module.description),
                  _buildDetailRow('Tipo', module.type.displayName),
                  _buildDetailRow(
                    'Status',
                    module.isActive ? 'Ativo' : 'Inativo',
                  ),
                  _buildDetailRow(
                    'Customizado',
                    module.isCustom ? 'Sim' : 'Não',
                  ),
                  _buildDetailRow('Criado em', _formatDate(module.createdAt)),
                  if (module.updatedAt != null)
                    _buildDetailRow(
                      'Atualizado em',
                      _formatDate(module.updatedAt!),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Colunas da Tabela (${module.tableColumns.length}):',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (module.tableColumns.isEmpty)
                    const Text(
                      'Nenhuma coluna configurada',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ...module.tableColumns.asMap().entries.map((entry) {
                    final index = entry.key;
                    final col = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${col.label} (${col.dataKey})',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fechar'),
              ),
            ],
          ),
    );
  }

  Future<void> _showEditModuleDialog(AssetModuleConfig module) async {
    final nameController = TextEditingController(text: module.name);
    final descriptionController = TextEditingController(
      text: module.description,
    );
    AssetModuleType selectedType = module.type;

    // Carrega colunas existentes
    List<String> selectedColumnKeys =
        module.tableColumns.map((col) => col.dataKey).toList();

    Map<String, bool> availableColumns = Map.from(
      _standardColumns.map((k, v) => MapEntry(k, false)),
    );
    for (var col in module.tableColumns) {
      if (availableColumns.containsKey(col.dataKey)) {
        availableColumns[col.dataKey] = true;
      }
    }

    String customColumnsText = module.tableColumns
        .where((col) => !_standardColumns.containsKey(col.dataKey))
        .map((col) => '${col.dataKey}:${col.label}')
        .join(', ');

    final customColumnsController = TextEditingController(
      text: customColumnsText,
    );

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setStateDialog) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Row(
                    children: [
                      const Icon(Icons.edit, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('Editar Módulo')),
                      IconButton(
                        icon: const Icon(
                          Icons.help_outline,
                          color: Colors.grey,
                        ),
                        tooltip: 'Arraste as colunas para reordenar',
                        onPressed: () {
                          _showSnackbar(
                            'Arraste as colunas selecionadas para mudar a ordem de exibição',
                          );
                        },
                      ),
                    ],
                  ),
                  content: SizedBox(
                    width: 650,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Nome do Módulo',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.label),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: descriptionController,
                            maxLines: 2,
                            decoration: InputDecoration(
                              labelText: 'Descrição',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.description),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<AssetModuleType>(
                            initialValue: selectedType,
                            decoration: InputDecoration(
                              labelText:
                                  'Tipo de Módulo (Não pode ser alterado)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.category),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            onChanged: null,
                            items:
                                AssetModuleType.values.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Row(
                                      children: [
                                        Icon(
                                          _getIconData(type.iconName),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(type.displayName),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Colunas da Tabela',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  setStateDialog(() {
                                    availableColumns.updateAll(
                                      (key, value) => false,
                                    );
                                    selectedColumnKeys.clear();
                                  });
                                },
                                icon: const Icon(Icons.clear_all, size: 16),
                                label: const Text(
                                  'Limpar Seleção',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 180,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView(
                              children:
                                  _standardColumns.entries.map((entry) {
                                    final key = entry.key;
                                    final label = entry.value;
                                    return CheckboxListTile(
                                      dense: true,
                                      title: Text(
                                        label,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      subtitle: Text(
                                        'Chave: $key',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      value: availableColumns[key] ?? false,
                                      onChanged: (bool? value) {
                                        setStateDialog(() {
                                          availableColumns[key] = value!;
                                          if (value) {
                                            if (!selectedColumnKeys.contains(
                                              key,
                                            )) {
                                              selectedColumnKeys.add(key);
                                            }
                                          } else {
                                            selectedColumnKeys.remove(key);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (selectedColumnKeys.isNotEmpty) ...[
                            Row(
                              children: const [
                                Icon(
                                  Icons.drag_handle,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Ordem de Exibição (arraste para reordenar)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                border: Border.all(color: Colors.blue[200]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ReorderableListView(
                                onReorder: (oldIndex, newIndex) {
                                  setStateDialog(() {
                                    if (newIndex > oldIndex) newIndex--;
                                    final item = selectedColumnKeys.removeAt(
                                      oldIndex,
                                    );
                                    selectedColumnKeys.insert(newIndex, item);
                                  });
                                },
                                children:
                                    selectedColumnKeys.asMap().entries.map((
                                      entry,
                                    ) {
                                      final index = entry.key;
                                      final key = entry.value;
                                      return ListTile(
                                        key: ValueKey(key),
                                        dense: true,
                                        leading: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.drag_indicator,
                                              size: 20,
                                              color: Colors.blue,
                                            ),
                                            const SizedBox(width: 4),
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: const BoxDecoration(
                                                color: Colors.blue,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${index + 1}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        title: Text(
                                          _standardColumns[key] ?? key,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            size: 18,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            setStateDialog(() {
                                              selectedColumnKeys.remove(key);
                                              availableColumns[key] = false;
                                            });
                                          },
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          TextField(
                            controller: customColumnsController,
                            decoration: InputDecoration(
                              labelText: 'Colunas Customizadas (Opcional)',
                              hintText: 'chave:Label, outra_chave:Outro Label',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                          _showSnackbar(
                            'O nome do módulo é obrigatório',
                            isError: true,
                          );
                          return;
                        }

                        // Processar colunas (similar ao create)
                        List<Map<String, String>> tableColumns = [];
                        for (var key in selectedColumnKeys) {
                          if (_standardColumns.containsKey(key)) {
                            tableColumns.add({
                              'dataKey': key,
                              'label': _standardColumns[key]!,
                            });
                          }
                        }
                        if (customColumnsController.text.trim().isNotEmpty) {
                          try {
                            final parts = customColumnsController.text
                                .trim()
                                .split(',');
                            for (var part in parts) {
                              final pair = part.split(':');
                              if (pair.length == 2 &&
                                  pair[0].trim().isNotEmpty &&
                                  pair[1].trim().isNotEmpty) {
                                tableColumns.add({
                                  'dataKey': pair[0].trim(),
                                  'label': pair[1].trim(),
                                });
                              }
                            }
                          } catch (e) {
                            _showSnackbar(
                              'Formato das colunas customizadas inválido.',
                              isError: true,
                            );
                            return;
                          }
                        }

                        try {
                          await _moduleService.updateModule(
                            moduleId: module.id,
                            name: nameController.text.trim(),
                            description: descriptionController.text.trim(),
                            type: selectedType,
                            tableColumns: tableColumns,
                          );

                          Navigator.of(context).pop();
                          _showSnackbar('Módulo atualizado com sucesso!');
                          _loadModules();
                        } catch (e) {
                          _showSnackbar(
                            'Erro ao atualizar módulo: $e',
                            isError: true,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Salvar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _confirmDeleteModule(AssetModuleConfig module) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: const [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text('Confirmar Exclusão'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Deseja realmente excluir o módulo:'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    module.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Esta ação não pode ser desfeita.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Excluir',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await _moduleService.deleteModule(module.id);
        _showSnackbar('Módulo excluído com sucesso!');
        _loadModules();
      } catch (e) {
        _showSnackbar('Erro ao excluir módulo: $e', isError: true);
      }
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(flex: 3, child: Text(value.isNotEmpty ? value : 'N/D')),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.apps, color: Colors.blue, size: 28),
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
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Erro ao carregar módulos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, color: Colors.grey, size: 64),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum módulo cadastrado',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Crie um novo módulo para começar'),
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

  Widget _buildModuleCard(AssetModuleConfig module) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showModuleDetailsDialog(module),
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
                      color:
                          module.isActive
                              ? Colors.blue.shade100
                              : Colors.grey.shade200,
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
                        _showEditModuleDialog(module);
                      } else if (value == 'delete') {
                        _confirmDeleteModule(module);
                      } else if (value == 'toggle') {
                        _moduleService
                            .updateModule(
                              name: module.name,
                              description: module.description,
                              type: module.type,
                              moduleId: module.id,
                              isActive: !module.isActive,
                              tableColumns:
                                  module.tableColumns
                                      .map((col) => col.toJson())
                                      .toList(),
                            )
                            .then((_) {
                              _showSnackbar('Status do módulo atualizado!');
                              _loadModules();
                            })
                            .catchError((e) {
                              _showSnackbar(
                                'Erro ao atualizar status: $e',
                                isError: true,
                              );
                            });
                      }
                    },
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 'toggle',
                            child: Row(
                              children: [
                                Icon(
                                  module.isActive
                                      ? Icons.visibility_off
                                      : Icons.visibility,
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
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                module.description.isNotEmpty
                    ? module.description
                    : 'Sem descrição',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
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
                      color:
                          module.isActive
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      module.isActive ? 'Ativo' : 'Inativo',
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            module.isActive
                                ? Colors.green.shade700
                                : Colors.red.shade700,
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
