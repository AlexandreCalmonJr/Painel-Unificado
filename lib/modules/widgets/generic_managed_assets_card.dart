// File: lib/widgets/generic_managed_assets_card.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/models/asset_module_base.dart';

enum AssetAction { edit, delete, markMaintenance, returnProduction }

class GenericManagedAssetsCard extends StatelessWidget {
  final String title;
  final List<ManagedAsset> assets;
  final List<TableColumnConfig> columns;
  final bool showActions;
  final Function(ManagedAsset)? onAssetUpdate;
  final Function(ManagedAsset)? onAssetDelete;
  final Function(ManagedAsset, bool)? onMaintenanceUpdate;

  const GenericManagedAssetsCard({
    super.key,
    required this.title,
    required this.assets,
    required this.columns,
    this.showActions = false,
    this.onAssetUpdate,
    this.onAssetDelete,
    this.onMaintenanceUpdate,
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
                    // TODO: Lógica para baixar CSV
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
                child: Table(
                  border: const TableBorder(
                    horizontalInside: BorderSide(
                      color: Colors.black12,
                      width: 0.5,
                    ),
                  ),
                  columnWidths: _getColumnWidths(),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey.shade50),
                      children: [
                        ...columns.map((col) => _buildTableHeader(col.label)),
                        if (showActions) _buildTableHeader('Ações'),
                      ],
                    ),
                    ...assets.map((asset) => _buildAssetTableRow(context, asset)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Map<int, TableColumnWidth> _getColumnWidths() {
    final baseWidth = 1.5; // Default width for each column
    final numColumns = columns.length + (showActions ? 1 : 0);
    final widths = <int, TableColumnWidth>{};

    // Assign proportional widths dynamically
    for (int i = 0; i < columns.length; i++) {
      final col = columns[i];
      double widthFactor = baseWidth;

      // Adjust width based on column key (if needed)
      if (col.dataKey == 'status') {
        widthFactor = 1.5; // Wider for status chips
      } else if (col.dataKey == 'sector_floor') {
        widthFactor = 1.8; // Wider for combined sector/floor
      } else if (col.dataKey == 'unit') {
        widthFactor = 1.5; // Moderate width for unit
      } else if (col.dataKey == 'dispositivo' || col.dataKey == 'hostname') {
        widthFactor = 2.5; // Wider for device/hostname
      } else {
        widthFactor = 1.2; // Default for narrower fields like serial, IMEI
      }

      widths[i] = FlexColumnWidth(widthFactor);
    }

    // Add width for actions column if enabled
    if (showActions) {
      widths[columns.length] = FlexColumnWidth(1.5); // Moderate width for actions
    }

    return widths;
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
    );
  }

  TableRow _buildAssetTableRow(BuildContext context, ManagedAsset asset) {
    final assetData = asset.toJson();

    return TableRow(
      children: [
        ...columns.map((col) {
          final dataKey = col.dataKey;
          final value = assetData[dataKey];

          if (dataKey == 'status') {
            return Center(child: _buildStatusChip(value?.toString() ?? 'unknown'));
          }

          if (dataKey == 'sector_floor') {
            final sectorFloor = assetData['sector_floor'] ??
                '${assetData['sector'] ?? "N/D"} / ${assetData['floor'] ?? "N/D"}';
            return _buildTableCell(sectorFloor);
          }

          if (dataKey == 'unit') {
            return _buildTableCell(
              value?.toString() ?? 'N/D',
              style: const TextStyle(fontWeight: FontWeight.w500),
            );
          }

          return _buildTableCell(value?.toString() ?? 'N/D');
        }),
        if (showActions) _buildActionsMenu(context, asset),
      ],
    );
  }

  Widget _buildTableCell(String text, {TextStyle? style}) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Text(
          text,
          style: style ?? const TextStyle(fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildActionsMenu(BuildContext context, ManagedAsset asset) {
    bool isInMaintenance = asset.status.toLowerCase() == 'maintenance';

    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: PopupMenuButton<AssetAction>(
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
              ),
            )
          else
            const PopupMenuItem(
              value: AssetAction.markMaintenance,
              child: ListTile(
                leading: Icon(Icons.build_outlined, color: Colors.orange),
                title: Text('Marcar Manutenção'),
              ),
            ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: AssetAction.edit,
            child: ListTile(
              leading: Icon(Icons.edit_outlined),
              title: Text('Editar'),
            ),
          ),
          const PopupMenuItem(
            value: AssetAction.delete,
            child: ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red),
              title: Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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