// File: lib/modules/widgets/generic_managed_assets_card.dart
import 'dart:convert';
import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/modules/asset_detail_screen.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:path_provider/path_provider.dart';

enum AssetAction { edit, delete, markMaintenance, returnProduction }

class GenericManagedAssetsCard extends StatelessWidget {
  final String title;
  final List<ManagedAsset> assets;
  final List<TableColumnConfig> columns;
  final bool showActions;
  final Function(ManagedAsset)? onAssetUpdate;
  final Function(ManagedAsset)? onAssetDelete;
  final Function(ManagedAsset, bool)? onMaintenanceUpdate;
  
  // ✅ NOVO: Propriedades para navegação e exportação
  final AuthService authService;
  final AssetModuleConfig moduleConfig;

  const GenericManagedAssetsCard({
    super.key,
    required this.title,
    required this.assets,
    required this.columns,
    this.showActions = false,
    this.onAssetUpdate,
    this.onAssetDelete,
    this.onMaintenanceUpdate,
    required this.authService,
    required this.moduleConfig,
  });

  // ✅ CORRIGIDO: Função de download CSV completa com BSSID e Unit
  Future<void> _downloadAssetsCsv(
    BuildContext context,
    List<ManagedAsset> assetsToExport,
  ) async {
    // Headers completos com BSSID e Unit
    final headers = [
      'Nome do Ativo',
      'Tipo',
      'Serial',
      'Status',
      'Unidade',
      'Setor',
      'Andar',
      'Setor/Andar',
      'Localização Original',
      'IP',
      'MAC Address',
      'BSSID (Rádio WiFi)',
      'Última Sincronização',
      'Atribuído a',
    ];

    final rows = assetsToExport.map((asset) {
      final assetData = asset.toJson();
      
      return [
        assetData['asset_name'] ?? 'N/A',
        assetData['asset_type'] ?? 'N/A',
        assetData['serial_number'] ?? 'N/A',
        assetData['status'] ?? 'N/A',
        assetData['unit'] ?? 'N/D',
        assetData['sector'] ?? 'N/D',
        assetData['floor'] ?? 'N/D',
        assetData['sector_floor'] ?? 'N/D',
        assetData['location'] ?? 'N/D',
        assetData['ip_address'] ?? 'N/A',
        assetData['mac_address'] ?? 'N/A',
        assetData['mac_address_radio'] ?? 'N/A', // ✅ BSSID
        DateFormat('dd/MM/yyyy HH:mm:ss').format(asset.lastSeen),
        assetData['assigned_to'] ?? 'N/A',
      ]
          .map((value) => '"${value.toString().replaceAll('"', '""')}"')
          .join(',');
    }).toList();

    final csvContent = [headers.join(','), ...rows].join('\n');
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'ativos_${moduleConfig.name.replaceAll(' ', '_')}_$timestamp.csv';

    try {
      if (kIsWeb) {
        // No web: Gera bytes e força download via file_saver
        final bytes = Uint8List.fromList(utf8.encode(csvContent));
        await FileSaver.instance.saveFile(
          name: fileName,
          bytes: bytes,
          fileExtension: 'csv',
          mimeType: MimeType.csv,
        );
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('CSV baixado com sucesso!')),
        );
      } else {
        // Em mobile/desktop: Usa path_provider
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}${Platform.pathSeparator}$fileName';
        final file = File(path);
        await file.writeAsString(csvContent);

        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('CSV salvo em: $path')),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar CSV: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
              ElevatedButton.icon(
                onPressed: () => _downloadAssetsCsv(context, assets),
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

  // ✅ CORRIGIDO: Larguras de colunas inteligentes
  Map<int, TableColumnWidth> _getColumnWidths() {
    final widths = <int, TableColumnWidth>{};

    // Mapeamento inteligente de larguras por tipo de dado
    for (int i = 0; i < columns.length; i++) {
      final col = columns[i];
      double widthFactor;

      // Define largura baseado no tipo de conteúdo
      switch (col.dataKey) {
        // Colunas de identificação (mais largas)
        case 'asset_name':
        case 'hostname':
        case 'dispositivo':
          widthFactor = 2.5;
          break;
        
        // Localização combinada (larga)
        case 'sector_floor':
          widthFactor = 2.2;
          break;
        
        // Localização individual (média)
        case 'unit':
        case 'location':
          widthFactor = 1.8;
          break;
        
        // Serial, IMEI, MAC (média)
        case 'serial_number':
        case 'imei':
        case 'mac_address':
        case 'mac_address_radio':
          widthFactor = 1.5;
          break;
        
        // IP Address (média)
        case 'ip_address':
          widthFactor = 1.4;
          break;
        
        // Status (pequena, com chip)
        case 'status':
          widthFactor = 1.2;
          break;
        
        // Modelo, Fabricante (média)
        case 'model':
        case 'manufacturer':
          widthFactor = 1.6;
          break;
        
        // Especificações técnicas (pequena/média)
        case 'processor':
        case 'ram':
        case 'storage':
        case 'battery_level':
          widthFactor = 1.3;
          break;
        
        // Data/Hora (média)
        case 'last_seen':
        case 'last_sync':
          widthFactor = 1.6;
          break;
        
        // Padrão para outros campos
        default:
          widthFactor = 1.4;
      }

      widths[i] = FlexColumnWidth(widthFactor);
    }

    // Coluna de ações (se habilitada)
    if (showActions) {
      widths[columns.length] = FlexColumnWidth(1.2);
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

  // ✅ CORRIGIDO: Linha da tabela com navegação no hostname
  TableRow _buildAssetTableRow(BuildContext context, ManagedAsset asset) {
    final assetData = asset.toJson();

    return TableRow(
      children: [
        ...columns.map((col) {
          final dataKey = col.dataKey;
          final value = assetData[dataKey];

          // Status com chip colorido
          if (dataKey == 'status') {
            return Center(child: _buildStatusChip(value?.toString() ?? 'unknown'));
          }

          // Setor/Andar combinado
          if (dataKey == 'sector_floor') {
            final sectorFloor = assetData['sector_floor'] ??
                '${assetData['sector'] ?? "N/D"} / ${assetData['floor'] ?? "N/D"}';
            return _buildTableCell(sectorFloor);
          }

          // Unidade (destaque)
          if (dataKey == 'unit') {
            return _buildTableCell(
              value?.toString() ?? 'N/D',
              style: const TextStyle(fontWeight: FontWeight.w500),
            );
          }

          // ✅ NOVO: Hostname/Asset Name clicável
          if (dataKey == 'hostname' || dataKey == 'asset_name') {
            return _buildClickableCell(context, asset, value?.toString() ?? 'N/D');
          }

          // Células padrão
          return _buildTableCell(value?.toString() ?? 'N/D');
        }),
        if (showActions) _buildActionsMenu(context, asset),
      ],
    );
  }

  // ✅ NOVO: Célula clicável que navega para detalhes
  Widget _buildClickableCell(BuildContext context, ManagedAsset asset, String text) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: InkWell(
        onTap: () {
          // Navega para a tela de detalhes
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.open_in_new, size: 14, color: Colors.blue.shade300),
            ],
          ),
        ),
      ),
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
          overflow: TextOverflow.ellipsis,
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