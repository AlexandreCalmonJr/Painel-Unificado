// File: lib/modules/widgets/generic_managed_assets_card.dart (COM CSV EXPORT)
import 'dart:convert';
import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/modules/asset_detail_screen.dart';
import 'package:painel_windowns/modules/widgets/asset_command_controls.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:path_provider/path_provider.dart';

class GenericManagedAssetsCard extends StatelessWidget {
  final String title;
  final List<ManagedAsset> assets;
  final List<TableColumnConfig> columns;
  final AssetModuleConfig moduleConfig;
  final bool showActions;
  final AuthService authService;
  final VoidCallback onAssetChanged;
  final Function(ManagedAsset)? onAssetUpdate;

  const GenericManagedAssetsCard({
    super.key,
    required this.title,
    required this.assets,
    required this.columns,
    required this.moduleConfig,
    required this.authService,
    required this.onAssetChanged,
    this.showActions = false,
    this.onAssetUpdate,
  });

  // ✅ FUNÇÃO DE DOWNLOAD CSV
  Future<void> _downloadAssetsCsv(
    BuildContext context,
    List<ManagedAsset> assetsToExport,
  ) async {
    // Gera headers baseado nas colunas configuradas
    final headers = columns.map((col) => col.label).toList();

    final rows =
        assetsToExport.map((asset) {
          final assetData = asset.toJson();

          return columns
              .map((col) {
                final dataKey = col.dataKey;
                dynamic value;

                // Tratamentos especiais para campos específicos
                if (dataKey == 'sector_floor') {
                  final sector = assetData['sector']?.toString() ?? 'N/D';
                  final floor = assetData['floor']?.toString() ?? 'N/D';
                  value = '$sector / $floor';
                } else if (dataKey == 'status') {
                  value = _formatStatus(
                    assetData[dataKey]?.toString() ?? 'unknown',
                  );
                } else if (dataKey == 'updated_at' ||
                    dataKey == 'last_sync_time') {
                  value = _formatDateForCsv(assetData[dataKey]);
                } else if (dataKey == 'battery_level') {
                  final batteryValue = assetData[dataKey];
                  value = batteryValue != null ? '$batteryValue%' : 'N/D';
                } else if (dataKey == 'toner_levels') {
                  // Para impressoras - formata níveis de toner
                  final tonerData = assetData[dataKey];
                  if (tonerData is Map) {
                    value = tonerData.entries
                        .map((e) => '${e.key}:${e.value}%')
                        .join(', ');
                  } else {
                    value = 'N/D';
                  }
                } else if (dataKey == 'antivirus_status') {
                  value = assetData[dataKey] == true ? 'Ativo' : 'Inativo';
                } else if (dataKey == 'uptime') {
                  value = assetData[dataKey] ?? 'N/D';
                } else {
                  value = assetData[dataKey] ?? 'N/D';
                }

                // Escapa aspas duplas e envolve em aspas
                return '"${value.toString().replaceAll('"', '""')}"';
              })
              .join(',');
        }).toList();

    final csvContent = [headers.join(','), ...rows].join('\n');
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName =
        '${moduleConfig.name.toLowerCase().replaceAll(' ', '_')}_$timestamp.csv';

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

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return 'Online';
      case 'maintenance':
        return 'Manutenção';
      case 'offline':
        return 'Offline';
      default:
        return status;
    }
  }

  String _formatDateForCsv(dynamic value) {
    try {
      if (value != null && value.toString().isNotEmpty) {
        final dateTime = DateTime.parse(value.toString()).toLocal();
        return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return value?.toString() ?? 'N/D';
    }
    return 'N/D';
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
              // ✅ BOTÃO DE DOWNLOAD CSV (sempre visível)
              ElevatedButton.icon(
                onPressed:
                    assets.isEmpty
                        ? null
                        : () => _downloadAssetsCsv(context, assets),
                icon: const Icon(Icons.download, size: 16),
                label: const Text('Baixar CSV'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
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
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
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
                          rows:
                              assets
                                  .map(
                                    (asset) =>
                                        _buildAssetDataRow(context, asset),
                                  )
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

  DataRow _buildAssetDataRow(BuildContext context, ManagedAsset asset) {
    final assetData = asset.toJson();

    return DataRow(
      cells: [
        ...columns.map((col) {
          final dataKey = col.dataKey;

          if (dataKey == 'sector_floor') {
            return DataCell(_buildSectorFloorCell(assetData));
          }

          final value = assetData[dataKey];

          if (dataKey == 'hostname' || dataKey == 'asset_name') {
            return DataCell(_buildClickableNameCell(context, asset, value));
          }

          if (dataKey == 'status') {
            return DataCell(
              Center(child: _buildStatusChip(value?.toString() ?? 'unknown')),
            );
          }

          if (dataKey == 'updated_at' || dataKey == 'last_sync_time') {
            return DataCell(_buildDateCell(value));
          }

          if (dataKey == 'battery_level') {
            return DataCell(_buildBatteryCell(value));
          }

          if (dataKey == 'antivirus_status') {
            return DataCell(_buildBooleanCell(value));
          }

          return DataCell(_buildDefaultCell(value));
        }),

        if (showActions) DataCell(_buildActionsMenu(context, asset)),
      ],
    );
  }

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
            builder:
                (context) => AssetDetailScreen(
                  asset: asset,
                  authService: authService,
                  moduleConfig: moduleConfig,
                ),
          ),
        );
      },
      child: Text(
        value?.toString() ?? 'N/D',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDefaultCell(dynamic value) {
    return Text(
      value?.toString() ?? 'N/D',
      style: const TextStyle(fontSize: 12),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDateCell(dynamic value) {
    try {
      if (value != null && value.toString().isNotEmpty) {
        final dateTime = DateTime.parse(value.toString()).toLocal();
        return Text(
          formatDateTime(dateTime),
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        );
      }
    } catch (e) {
      return _buildDefaultCell(value);
    }
    return _buildDefaultCell('N/D');
  }

  Widget _buildBatteryCell(dynamic value) {
    if (value == null) {
      return Text('N/D', style: TextStyle(fontSize: 12, color: Colors.grey));
    }

    final level = value is int ? value : int.tryParse(value.toString()) ?? 0;
    Color color;
    IconData icon;

    if (level <= 20) {
      color = Colors.red;
      icon = Icons.battery_alert;
    } else if (level <= 50) {
      color = Colors.orange;
      icon = Icons.battery_std;
    } else {
      color = Colors.green;
      icon = Icons.battery_full;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        SizedBox(width: 4),
        Text('$level%', style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }

  Widget _buildBooleanCell(dynamic value) {
    final isActive = value == true || value.toString().toLowerCase() == 'true';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isActive ? Icons.check_circle : Icons.cancel,
          size: 16,
          color: isActive ? Colors.green : Colors.red,
        ),
        SizedBox(width: 4),
        Text(
          isActive ? 'Ativo' : 'Inativo',
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildActionsMenu(BuildContext context, ManagedAsset asset) {
    return AssetCommandControls(
      asset: asset,
      moduleId: moduleConfig.id,
      authService: authService,
      onCommandExecuted: onAssetChanged,
      onEditPressed: () => onAssetUpdate?.call(asset),
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

  String formatDateTime(DateTime? dt) {
    if (dt == null) return "N/A";
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.inMinutes < 1) return 'Agora mesmo';
    if (difference.inHours < 1) return 'Há ${difference.inMinutes} minuto(s)';
    if (difference.inDays < 1) return 'Há ${difference.inHours} hora(s)';
    if (difference.inDays < 7) return 'Há ${difference.inDays} dia(s)';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
