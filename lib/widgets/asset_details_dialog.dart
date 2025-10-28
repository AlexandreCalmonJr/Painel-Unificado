// File: lib/widgets/asset_details_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/models/desktop.dart';
import 'package:painel_windowns/models/notebook.dart';
import 'package:painel_windowns/models/painel.dart';
import 'package:painel_windowns/models/printer.dart';

class AssetDetailsDialog extends StatelessWidget {
  final ManagedAsset asset;

  const AssetDetailsDialog({super.key, required this.asset});

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copiado para a área de transferência'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade500],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(_getAssetIcon(), color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.assetName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          asset.assetType.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(asset.status),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('Informações Básicas', [
                      _buildDetailRow(
                        context,
                        'Serial',
                        asset.serialNumber,
                        Icons.qr_code,
                        copyable: true,
                      ),
                      _buildDetailRow(
                        context,
                        'Localização',
                        asset.location ?? 'N/D',
                        Icons.location_on,
                      ),
                      _buildDetailRow(
                        context,
                        'Unidade',
                        asset.unit ?? 'N/D',
                        Icons.business,
                      ),
                      _buildDetailRow(
                        context,
                        'Setor',
                        asset.sector ?? 'N/D',
                        Icons.domain,
                      ),
                      _buildDetailRow(
                        context,
                        'Andar',
                        asset.floor ?? 'N/D',
                        Icons.layers,
                      ),
                      _buildDetailRow(
                        context,
                        'Atribuído a',
                        asset.assignedTo ?? 'Não atribuído',
                        Icons.person,
                      ),
                      _buildDetailRow(
                        context,
                        'Última Conexão',
                        _formatDateTime(asset.lastSeen),
                        Icons.access_time,
                      ),
                    ]),

                    const SizedBox(height: 20),

                    // Seções específicas por tipo
                    if (asset is Desktop) _buildDesktopDetails(context, asset as Desktop),
                    if (asset is Notebook) _buildNotebookDetails(context, asset as Notebook),
                    if (asset is Panel) _buildPanelDetails(context, asset as Panel),
                    if (asset is Printer) _buildPrinterDetails(context, asset as Printer),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAssetIcon() {
    switch (asset.assetType) {
      case 'desktop':
        return Icons.computer;
      case 'notebook':
        return Icons.laptop;
      case 'panel':
        return Icons.tv;
      case 'printer':
        return Icons.print;
      default:
        return Icons.devices;
    }
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'online':
        color = Colors.green;
        break;
      case 'maintenance':
        color = Colors.orange;
        break;
      default:
        color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const Divider(),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool copyable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                if (copyable)
                  IconButton(
                    icon: Icon(Icons.copy, size: 16, color: Colors.grey[600]),
                    onPressed: () => _copyToClipboard(context, value, label),
                    tooltip: 'Copiar',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopDetails(BuildContext context, Desktop desktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection('Identificação', [
          _buildDetailRow(context, 'Hostname', desktop.hostname, Icons.dns, copyable: true),
          _buildDetailRow(context, 'Modelo', desktop.model, Icons.laptop_chromebook),
          _buildDetailRow(context, 'Fabricante', desktop.manufacturer, Icons.business_center),
        ]),
        const SizedBox(height: 20),
        _buildSection('Hardware', [
          _buildDetailRow(context, 'Processador', desktop.processor, Icons.memory),
          _buildDetailRow(context, 'Memória RAM', desktop.ram, Icons.storage),
          _buildDetailRow(context, 'Armazenamento', desktop.storage, Icons.sd_storage),
          _buildDetailRow(context, 'Tipo de HD', desktop.storageType, Icons.data_usage),
        ]),
        const SizedBox(height: 20),
        _buildSection('Sistema Operacional', [
          _buildDetailRow(context, 'SO', desktop.operatingSystem, Icons.computer),
          _buildDetailRow(context, 'Versão do SO', desktop.osVersion, Icons.info),
        ]),
        const SizedBox(height: 20),
        _buildSection('Rede', [
          _buildDetailRow(context, 'Endereço IP', desktop.ipAddress, Icons.network_check, copyable: true),
          _buildDetailRow(context, 'MAC Address', desktop.macAddress, Icons.router, copyable: true),
        ]),
        const SizedBox(height: 20),
        _buildSection('Periféricos', [
          _buildDetailRow(context, 'Leitor Biométrico', desktop.biometricReader ?? 'N/D', Icons.fingerprint),
          _buildDetailRow(context, 'Impressora Conectada', desktop.connectedPrinter ?? 'N/D', Icons.print),
        ]),
        const SizedBox(height: 20),
        _buildSection('Software', [
          _buildDetailRow(context, 'Versão Java', desktop.javaVersion ?? 'N/D', Icons.code),
          _buildDetailRow(context, 'Navegador', desktop.browserVersion ?? 'N/D', Icons.public),
        ]),
        const SizedBox(height: 20),
        _buildSection('Segurança', [
          _buildDetailRow(
            context,
            'Antivírus',
            desktop.antivirusStatus ? 'Ativo' : 'Inativo',
            Icons.security,
          ),
          if (desktop.antivirusVersion != null)
            _buildDetailRow(context, 'Versão Antivírus', desktop.antivirusVersion!, Icons.verified_user),
        ]),
      ],
    );
  }

  Widget _buildNotebookDetails(BuildContext context, Notebook notebook) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection('Identificação', [
          _buildDetailRow(context, 'Hostname', notebook.hostname, Icons.dns, copyable: true),
          _buildDetailRow(context, 'Modelo', notebook.model, Icons.laptop),
          _buildDetailRow(context, 'Fabricante', notebook.manufacturer, Icons.business_center),
        ]),
        const SizedBox(height: 20),
        _buildSection('Hardware', [
          _buildDetailRow(context, 'Processador', notebook.processor, Icons.memory),
          _buildDetailRow(context, 'Memória RAM', notebook.ram, Icons.storage),
          _buildDetailRow(context, 'Armazenamento', notebook.storage, Icons.sd_storage),
        ]),
        const SizedBox(height: 20),
        _buildSection('Bateria', [
          _buildDetailRow(
            context,
            'Nível',
            notebook.batteryLevel != null ? '${notebook.batteryLevel}%' : 'N/D',
            Icons.battery_charging_full,
          ),
          _buildDetailRow(context, 'Saúde', notebook.batteryHealth ?? 'N/D', Icons.health_and_safety),
        ]),
        const SizedBox(height: 20),
        _buildSection('Rede', [
          _buildDetailRow(context, 'Endereço IP', notebook.ipAddress, Icons.network_check, copyable: true),
          _buildDetailRow(context, 'MAC Address', notebook.macAddress, Icons.router, copyable: true),
        ]),
        const SizedBox(height: 20),
        _buildSection('Segurança', [
          _buildDetailRow(
            context,
            'Antivírus',
            notebook.antivirusStatus ? 'Ativo' : 'Inativo',
            Icons.security,
          ),
          _buildDetailRow(
            context,
            'Criptografia',
            notebook.isEncrypted ? 'Ativa' : 'Inativa',
            Icons.lock,
          ),
        ]),
      ],
    );
  }

  Widget _buildPanelDetails(BuildContext context, Panel panel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection('Display', [
          _buildDetailRow(context, 'Tamanho da Tela', panel.screenSize, Icons.aspect_ratio),
          _buildDetailRow(context, 'Resolução', panel.resolution, Icons.photo_size_select_large),
          if (panel.brightness != null)
            _buildDetailRow(context, 'Brilho', '${panel.brightness}%', Icons.brightness_6),
          if (panel.volume != null)
            _buildDetailRow(context, 'Volume', '${panel.volume}%', Icons.volume_up),
        ]),
        const SizedBox(height: 20),
        _buildSection('Rede', [
          _buildDetailRow(context, 'Endereço IP', panel.ipAddress, Icons.network_check, copyable: true),
          _buildDetailRow(context, 'MAC Address', panel.macAddress, Icons.router, copyable: true),
        ]),
        const SizedBox(height: 20),
        _buildSection('Sistema', [
          _buildDetailRow(context, 'Firmware', panel.firmwareVersion, Icons.system_update),
          _buildDetailRow(context, 'Entrada HDMI', panel.hdmiInput ?? 'N/D', Icons.hd),
        ]),
      ],
    );
  }

  Widget _buildPrinterDetails(BuildContext context, Printer printer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection('Conectividade', [
          _buildDetailRow(context, 'Tipo de Conexão', printer.connectionType, Icons.settings_input_hdmi),
          if (printer.ipAddress != null)
            _buildDetailRow(context, 'Endereço IP', printer.ipAddress!, Icons.network_check, copyable: true),
          if (printer.hostComputerName != null)
            _buildDetailRow(context, 'Computador Host', printer.hostComputerName!, Icons.computer),
        ]),
        const SizedBox(height: 20),
        _buildSection('Status', [
          _buildDetailRow(context, 'Status', printer.printerStatus, Icons.print),
          if (printer.errorMessage != null)
            _buildDetailRow(context, 'Erro', printer.errorMessage!, Icons.error, copyable: true),
        ]),
        const SizedBox(height: 20),
        _buildSection('Contadores', [
          if (printer.totalPageCount != null)
            _buildDetailRow(
              context,
              'Total de Páginas',
              printer.totalPageCount.toString(),
              Icons.description,
            ),
          if (printer.colorPageCount != null)
            _buildDetailRow(
              context,
              'Páginas Coloridas',
              printer.colorPageCount.toString(),
              Icons.color_lens,
            ),
          if (printer.blackWhitePageCount != null)
            _buildDetailRow(
              context,
              'Páginas P&B',
              printer.blackWhitePageCount.toString(),
              Icons.filter_b_and_w,
            ),
        ]),
        const SizedBox(height: 20),
        _buildSection('Capacidades', [
          _buildDetailRow(
            context,
            'Impressão Duplex',
            printer.isDuplex == true ? 'Sim' : 'Não',
            Icons.compare_arrows,
          ),
          _buildDetailRow(
            context,
            'Impressão Colorida',
            printer.isColor == true ? 'Sim' : 'Não',
            Icons.palette,
          ),
        ]),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Agora mesmo';
    } else if (difference.inHours < 1) {
      return 'Há ${difference.inMinutes} minuto(s)';
    } else if (difference.inDays < 1) {
      return 'Há ${difference.inHours} hora(s)';
    } else if (difference.inDays < 7) {
      return 'Há ${difference.inDays} dia(s)';
    } else {
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}