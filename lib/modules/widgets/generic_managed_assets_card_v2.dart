// File: lib/modules/widgets/generic_managed_assets_card_v2.dart
// VERSÃO MIGRADA USANDO BaseDataTable

import 'package:flutter/material.dart';
import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/modules/asset_detail_screen.dart';
import 'package:painel_windowns/widgets/common/index.dart';
import 'package:painel_windowns/utils/app_constants.dart';

class GenericManagedAssetsCardV2 extends StatelessWidget {
  final List<ManagedAsset> assets;
  final String assetType;
  final VoidCallback? onRefresh;

  const GenericManagedAssetsCardV2({
    super.key,
    required this.assets,
    required this.assetType,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      title: 'Ativos Gerenciados - $assetType',
      actions: [
        if (onRefresh != null)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRefresh,
            tooltip: 'Atualizar',
          ),
      ],
      child: BaseDataTable<ManagedAsset>(
        items: assets,
        columns: _buildColumns(),
        actions: [
          TableAction<ManagedAsset>(
            icon: Icons.visibility,
            label: 'Ver Detalhes',
            onTap: (asset) => _navigateToDetails(context, asset),
          ),
          TableAction<ManagedAsset>(
            icon: Icons.build,
            label: 'Manutenção',
            onTap: (asset) => {}, // Implementar
            isVisible: (asset) => asset.status != 'maintenance',
          ),
          TableAction<ManagedAsset>(
            icon: Icons.check_circle,
            label: 'Retornar à Produção',
            onTap: (asset) => {}, // Implementar
            isVisible: (asset) => asset.status == 'maintenance',
            color: AppColors.success,
          ),
          TableAction<ManagedAsset>(
            icon: Icons.delete,
            label: 'Deletar',
            onTap: (asset) => {}, // Implementar
            color: AppColors.danger,
          ),
        ],
        showPagination: true,
        pageSize: 10,
      ),
    );
  }

  List<DataTableColumn<ManagedAsset>> _buildColumns() {
    return [
      DataTableColumn<ManagedAsset>(
        label: 'Nome',
        builder: (asset) => TableCell(
          value: asset.assetData['name'] ?? 'Sem nome',
          isClickable: true,
          onTap: () => {}, // Implementar navegação
        ),
      ),
      DataTableColumn<ManagedAsset>(
        label: 'Status',
        builder: (asset) => StatusChip(
          status: asset.status,
          type: StatusType.asset,
          isCompact: true,
        ),
      ),
      DataTableColumn<ManagedAsset>(
        label: 'Setor/Andar',
        value: (asset) {
          final sector = asset.assetData['sector'] ?? '-';
          final floor = asset.assetData['floor'] ?? '-';
          return '$sector / $floor';
        },
      ),
      DataTableColumn<ManagedAsset>(
        label: 'Serial',
        value: (asset) => asset.assetData['serialNumber'] ?? '-',
      ),
      DataTableColumn<ManagedAsset>(
        label: 'Patrimônio',
        value: (asset) => asset.assetData['patrimonyNumber'] ?? '-',
      ),
      DataTableColumn<ManagedAsset>(
        label: 'Última Atualização',
        value: (asset) {
          final lastUpdate = asset.assetData['lastUpdate'];
          if (lastUpdate == null) return '-';
          
          try {
            final date = DateTime.parse(lastUpdate.toString());
            final diff = DateTime.now().difference(date);
            if (diff.inMinutes < 60) return '${diff.inMinutes}m atrás';
            if (diff.inHours < 24) return '${diff.inHours}h atrás';
            return '${diff.inDays}d atrás';
          } catch (e) {
            return lastUpdate.toString();
          }
        },
      ),
    ];
  }

  void _navigateToDetails(BuildContext context, ManagedAsset asset) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssetDetailScreen(
          assetId: asset.id,
          assetType: assetType,
        ),
      ),
    );
  }
}
