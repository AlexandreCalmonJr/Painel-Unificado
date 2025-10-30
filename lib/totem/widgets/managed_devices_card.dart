import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:painel_windowns/models/totem.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/totem/totem_detail_screen.dart';
import 'package:path_provider/path_provider.dart';

/// Widget que exibe uma lista de totens em um cartão com uma tabela
class ManagedTotemsCard extends StatelessWidget {
  final String title;
  final List<Totem> totems;
  final AuthService authService;
  final VoidCallback? onTotemUpdate;

  const ManagedTotemsCard({
    required this.authService,
    super.key,
    required this.title,
    required this.totems,
    this.onTotemUpdate,
  });

  /// Gera e baixa um arquivo CSV com os dados dos totens
  Future<void> _downloadTotemsCsv(
      BuildContext context, List<Totem> totemsToExport) async {
    final headers = [
      'Hostname',
      'Status',
      'IP',
      'Localização',
      'Serial',
      'Status Zebra',
      'Status Bematech',
      'Tipo de Totem',
      'Mozilla Firefox',
      'Java',
      'Última Sincronização'
    ];

    final rows = totemsToExport.map((totem) {
      return [
        totem.hostname,
        totem.status,
        totem.ip,
        totem.location,
        totem.serialNumber,
        totem.zebraStatus,
        totem.bematechStatus,
        totem.totemType,
        totem.mozillaVersion,
        totem.javaVersion,
        DateFormat('dd/MM/yyyy HH:mm:ss').format(totem.lastSeen),
      ]
          .map((value) => '"${value.toString().replaceAll('"', '""')}"')
          .join(',');
    }).toList();

    final csvContent = [headers.join(','), ...rows].join('\n');
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path =
          '${directory.path}${Platform.pathSeparator}totens_$timestamp.csv';
      final file = File(path);
      await file.writeAsString(csvContent);

      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('CSV salvo em: $path')),
      );
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
    // Ordena os totens por hostname
    List<Totem> sortedTotems = List.from(totems);
    sortedTotems.sort((a, b) =>
        (a.hostname).toLowerCase().compareTo((b.hostname).toLowerCase()));

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
                onPressed: () => _downloadTotemsCsv(context, sortedTotems),
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
          Expanded(
            child: SingleChildScrollView(
              child: Table(
                border: const TableBorder(
                  horizontalInside: BorderSide(
                    color: Colors.black12,
                    width: 0.5,
                  ),
                ),
                columnWidths: const {
                  0: FlexColumnWidth(2.0),  // Hostname
                  1: FlexColumnWidth(1.2),  // Status
                  2: FlexColumnWidth(1.5),  // IP
                  3: FlexColumnWidth(2.0),  // Localização
                  4: FlexColumnWidth(1.5),  // Serial
                  5: FlexColumnWidth(1.3),  // Status Zebra
                  6: FlexColumnWidth(1.5),  // Status Bematech
                  7: FlexColumnWidth(1.3),  // Tipo de Totem
                  8: FlexColumnWidth(1.2),  // Mozilla
                  9: FlexColumnWidth(1.2),  // Java
                  10: FlexColumnWidth(1.8), // Última Sincronização
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade50),
                    children: [
                      _buildTableHeader('Hostname'),
                      _buildTableHeader('Status'),
                      _buildTableHeader('IP'),
                      _buildTableHeader('Localização'),
                      _buildTableHeader('Serial'),
                      _buildTableHeader('Status Zebra'),
                      _buildTableHeader('Status Bematech'),
                      _buildTableHeader('Tipo de Totem'),
                      _buildTableHeader('Mozilla Firefox'),
                      _buildTableHeader('Java'),
                      _buildTableHeader('Última Sincronização'),
                    ],
                  ),
                  ...sortedTotems.map(
                    (totem) => _buildTotemTableRow(context, totem),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

  TableRow _buildTotemTableRow(BuildContext context, Totem totem) {
    return TableRow(
      children: [
        _buildClickableTotemCell(context, totem),
        TableCell(
            child: Center(
                child: _buildStatusChip(
                    totem.status, getStatusColor(totem.status)))),
        _buildTableCell(totem.ip),
        _buildTableCell(totem.unit ?? totem.location!),
        _buildTableCell(totem.serialNumber),
        _buildTableCell(totem.zebraStatus),
        _buildTableCell(totem.bematechStatus),
        _buildTableCell(totem.totemType),
        _buildTableCell(totem.mozillaVersion),
        _buildTableCell(totem.javaVersion),
        _buildTableCell(DateFormat('dd/MM/yyyy HH:mm').format(totem.lastSeen)),
      ],
    );
  }

Widget _buildClickableTotemCell(BuildContext context, Totem totem) {
  return TableCell(
    verticalAlignment: TableCellVerticalAlignment.middle,
    child: InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TotemDetailScreen(
            totem: totem,
            authService: authService, // ✅ Adicione esta linha
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Text(
          totem.hostname,
          style: const TextStyle(fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
  );
}

  Widget _buildTableCell(String text) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Text(text, style: const TextStyle(fontSize: 13)),
      ),
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          status,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return Colors.green;
      case 'offline':
        return Colors.red;
      case 'maintenance':
      case 'com erro':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}