// File: lib/modules/widgets/generic_managed_assets_card.dart (CORRIGIDO)
import 'package:flutter/material.dart';
import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/modules/asset_detail_screen.dart';
// ✅ 1. IMPORTAR O WIDGET DE CONTROLES
import 'package:painel_windowns/modules/widgets/asset_command_controls.dart';
import 'package:painel_windowns/services/auth_service.dart';

// ❌ 2. REMOVIDO O ENUM ANTIGO (AssetAction) que não é mais necessário aqui

class GenericManagedAssetsCard extends StatelessWidget {
  final String title;
  final List<ManagedAsset> assets;
  final List<TableColumnConfig> columns;
  final AssetModuleConfig moduleConfig;
  final bool showActions;
  final AuthService authService;
  
  // ✅ 3. CALLBACKS ANTIGOS REMOVIDOS E SUBSTITUÍDOS
  //    (onAssetUpdate, onAssetDelete, onMaintenanceUpdate removidos)
  //    Adicionamos um callback genérico para recarregar a lista
  final VoidCallback onAssetChanged;


  const GenericManagedAssetsCard({
    super.key,
    required this.title,
    required this.assets,
    required this.columns,
    required this.moduleConfig,
    required this.authService,
    required this.onAssetChanged, // ✅ Adicionado
    this.showActions = false,
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
                            ...columns
                                .map(
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
                                )
                                ,
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
                              .map((asset) => _buildAssetDataRow(context, asset))
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

  /// ✅ MÉTODO PRINCIPAL: Constrói uma linha da tabela
  DataRow _buildAssetDataRow(BuildContext context, ManagedAsset asset) {
    final assetData = asset.toJson();

    return DataRow(
      cells: [
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
        
        // ✅ 4. CÉLULA DE AÇÕES CORRIGIDA
        if (showActions) DataCell(_buildActionsMenu(context, asset)),
      ],
    );
  }

  /// ✅ NOVO: Célula específica para Setor/Andar (CORRIGIDO)
  Widget _buildSectorFloorCell(Map<String, dynamic> assetData) {
    String displayValue;

    // 1. Tenta usar sector_floor direto (vem do backend via transformAssetForOutput)
    if (assetData.containsKey('sector_floor') && 
        assetData['sector_floor'] != null &&
        assetData['sector_floor'].toString().isNotEmpty) {
      displayValue = assetData['sector_floor'].toString();
    }
    // 2. Fallback: Constrói manualmente a partir de sector e floor
    else {
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

  /// ✅ NOVO: Célula clicável para nome do ativo
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
          // Cor, sublinhado e fontWeight removidos
          // para usar o estilo padrão da célula.
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// ✅ NOVO: Célula padrão
  Widget _buildDefaultCell(dynamic value) {
    return Text(
      value?.toString() ?? 'N/D',
      style: const TextStyle(fontSize: 12),
      overflow: TextOverflow.ellipsis,
    );
  }

  /// ✅ 5. FUNÇÃO DE MENU CORRIGIDA
  /// Menu de ações do ativo (Agora usa o widget "inteligente")
  Widget _buildActionsMenu(BuildContext context, ManagedAsset asset) {
    return AssetCommandControls(
      asset: asset,
      moduleId: moduleConfig.id,
      authService: authService,
      onCommandExecuted: onAssetChanged, // Passa o callback de recarregar
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