// File: lib/tabs/generic_maintenance_tab.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/modules/widgets/generic_managed_assets_card.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/module_management_service.dart';

class GenericMaintenanceTab extends StatelessWidget {
  final List<ManagedAsset> allAssets;
  final AssetModuleConfig moduleConfig;
  final ModuleManagementService moduleService;
  final VoidCallback onRefresh;
  final Function(String, {bool isError}) showSnackbar;
  final Function(ManagedAsset) onEditAsset;
  final Function(ManagedAsset) onDeleteAsset;
  final List<TableColumnConfig> columns; // <-- CAMPO ADICIONADO
  final AuthService authService; // ✅ CORRIGIDO: Removido o segundo moduleConfig


  const GenericMaintenanceTab({
    super.key,
    required this.allAssets,
    required this.moduleConfig,
    required this.moduleService,
    required this.onRefresh,
    required this.showSnackbar,
    required this.onEditAsset,
    required this.onDeleteAsset,
    required this.columns,
    required this.authService,
  });

  Future<void> _updateMaintenanceStatus(ManagedAsset asset, bool setMaintenance) async {
    final newStatus = setMaintenance ? 'maintenance' : 'offline'; // Define offline ao retornar
    try {
      await moduleService.updateAsset(
        moduleId: moduleConfig.id,
        assetId: asset.id,
        updateData: {'status': newStatus},
      );
      showSnackbar('Status de ${asset.assetName} atualizado para $newStatus');
      onRefresh(); // Atualiza a lista
    } catch (e) {
      showSnackbar('Erro ao atualizar status: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maintenanceAssets = allAssets
        .where((a) => a.status.toLowerCase() == 'maintenance')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manutenção - ${moduleConfig.name}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ativos que estão atualmente marcados para manutenção.',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: GenericManagedAssetsCard(
            title: 'Ativos em Manutenção (${maintenanceAssets.length})',
            assets: maintenanceAssets,
            columns: columns, // <-- Passa as colunas
            showActions: true,
            onAssetUpdate: onEditAsset,
            onAssetDelete: onDeleteAsset,
            onMaintenanceUpdate: _updateMaintenanceStatus,
            authService: authService,
            moduleConfig: moduleConfig,
          ),
        ),
      ],
    );
  }
}