// File: lib/services/report_generator.dart
import 'dart:typed_data'; // Necessário para Uint8List

import 'package:excel/excel.dart'; // Necessário para Excel
import 'package:painel_windowns/models/asset_module_base.dart'; // Import presumido
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // Necessário para PDF

class ReportGenerator {
  /// Gera relatório PDF com gráficos
  Future<Uint8List> generatePdfReport({
    required List<ManagedAsset> assets,
    required AssetModuleConfig module,
  }) async {
    final pdf = pw.Document();

    // Página 1: Sumário Executivo
    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text('Relatório de Ativos - ${module.name}'),
            ),
            pw.SizedBox(height: 20),
            _buildSummaryTable(assets),
            pw.SizedBox(height: 20),
            // ✅ MÉTODO ADICIONADO (PLACEHOLDER)
            _buildStatusChart(assets),
          ],
        ),
      ),
    );

    // Página 2: Lista Detalhada
    pdf.addPage(
      pw.Page(
        // ✅ MÉTODO ADICIONADO
        build: (context) => _buildDetailedTable(assets, module),
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildSummaryTable(List<ManagedAsset> assets) {
    if (assets.isEmpty) return pw.Text('Nenhum ativo para exibir.');

    final total = assets.length;
    final online = assets.where((a) => a.status == 'online').length;
    final offline = assets.where((a) => a.status == 'offline').length;
    final maintenance = assets.where((a) => a.status == 'maintenance').length;

    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(children: [
          pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: pw.Text('Total de Ativos',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('$total')),
        ]),
        pw.TableRow(children: [
          pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Online')),
          pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: pw.Text(
                  '$online (${(online / total * 100).toStringAsFixed(1)}%)')),
        ]),
        pw.TableRow(children: [
          pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Offline')),
          pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: pw.Text(
                  '$offline (${(offline / total * 100).toStringAsFixed(1)}%)')),
        ]),
        pw.TableRow(children: [
          pw.Padding(
              padding: pw.EdgeInsets.all(8), child: pw.Text('Em Manutenção')),
          pw.Padding(
              padding: pw.EdgeInsets.all(8),
              child: pw.Text(
                  '$maintenance (${(maintenance / total * 100).toStringAsFixed(1)}%)')),
        ]),
      ],
    );
  }

  // ===================================================================
  // ✅ MÉTODOS QUE FALTAVAM (FORAM ADICIONADOS)
  // ===================================================================

  /// Constrói a tabela detalhada para o PDF
  pw.Widget _buildDetailedTable(
      List<ManagedAsset> assets, AssetModuleConfig module) {
    final headers = module.tableColumns.map((c) => c.label).toList();

    final data = assets.map((asset) {
      return module.tableColumns.map((col) {
        final value = asset.toJson()[col.dataKey];
        return value?.toString() ?? 'N/D';
      }).toList();
    }).toList();

    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Header(level: 1, text: 'Lista Detalhada de Ativos'),
          pw.Table.fromTextArray(
            headers: headers,
            data: data,
            border: pw.TableBorder.all(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.centerLeft,
            headerAlignment: pw.Alignment.centerLeft,
          ),
        ]);
  }

  /// Constrói um placeholder para o gráfico de status no PDF
  pw.Widget _buildStatusChart(List<ManagedAsset> assets) {
    // Gerar gráficos em PDF é complexo e requer a biblioteca pdf/charts
    // ou uma imagem estática de um gráfico.
    // Este é um placeholder.
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        color: PdfColors.grey100,
      ),
      child: pw.Text(
        'Placeholder para Gráfico de Status (Online, Offline, Manutenção)',
        style: pw.TextStyle(color: PdfColors.grey600),
      ),
    );
  }

  // ===================================================================
  // FIM DOS MÉTODOS ADICIONADOS
  // ===================================================================

  /// Gera relatório Excel com múltiplas abas
  Future<List<int>?> generateExcelReport({
    required List<ManagedAsset> assets,
    required AssetModuleConfig module,
  }) async {
    final excel = Excel.createExcel();

    // Aba 1: Resumo
    final summarySheet = excel['Resumo'];
    summarySheet.appendRow(['Métrica', 'Valor']);
    summarySheet.appendRow(['Total de Ativos', assets.length]);
    summarySheet
        .appendRow(['Online', assets.where((a) => a.status == 'online').length]);
    summarySheet.appendRow(
        ['Offline', assets.where((a) => a.status == 'offline').length]);

    // Aba 2: Detalhes
    final detailsSheet = excel['Detalhes'];
    detailsSheet
        .appendRow(module.tableColumns.map((c) => c.label).toList());

    for (final asset in assets) {
      final row = module.tableColumns.map((col) {
        final value = asset.toJson()[col.dataKey];
        return value?.toString() ?? 'N/D';
      }).toList();
      detailsSheet.appendRow(row);
    }

    // Aba 3: Por Localização
    final locationSheet = excel['Por Localização'];
    final groupedByUnit = _groupByLocation(assets);
    locationSheet.appendRow(['Unidade', 'Setor', 'Andar', 'Total']);

    groupedByUnit.forEach((key, list) {
      final parts = key.split('|');
      locationSheet.appendRow([parts[0], parts[1], parts[2], list.length]);
    });

    return excel.encode();
  }

  Map<String, List<ManagedAsset>> _groupByLocation(List<ManagedAsset> assets) {
    final Map<String, List<ManagedAsset>> grouped = {};

    for (final asset in assets) {
      final key = '${asset.unit}|${asset.sector}|${asset.floor}';
      grouped.putIfAbsent(key, () => []).add(asset);
    }

    return grouped;
  }
}