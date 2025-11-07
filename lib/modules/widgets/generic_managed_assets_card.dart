// File: lib/modules/widgets/generic_managed_assets_card.dart (CORRIGIDO E ATUALIZADO)
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
  final AuthService authService;
  final Function(ManagedAsset)? onAssetUpdate;
  final Function(ManagedAsset)? onAssetDelete;
  final Function(ManagedAsset, bool)? onMaintenanceUpdate;

  // ✅ CAMPOS ADICIONADOS PARA SELEÇÃO
  final List<ManagedAsset> selectedAssets;
  final Function(List<ManagedAsset>)? onSelectionChanged;

  const GenericManagedAssetsCard({
    super.key,
    required this.title,
    required this.assets,
    required this.columns,
    required this.moduleConfig,
    required this.authService,
    this.showActions = false,
    this.onAssetUpdate,
    this.onAssetDelete,
    this.onMaintenanceUpdate,
    // ✅ CAMPOS ADICIONADOS PARA SELEÇÃO
    required this.selectedAssets,
    required this.onSelectionChanged,
  });

  // ✅ LÓGICA DE SELEÇÃO
  void _handleSelection(ManagedAsset asset, bool? isSelected) {
    if (onSelectionChanged == null) return;

    List<ManagedAsset> newSelection = List.from(selectedAssets);
    if (isSelected == true) {
      if (!newSelection.any((a) => a.id == asset.id)) {
        newSelection.add(asset);
      }
    } else {
      newSelection.removeWhere((a) => a.id == asset.id);
    }
    onSelectionChanged!(newSelection);
  }

  void _handleSelectAll(bool? isSelected) {
    if (onSelectionChanged == null) return;

    List<ManagedAsset> newSelection = [];
    if (isSelected == true) {
      newSelection = List.from(assets);
    }
    onSelectionChanged!(newSelection);
  }

  @override
  Widget build(BuildContext context) {
    // Verifica se a seleção múltipla está ativa
    final bool isSelectionEnabled = onSelectionChanged != null;
    final bool isAllSelected =
        isSelectionEnabled && selectedAssets.length == assets.length && assets.isNotEmpty;

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
                    // Implementar lógica de download CSV
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum ativo encontrado.',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: SingleChildScrollView(
                        child: DataTable(
                          columnSpacing: 12,
                          horizontalMargin: 12,
                          headingRowColor: WidgetStateProperty.all(
                            Colors.grey.shade50,
                          ),
                          border: TableBorder(
                            horizontalInside: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          columns: [
                            // ✅ COLUNA DE CHECKBOX CONDICIONAL
                            if (isSelectionEnabled)
                              DataColumn(
                                label: Checkbox(
                                  value: isAllSelected,
                                  onChanged: _handleSelectAll,
                                ),
                              ),
                            ...columns.map(
                              (col) => DataColumn(
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
                              ),
                            ),
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
                          rows: assets
                              .map((asset) =>
                                  _buildAssetDataRow(context, asset, isSelectionEnabled))
                              .toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  /// ✅ MÉTODO PRINCIPAL ATUALIZADO: Constrói uma linha da tabela
  DataRow _buildAssetDataRow(BuildContext context, ManagedAsset asset, bool isSelectionEnabled) {
    final assetData = asset.toJson();
    final bool isSelected =
        isSelectionEnabled && selectedAssets.any((a) => a.id == asset.id);

    return DataRow(
      // ✅ SELEÇÃO DA LINHA
      selected: isSelected,
      onSelectChanged: (selected) {
         if (isSelectionEnabled) {
           _handleSelection(asset, selected);
         }
      },
      cells: [
        // ✅ CÉLULA DE CHECKBOX CONDICIONAL
        if (isSelectionEnabled)
          DataCell(
            Checkbox(
              value: isSelected,
              onChanged: (value) => _handleSelection(asset, value),
            ),
          ),
        ...columns.map((col) {
          final dataKey = col.dataKey;

          // ✅ TRATAMENTO ESPECIAL PARA SECTOR_FLOOR
          if (dataKey == 'sector_floor') {
            return DataCell(_buildSectorFloorCell(assetData));
          }

          // Pega o valor do campo
          final value = assetData[dataKey];

          // Célula clicável para hostname/asset_name
          if (dataKey == 'hostname' || dataKey == 'asset_name') {
            return DataCell(_buildClickableNameCell(context, asset, value));
          }

          // Célula de status com chip
          if (dataKey == 'status') {
            return DataCell(
              Center(child: _buildStatusChip(value?.toString() ?? 'unknown')),
            );
          }

          // Células padrão
          return DataCell(_buildDefaultCell(value));
        }),
        if (showActions) DataCell(_buildActionsMenu(context, asset)),
      ],
    );
  }

  /// Célula específica para Setor/Andar
  Widget _buildSectorFloorCell(Map<String, dynamic> assetData) {
    String displayValue;

    if (assetData.containsKey('sector_floor') &&
        assetData['sector_floor'] != null &&
        assetData['sector_floor'].toString().isNotEmpty) {
      displayValue = assetData['sector_floor'].toString();
    } else {
      final sector = assetData['sector']?.toString() ?? 'N/D';
      final floor = assetData['floor']?.toString() ?? 'N/D';
      displayValue = '$sector / $floor';
    }

    return Text(
      displayValue,
      style: const TextStyle(fontSize: 12),
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Célula clicável para nome do ativo
  Widget _buildClickableNameCell(
    BuildContext context,
    ManagedAsset asset,
    dynamic value,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssetDetailScreen(
              asset: asset,
              authService: authService,
              moduleConfig: moduleConfig,
            ),
          ),
        );
      },
      child: Text(
        value?.toString() ?? 'N/D',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.blue, // ✅ Adicionado cor para indicar clique
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Célula padrão
  Widget _buildDefaultCell(dynamic value) {
    return Text(
      value?.toString() ?? 'N/D',
      style: const TextStyle(fontSize: 12),
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Menu de ações do ativo
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
              leading: Icon(
                Icons.check_circle_outline,
                color: Colors.green,
              ),
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

  /// Chip de status do ativo
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
      // ✅ CÓDIGO FALTANTE ADICIONADO AQUI
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}