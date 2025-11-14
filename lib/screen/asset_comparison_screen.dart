// File: lib/screens/asset_comparison_screen.dart

// ✅ IMPORTS ADICIONADOS
import 'dart:convert'; // Para utf8
import 'dart:io'; // Para File

import 'package:file_saver/file_saver.dart'; // Para FileSaver
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:flutter/material.dart';
import 'package:painel_windowns/models/asset_module_base.dart'; // Import presumido
import 'package:path_provider/path_provider.dart'; // Para getApplicationDocumentsDirectory

class AssetComparisonScreen extends StatefulWidget {
  final List<ManagedAsset> selectedAssets;
  final AssetModuleConfig moduleConfig;

  const AssetComparisonScreen({
    super.key, // ✅ Adicionado Key ao construtor
    required this.selectedAssets,
    required this.moduleConfig,
  });

  @override
  State<AssetComparisonScreen> createState() => _AssetComparisonScreenState();
}

class _AssetComparisonScreenState extends State<AssetComparisonScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comparar ${widget.selectedAssets.length} Ativos'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            columns: [
              const DataColumn(
                  label: Text('Campo',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              ...widget.selectedAssets.map(
                (asset) => DataColumn(
                  label: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(asset.assetName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(asset.serialNumber,
                          style:
                              const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ],
            rows: _buildComparisonRows(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _exportComparison,
        icon: const Icon(Icons.download),
        label: const Text('Exportar'),
      ),
    );
  }

  List<DataRow> _buildComparisonRows() {
    final rows = <DataRow>[];

    for (final column in widget.moduleConfig.tableColumns) {
      final cells = <DataCell>[
        DataCell(
            Text(column.label, style: const TextStyle(fontWeight: FontWeight.w600))),
      ];

      for (final asset in widget.selectedAssets) {
        final value = asset.toJson()[column.dataKey];
        final cellValue = value?.toString() ?? 'N/D';

        // Destaca diferenças
        final isDifferent = _isDifferentFromFirst(column.dataKey, cellValue);

        cells.add(DataCell(
          Container(
            padding: const EdgeInsets.all(8),
            decoration: isDifferent
                ? BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  )
                : null,
            child: Text(cellValue),
          ),
        ));
      }

      rows.add(DataRow(cells: cells));
    }

    return rows;
  }

  bool _isDifferentFromFirst(String key, String value) {
    if (widget.selectedAssets.length < 2) return false;

    final firstValue =
        widget.selectedAssets[0].toJson()[key]?.toString() ?? 'N/D';
    return value != firstValue;
  }

  Future<void> _exportComparison() async {
    // Garante que o contexto está válido (evita erros)
    if (!mounted) return;

    try {
      final csv = _generateComparisonCsv();

      if (kIsWeb) {
        await FileSaver.instance.saveFile(
          name: 'comparacao_ativos_${DateTime.now().millisecondsSinceEpoch}',
          bytes: Uint8List.fromList(utf8.encode(csv)),
          mimeType: MimeType.csv,
        );
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File(
            '${directory.path}/comparacao_${DateTime.now().millisecondsSinceEpoch}.csv');
        await file.writeAsString(csv);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comparação exportada com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao exportar: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  String _generateComparisonCsv() {
    final buffer = StringBuffer();

    // Header
    buffer.write('Campo,');
    buffer.writeln(widget.selectedAssets.map((a) => '"${a.assetName}"').join(','));

    // Rows
    for (final column in widget.moduleConfig.tableColumns) {
      buffer.write('"${column.label}",');
      final values = widget.selectedAssets.map((asset) {
        final value = asset.toJson()[column.dataKey]?.toString() ?? 'N/D';
        // Escapa aspas duplas dentro do valor
        return '"${value.replaceAll('"', '""')}"';
      }).join(',');
      buffer.writeln(values);
    }

    return buffer.toString();
  }
}