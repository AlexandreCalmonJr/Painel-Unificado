// File: lib/modules/widgets/generic_managed_assets_card.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/modules/asset_detail_screen.dart';
import 'package:painel_windowns/services/auth_service.dart';

enum AssetAction { edit, delete, markMaintenance, returnProduction }

class GenericManagedAssetsCard extends StatelessWidget {
  final String title;
  final List<ManagedAsset> assets;
  final List<TableColumnConfig> columns;
  final AssetModuleConfig moduleConfig;
  final bool showActions;
  final Function(ManagedAsset)? onAssetUpdate;
  final Function(ManagedAsset)? onAssetDelete;
  final Function(ManagedAsset, bool)? onMaintenanceUpdate;

  const GenericManagedAssetsCard({
    super.key,
    required this.title,
    required this.assets,
    required this.columns,
    required this.moduleConfig,
    this.showActions = false,
    this.onAssetUpdate,
    this.onAssetDelete,
    this.onMaintenanceUpdate, required AuthService authService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              if (showActions)
                ElevatedButton.icon(
                  onPressed: () {

                    
                    
                  },
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Baixar CSV'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: 24),

          if (assets.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Text(
                    'Nenhum ativo encontrado.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 12,
                    horizontalMargin: 12,
                    headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                    border: TableBorder(
                      horizontalInside: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    columns: [
                      ...columns.map((col) => DataColumn(
                        label: Expanded(
                          child: Text(
                            col.label,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )),
                      if (showActions) 
                        DataColumn(
                          label: Text(
                            'Ações',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                    rows: assets.map((asset) => _buildAssetDataRow(context, asset)).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  DataRow _buildAssetDataRow(BuildContext context, ManagedAsset asset) {
    final assetData = asset.toJson();

    return DataRow(
      cells: [
        ...columns.map((col) {
          final dataKey = col.dataKey;
          final value = assetData[dataKey];

          // Célula clicável para hostname/asset_name
          if (dataKey == 'hostname' || dataKey == 'asset_name') {
            return DataCell(
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AssetDetailScreen(
                        asset: asset,
                        authService: AuthService(), // Passe o authService do contexto
                        moduleConfig: moduleConfig,
                      ),
                    ),
                  );
                },
                child: Text(
                  value?.toString() ?? 'N/D',
                  style: const TextStyle(
                    fontSize: 12, // <-- Alterado para 12
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }

          // Célula de status com chip
          if (dataKey == 'status') {
            return DataCell(
              Center(child: _buildStatusChip(value?.toString() ?? 'unknown')),
            );
          }

          // Célula combinada setor/andar
          if (dataKey == 'sector_floor') {
            final sectorFloor = assetData['sector_floor'] ??
                '${assetData['sector'] ?? "N/D"} / ${assetData['floor'] ?? "N/D"}';
            return DataCell(Text(sectorFloor));
          }

          // Células padrão
          return DataCell(Text(value?.toString() ?? 'N/D'));
        }),
        if (showActions) DataCell(_buildActionsMenu(context, asset)),
      ],
    );
  }

  Widget _buildActionsMenu(BuildContext context, ManagedAsset asset) {
    bool isInMaintenance = asset.status.toLowerCase() == 'maintenance';

    return PopupMenuButton<AssetAction>(
      onSelected: (action) {
        if (action == AssetAction.edit) {
          onAssetUpdate?.call(asset);
        } else if (action == AssetAction.delete) {
          onAssetDelete?.call(asset);
        } else if (action == AssetAction.markMaintenance) {
          onMaintenanceUpdate?.call(asset, true);
        } else if (action == AssetAction.returnProduction) {
          onMaintenanceUpdate?.call(asset, false);
        }
      },
      itemBuilder: (context) => [
        if (isInMaintenance)
          const PopupMenuItem(
            value: AssetAction.returnProduction,
            child: ListTile(
              leading: Icon(Icons.check_circle_outline, color: Colors.green),
              title: Text('Retornar à Produção'),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          )
        else
          const PopupMenuItem(
            value: AssetAction.markMaintenance,
            child: ListTile(
              leading: Icon(Icons.build_outlined, color: Colors.orange),
              title: Text('Marcar Manutenção'),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: AssetAction.edit,
          child: ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text('Editar'),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        const PopupMenuItem(
          value: AssetAction.delete,
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: Colors.red),
            title: Text('Excluir', style: TextStyle(color: Colors.red)),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    String statusText;
    Color statusColor;

    switch (status.toLowerCase()) {
      case 'online':
        statusText = 'Online';
        statusColor = Colors.green;
        break;
      case 'maintenance':
        statusText = 'Manutenção';
        statusColor = Colors.orange;
        break;
      case 'offline':
        statusText = 'Offline';
        statusColor = Colors.red;
        break;
      case 'sem monitorar':
        statusText = 'Sem Monitorar';
        statusColor = Colors.grey;
        break;
      default:
        statusText = status;
        statusColor = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}