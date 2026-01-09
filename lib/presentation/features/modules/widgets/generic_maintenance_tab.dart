// File: lib/tabs/generic_maintenance_tab.dart (CORRIGIDO)
import 'package:flutter/material.dart';
import 'package:painel_windowns/data/models/asset_module_base_model.dart';
import 'package:painel_windowns/modules/widgets/generic_managed_assets_card.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/module_management_service.dart';

class GenericMaintenanceTab extends StatelessWidget {

  const GenericMaintenanceTab({
    super.key,
    required this.allAssets,
    required this.moduleConfig,
    required this.moduleService,
    required this.onRefresh,
    required this.showSnackbar,
    // ❌ REMOVIDO: onEditAsset
    // ❌ REMOVIDO: onDeleteAsset
    required this.columns,
    required this.authService,
  });
  final List<ManagedAsset> allAssets;
  final AssetModuleConfig moduleConfig;
  final ModuleManagementService moduleService;
  final VoidCallback onRefresh;
  final Function(String, {bool isError}) showSnackbar;
  // ❌ REMOVIDO: onEditAsset
  // ❌ REMOVIDO: onDeleteAsset
  final List<TableColumnConfig> columns;
  final AuthService authService;

  // Esta função _updateMaintenanceStatus está obsoleta, pois
  // o 'asset_command_controls.dart' agora faz isso.
  // Pode ser removida se não for usada em outro local.
  /* Future<void> _updateMaintenanceStatus(
      ManagedAsset asset, bool setMaintenance) async {
    // ...
  }
  */

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
            columns: columns,
            showActions: true,
            
            // ✅ CORREÇÃO APLICADA AQUI
            onAssetChanged: onRefresh, // Passa a função de recarregar
            
            authService: authService,
            moduleConfig: moduleConfig,
          ),
        ),
      ],
    );
  }
}