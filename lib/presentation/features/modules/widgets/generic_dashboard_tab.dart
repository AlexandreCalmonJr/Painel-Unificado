// File: lib/tabs/generic_dashboard_tab.dart (CORRIGIDO)
import 'package:flutter/material.dart';
import 'package:painel_windowns/data/models/asset_module_base_model.dart';
import 'package:painel_windowns/presentation/features/modules/widgets/generic_managed_assets_card.dart';
import 'package:painel_windowns/presentation/shared/widgets/cards/stat_card.dart';

class GenericDashboardTab extends StatelessWidget { // <-- ADICIONADO

  const GenericDashboardTab({
    super.key,
    required this.allAssets,
    required this.onRefresh,
    required this.getModuleIcon,
    required this.moduleType,
    required this.columns, // <-- CAMPO ADICIONADO
    required this.authService,
    required this.moduleConfig,// <-- ADICIONADO
  });
  final List<ManagedAsset> allAssets;
  final VoidCallback onRefresh;
  final IconData Function() getModuleIcon;
  final String moduleType;
  final List<TableColumnConfig> columns; // <-- CAMPO ADICIONADO
  final dynamic authService;
  
  final dynamic moduleConfig;

  @override
  Widget build(BuildContext context) {
    final int onlineCount =
        allAssets.where((a) => a.status.toLowerCase() == 'online').length;
    final int offlineCount =
        allAssets.where((a) => a.status.toLowerCase() == 'offline').length;
    final int maintenanceCount =
        allAssets.where((a) => a.status.toLowerCase() == 'maintenance').length;

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visão Geral - $moduleType',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[800],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Total de Ativos',
                  value: allAssets.length.toString(),
                  icon: getModuleIcon(),
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: StatCard(
                  title: 'Online',
                  value: onlineCount.toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: StatCard(
                  title: 'Offline',
                  value: offlineCount.toString(),
                  icon: Icons.cancel,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: StatCard(
                  title: 'Manutenção',
                  value: maintenanceCount.toString(),
                  icon: Icons.build,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GenericManagedAssetsCard(
              title: '($moduleType) Gerenciados (${allAssets.length})',
              columns: columns, 
              assets: allAssets,
              showActions: false, // Ações desabilitadas no dashboard
              authService: authService,
              moduleConfig: moduleConfig,
              
              // ✅ CORREÇÃO APLICADA AQUI
              onAssetChanged: onRefresh, // Passa a função de recarregar
            ),
          ),
        ],
      ),
    );
  }
}