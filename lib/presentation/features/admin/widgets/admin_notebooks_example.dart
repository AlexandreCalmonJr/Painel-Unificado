// File: lib/admin/tabs/admin_notebooks_example.dart
// EXEMPLO DE USO DA TABELA DINÂMICA
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/presentation/features/auth/bloc/theme_controller.dart';

class AdminNotebooksExampleTab extends StatefulWidget {
  const AdminNotebooksExampleTab({super.key});

  @override
  State<AdminNotebooksExampleTab> createState() =>
      _AdminNotebooksExampleTabState();
}

class _AdminNotebooksExampleTabState extends State<AdminNotebooksExampleTab> {
  // Exemplo de dados (normalmente viriam de um controller/service)
  final List<Map<String, dynamic>> _notebooks = [
    {
      'id': '1',
      'assetName': 'Notebook Dell',
      'hostname': 'NB-DELL-001',
      'serialNumber': 'SN123456',
      'model': 'Latitude 5420',
      'manufacturer': 'Dell',
      'processor': 'Intel i7-1185G7',
      'ram': '16GB',
      'storage': '512GB SSD',
      'operatingSystem': 'Windows 11',
      'osVersion': '22H2',
      'batteryLevel': 85,
      'batteryHealth': 'Boa',
      'biometricReaderStatus': 'Funcionando',
      'ipAddress': '192.168.1.100',
      'macAddress': '00:1A:2B:3C:4D:5E',
      'currentUser': 'joao.silva',
      'uptime': '5d 3h',
      'antivirusStatus': true,
      'isEncrypted': true,
      'unit': 'Matriz',
      'sector': 'TI',
      'floor': '3º Andar',
      'status': 'online',
      'lastSeen': DateTime.now().subtract(const Duration(minutes: 5)),
    },
    {
      'id': '2',
      'assetName': 'Notebook HP',
      'hostname': 'NB-HP-002',
      'serialNumber': 'SN789012',
      'model': 'EliteBook 840',
      'manufacturer': 'HP',
      'processor': 'Intel i5-1135G7',
      'ram': '8GB',
      'storage': '256GB SSD',
      'operatingSystem': 'Windows 10',
      'osVersion': '21H2',
      'batteryLevel': 45,
      'batteryHealth': 'Regular',
      'biometricReaderStatus': 'N/D',
      'ipAddress': '192.168.1.101',
      'macAddress': '00:1A:2B:3C:4D:5F',
      'currentUser': 'maria.santos',
      'uptime': '2d 1h',
      'antivirusStatus': true,
      'isEncrypted': false,
      'unit': 'Filial SP',
      'sector': 'Vendas',
      'floor': '2º Andar',
      'status': 'offline',
      'lastSeen': DateTime.now().subtract(const Duration(hours: 2)),
    },
  ];

  void _handleView(Map<String, dynamic> asset) {
    // Implementar visualização de detalhes
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Detalhes: ${asset['assetName']}'),
            content: Text('Serial: ${asset['serialNumber']}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ],
          ),
    );
  }

  void _handleEdit(Map<String, dynamic> asset) {
    // Implementar edição
    Get.snackbar(
      'Editar',
      'Editando ${asset['assetName']}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _handleDelete(Map<String, dynamic> asset) {
    // Implementar exclusão com confirmação
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: Text('Deseja realmente excluir ${asset['assetName']}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _notebooks.removeWhere((n) => n['id'] == asset['id']);
                  });
                  Navigator.pop(context);
                  Get.snackbar(
                    'Sucesso',
                    'Asset excluído com sucesso',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                ),
                child: const Text('Excluir'),
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

      return Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface : AppColors.surfaceLightMode,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.border : AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.laptop,
                  size: 32,
                  color: themeController.currentPalette['primary'],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gerenciamento de Notebooks',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color:
                              isDark
                                  ? AppColors.textPrimary
                                  : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Visualize e gerencie todos os notebooks da organização',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isDark
                                  ? AppColors.textSecondary
                                  : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Adicionar novo notebook
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar Notebook'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeController.currentPalette['primary'],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // TODO: Implementar DynamicAssetTable
          // Tabela Dinâmica comentada temporariamente
          Expanded(
            child: Center(
              child: Text(
                'DynamicAssetTable será implementado em breve',
                style: TextStyle(
                  color:
                      isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                ),
              ),
            ),
          ),
          /* 
          Expanded(
            child: DynamicAssetTable(
              assetType: 'notebook',
              assets: _notebooks,
              onView: _handleView,
              onEdit: _handleEdit,
              onDelete: _handleDelete,
              // Opcional: definir colunas visíveis inicialmente
              initialVisibleColumns: [
                'assetName',
                'hostname',
                'serialNumber',
                'model',
                'processor',
                'ram',
                'batteryLevel',
                'status',
              ],
            ),
          ),
          */
        ],
      );
    });
  }
}
