// File: lib/services/report_generator.dart

import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:painel_windowns/data/models/asset_module_base_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Serviço responsável por gerar relatórios em PDF e Excel
/// para os ativos gerenciados no sistema
class ReportGenerator {
  /// Gera relatório em formato PDF com sumário executivo e lista detalhada
  ///
  /// [assets] - Lista de ativos a serem incluídos no relatório
  /// [module] - Configuração do módulo com informações de colunas
  ///
  /// Retorna um [Uint8List] contendo os bytes do PDF gerado
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
            _buildStatusChart(assets),
          ],
        ),
      ),
    );

    // Página 2: Lista Detalhada
    pdf.addPage(
      pw.Page(
        build: (context) => _buildDetailedTable(assets, module),
      ),
    );

    return pdf.save();
  }

  /// Constrói tabela resumida com estatísticas dos ativos
  pw.Widget _buildSummaryTable(List<ManagedAsset> assets) {
    if (assets.isEmpty) {
      return pw.Text('Nenhum ativo para exibir.');
    }

    final total = assets.length;
    final online = assets.where((a) => a.status == 'online').length;
    final offline = assets.where((a) => a.status == 'offline').length;
    final maintenance = assets.where((a) => a.status == 'maintenance').length;

    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        _buildTableRow('Total de Ativos', '$total', isBold: true),
        _buildTableRow(
          'Online',
          '$online (${_calculatePercentage(online, total)}%)',
        ),
        _buildTableRow(
          'Offline',
          '$offline (${_calculatePercentage(offline, total)}%)',
        ),
        _buildTableRow(
          'Em Manutenção',
          '$maintenance (${_calculatePercentage(maintenance, total)}%)',
        ),
      ],
    );
  }

  /// Helper para criar linhas da tabela de resumo
  pw.TableRow _buildTableRow(String label, String value, {bool isBold = false}) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            label,
            style: isBold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null,
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }

  /// Calcula porcentagem com uma casa decimal
  String _calculatePercentage(int part, int total) {
    if (total == 0) return '0.0';
    return (part / total * 100).toStringAsFixed(1);
  }

  /// Constrói a tabela detalhada dos ativos para o PDF
  pw.Widget _buildDetailedTable(
    List<ManagedAsset> assets,
    AssetModuleConfig module,
  ) {
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
        pw.Header(level: 1, child: pw.Text('Lista Detalhada de Ativos')),
        pw.SizedBox(height: 10),
        pw.Table.fromTextArray(
          headers: headers,
          data: data,
          border: pw.TableBorder.all(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellStyle: const pw.TextStyle(fontSize: 8),
          cellAlignment: pw.Alignment.centerLeft,
          headerAlignment: pw.Alignment.centerLeft,
        ),
      ],
    );
  }

  /// Placeholder para gráfico de status no PDF
  ///
  /// Nota: Para gráficos reais, considere usar a biblioteca charts_flutter
  /// e converter para imagem, ou usar pdf_widgets com gráficos customizados
  pw.Widget _buildStatusChart(List<ManagedAsset> assets) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        color: PdfColors.grey100,
      ),
      child: pw.Text(
        'Placeholder para Gráfico de Status (Online, Offline, Manutenção)',
        style: const pw.TextStyle(color: PdfColors.grey600),
      ),
    );
  }

  /// Gera relatório em formato Excel com múltiplas abas
  ///
  /// [assets] - Lista de ativos a serem incluídos no relatório
  /// [module] - Configuração do módulo com informações de colunas
  ///
  /// Retorna [List<int>?] com os bytes do arquivo Excel ou null em caso de erro
  Future<List<int>?> generateExcelReport({
    required List<ManagedAsset> assets,
    required AssetModuleConfig module,
  }) async {
    final excel = Excel.createExcel();

    // Aba 1: Resumo
    _createSummarySheet(excel, assets);

    // Aba 2: Detalhes
    _createDetailsSheet(excel, assets, module);

    // Aba 3: Por Localização
    _createLocationSheet(excel, assets);

    // Remove a aba padrão se existir
    excel.delete('Sheet1');

    return excel.encode();
  }

  /// Cria a aba de resumo no Excel
  void _createSummarySheet(Excel excel, List<ManagedAsset> assets) {
    final summarySheet = excel['Resumo'];
    summarySheet.appendRow([TextCellValue('Métrica'), TextCellValue('Valor')]);
    summarySheet.appendRow([
      TextCellValue('Total de Ativos'),
      IntCellValue(assets.length),
    ]);
    summarySheet.appendRow([
      TextCellValue('Online'),
      IntCellValue(assets.where((a) => a.status == 'online').length),
    ]);
    summarySheet.appendRow([
      TextCellValue('Offline'),
      IntCellValue(assets.where((a) => a.status == 'offline').length),
    ]);
    summarySheet.appendRow([
      TextCellValue('Em Manutenção'),
      IntCellValue(assets.where((a) => a.status == 'maintenance').length),
    ]);
  }

  /// Cria a aba de detalhes no Excel
  void _createDetailsSheet(
    Excel excel,
    List<ManagedAsset> assets,
    AssetModuleConfig module,
  ) {
    final detailsSheet = excel['Detalhes'];
    
    // Adiciona cabeçalhos
    detailsSheet.appendRow(
      module.tableColumns.map((c) => TextCellValue(c.label)).toList(),
    );

    // Adiciona dados dos ativos
    for (final asset in assets) {
      final row = module.tableColumns.map((col) {
        final value = asset.toJson()[col.dataKey];
        return TextCellValue(value?.toString() ?? 'N/D');
      }).toList();
      detailsSheet.appendRow(row);
    }
  }

  /// Cria a aba de agrupamento por localização no Excel
  void _createLocationSheet(Excel excel, List<ManagedAsset> assets) {
    final locationSheet = excel['Por Localização'];
    final groupedByUnit = _groupByLocation(assets);

    // Adiciona cabeçalhos
    locationSheet.appendRow([
      TextCellValue('Unidade'),
      TextCellValue('Setor'),
      TextCellValue('Andar'),
      TextCellValue('Total'),
    ]);

    // Adiciona dados agrupados
    groupedByUnit.forEach((key, list) {
      final parts = key.split('|');
      locationSheet.appendRow([
        TextCellValue(parts[0]),
        TextCellValue(parts[1]),
        TextCellValue(parts[2]),
        IntCellValue(list.length),
      ]);
    });
  }

  /// Agrupa ativos por localização (unidade, setor e andar)
  Map<String, List<ManagedAsset>> _groupByLocation(List<ManagedAsset> assets) {
    final Map<String, List<ManagedAsset>> grouped = {};

    for (final asset in assets) {
      final key = '${asset.unit}|${asset.sector}|${asset.floor}';
      grouped.putIfAbsent(key, () => []).add(asset);
    }

    return grouped;
  }
}