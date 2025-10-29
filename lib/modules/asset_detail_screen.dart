import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:painel_windowns/devices/utils/helpers.dart';
import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/models/desktop.dart';
import 'package:painel_windowns/models/notebook.dart';
import 'package:painel_windowns/models/painel.dart';
import 'package:painel_windowns/models/printer.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/module_management_service.dart';

// Placeholder para fetchAssetHistory
extension ModuleManagementServiceAssetHistory on ModuleManagementService {
  Future<List<Map<String, dynamic>>> fetchAssetHistory(String token, String assetId) async {
    return <Map<String, dynamic>>[];
  }
}

class AssetDetailScreen extends StatefulWidget {
  final ManagedAsset asset;
  final AuthService authService;
  final AssetModuleConfig moduleConfig;

  const AssetDetailScreen({
    super.key,
    required this.asset,
    required this.authService,
    required this.moduleConfig,
  });

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  final ModuleManagementService _moduleService = ModuleManagementService(authService: AuthService());
  late Future<List<Map<String, dynamic>>> _assetHistoryFuture;
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _assetHistoryFuture = _fetchAssetHistory();
  }

  Future<List<Map<String, dynamic>>> _fetchAssetHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final token = widget.authService.currentToken;
      if (token == null || token.isEmpty) return [];
      return await _moduleService.fetchAssetHistory(token, widget.asset.id);
    } catch (e) {
      print('Erro ao buscar histórico: $e');
      return [];
    } finally {
      setState(() => _isLoadingHistory = false);
    }
  }

  void _refreshAssetHistory() {
    setState(() {
      _assetHistoryFuture = _fetchAssetHistory();
    });
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copiado para a área de transferência'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  IconData _getAssetIcon() {
    switch (widget.asset.assetType) {
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
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(status.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
        const Divider(),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700]))),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
                if (copyable)
                  IconButton(
                    icon: Icon(Icons.copy, size: 16, color: Colors.grey[600]),
                    onPressed: () => _copyToClipboard(value, label),
                    tooltip: 'Copiar',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) return 'Agora mesmo';
    if (difference.inHours < 1) return 'Há ${difference.inMinutes} minuto(s)';
    if (difference.inDays < 1) return 'Há ${difference.inHours} hora(s)';
    if (difference.inDays < 7) return 'Há ${difference.inDays} dia(s)';
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: () async => _refreshAssetHistory(),
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === Informações Básicas ===
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildSection('Informações Básicas', [
                          _buildDetailRow('Serial', widget.asset.serialNumber, Icons.qr_code, copyable: true),
                          _buildDetailRow('Localização', widget.asset.location ?? 'N/D', Icons.location_on),
                          _buildDetailRow('Unidade', widget.asset.unit ?? 'N/D', Icons.business),
                          _buildDetailRow('Setor', widget.asset.sector ?? 'N/D', Icons.domain),
                          _buildDetailRow('Andar', widget.asset.floor ?? 'N/D', Icons.layers),
                          _buildDetailRow('Atribuído a', widget.asset.assignedTo ?? 'Não atribuído', Icons.person),
                          _buildDetailRow('Última Conexão', _formatDateTime(widget.asset.lastSeen), Icons.access_time),
                        ]),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // === Detalhes Específicos por Tipo ===
                    if (widget.asset is Desktop)
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildDesktopDetails(widget.asset as Desktop),
                        ),
                      )
                    else if (widget.asset is Notebook)
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildNotebookDetails(widget.asset as Notebook),
                        ),
                      )
                    else if (widget.asset is Panel)
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildPanelDetails(widget.asset as Panel),
                        ),
                      )
                    else if (widget.asset is Printer)
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildPrinterDetails(widget.asset as Printer),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // === Histórico de Manutenção ===
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.history, color: Colors.orange, size: 20),
                                const SizedBox(width: 8),
                                const Text('Histórico de Manutenção', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const Divider(height: 24),
                            _isLoadingHistory
                                ? const Center(child: CircularProgressIndicator())
                                : FutureBuilder<List<Map<String, dynamic>>>(
                                    future: _assetHistoryFuture,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                        return Column(
                                          children: snapshot.data!.map((entry) {
                                            final timestamp = DateTime.parse(entry['timestamp'] as String);
                                            return _buildTimelineTile(
                                              title: entry['status'] as String,
                                              subtitle: '${formatDateTime(timestamp)} - ${entry['reason'] ?? ''}',
                                            );
                                          }).toList(),
                                        );
                                      }
                                      return const Text('Nenhum histórico disponível');
                                    },
                                  ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // === Dados Customizados ===
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildSection('Dados Customizados', [
                          _buildDetailRow('Campo 1', widget.asset.customData['custom_field_1']?.toString() ?? 'N/A', Icons.info),
                          _buildDetailRow('Campo 2', widget.asset.customData['custom_field_2']?.toString() ?? 'N/A', Icons.info),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildHeader() {
    final statusInfo = {
      'online': {'color': Colors.green, 'icon': Icons.cloud_done_outlined, 'text': 'Online'},
      'offline': {'color': Colors.red, 'icon': Icons.cloud_off_outlined, 'text': 'Offline'},
      'maintenance': {'color': Colors.orange, 'icon': Icons.build_outlined, 'text': 'Em Manutenção'},
      'retired': {'color': Colors.purple, 'icon': Icons.archive_outlined, 'text': 'Aposentado'},
    };

    final status = statusInfo[widget.asset.status] ?? {'color': Colors.grey, 'icon': Icons.help_outline, 'text': 'Desconhecido'};

    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(widget.asset.assetName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [status['color'] as Color, (status['color'] as Color).withOpacity(0.7)],
            ),
          ),
          child: Stack(
            children: [
              Center(child: Icon(status['icon'] as IconData, size: 80, color: Colors.white.withOpacity(0.8))),
              Positioned(
                top: 50,
                right: 16,
                child: _buildStatusChip(status['text'] as String),
              ),
              Positioned(
                top: 50,
                left: 16,
                child: Icon(_getAssetIcon(), color: Colors.white, size: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineTile({required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(width: 2, height: 8, color: Colors.grey[300]),
              Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.withOpacity(0.2)), child: const Icon(Icons.event_note, color: Colors.blue, size: 16)),
              Expanded(child: Container(width: 2, color: Colors.grey[300])),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === Métodos de Detalhes por Tipo (iguais ao dialog) ===
  Widget _buildDesktopDetails(Desktop desktop) => _buildTypeDetails([
        _buildSection('Identificação', [
          _buildDetailRow('Hostname', desktop.hostname, Icons.dns, copyable: true),
          _buildDetailRow('Modelo', desktop.model, Icons.laptop_chromebook),
          _buildDetailRow('Fabricante', desktop.manufacturer, Icons.business_center),
        ]),
        _buildSection('Hardware', [
          _buildDetailRow('Processador', desktop.processor, Icons.memory),
          _buildDetailRow('Memória RAM', desktop.ram, Icons.storage),
          _buildDetailRow('Armazenamento', desktop.storage, Icons.sd_storage),
          _buildDetailRow('Tipo de HD', desktop.storageType, Icons.data_usage),
        ]),
        _buildSection('Sistema Operacional', [
          _buildDetailRow('SO', desktop.operatingSystem, Icons.computer),
          _buildDetailRow('Versão do SO', desktop.osVersion, Icons.info),
        ]),
        _buildSection('Rede', [
          _buildDetailRow('Endereço IP', desktop.ipAddress, Icons.network_check, copyable: true),
          _buildDetailRow('MAC Address', desktop.macAddress, Icons.router, copyable: true),
        ]),
        _buildSection('Periféricos', [
          _buildDetailRow('Leitor Biométrico', desktop.biometricReader ?? 'N/D', Icons.fingerprint),
          _buildDetailRow('Impressora Conectada', desktop.connectedPrinter ?? 'N/D', Icons.print),
        ]),
        _buildSection('Software', [
          _buildDetailRow('Versão Java', desktop.javaVersion ?? 'N/D', Icons.code),
          _buildDetailRow('Navegador', desktop.browserVersion ?? 'N/D', Icons.public),
        ]),
        _buildSection('Segurança', [
          _buildDetailRow('Antivírus', desktop.antivirusStatus ? 'Ativo' : 'Inativo', Icons.security),
          if (desktop.antivirusVersion != null) _buildDetailRow('Versão Antivírus', desktop.antivirusVersion!, Icons.verified_user),
        ]),
      ]);

  Widget _buildNotebookDetails(Notebook notebook) => _buildTypeDetails([
        _buildSection('Identificação', [
          _buildDetailRow('Hostname', notebook.hostname, Icons.dns, copyable: true),
          _buildDetailRow('Modelo', notebook.model, Icons.laptop),
          _buildDetailRow('Fabricante', notebook.manufacturer, Icons.business_center),
        ]),
        _buildSection('Hardware', [
          _buildDetailRow('Processador', notebook.processor, Icons.memory),
          _buildDetailRow('Memória RAM', notebook.ram, Icons.storage),
          _buildDetailRow('Armazenamento', notebook.storage, Icons.sd_storage),
        ]),
        _buildSection('Bateria', [
          _buildDetailRow('Nível', notebook.batteryLevel != null ? '${notebook.batteryLevel}%' : 'N/D', Icons.battery_charging_full),
          _buildDetailRow('Saúde', notebook.batteryHealth ?? 'N/D', Icons.health_and_safety),
        ]),
        _buildSection('Rede', [
          _buildDetailRow('Endereço IP', notebook.ipAddress, Icons.network_check, copyable: true),
          _buildDetailRow('MAC Address', notebook.macAddress, Icons.router, copyable: true),
        ]),
        _buildSection('Segurança', [
          _buildDetailRow('Antivírus', notebook.antivirusStatus ? 'Ativo' : 'Inativo', Icons.security),
          _buildDetailRow('Criptografia', notebook.isEncrypted ? 'Ativa' : 'Inativa', Icons.lock),
        ]),
      ]);

  Widget _buildPanelDetails(Panel panel) => _buildTypeDetails([
        _buildSection('Display', [
          _buildDetailRow('Tamanho da Tela', panel.screenSize, Icons.aspect_ratio),
          _buildDetailRow('Resolução', panel.resolution, Icons.photo_size_select_large),
          if (panel.brightness != null) _buildDetailRow('Brilho', '${panel.brightness}%', Icons.brightness_6),
          if (panel.volume != null) _buildDetailRow('Volume', '${panel.volume}%', Icons.volume_up),
        ]),
        _buildSection('Rede', [
          _buildDetailRow('Endereço IP', panel.ipAddress, Icons.network_check, copyable: true),
          _buildDetailRow('MAC Address', panel.macAddress, Icons.router, copyable: true),
        ]),
        _buildSection('Sistema', [
          _buildDetailRow('Firmware', panel.firmwareVersion, Icons.system_update),
          _buildDetailRow('Entrada HDMI', panel.hdmiInput ?? 'N/D', Icons.hd),
        ]),
      ]);

  Widget _buildPrinterDetails(Printer printer) => _buildTypeDetails([
        _buildSection('Conectividade', [
          _buildDetailRow('Tipo de Conexão', printer.connectionType, Icons.settings_input_hdmi),
          if (printer.ipAddress != null) _buildDetailRow('Endereço IP', printer.ipAddress!, Icons.network_check, copyable: true),
          if (printer.hostComputerName != null) _buildDetailRow('Computador Host', printer.hostComputerName!, Icons.computer),
        ]),
        _buildSection('Status', [
          _buildDetailRow('Status', printer.printerStatus, Icons.print),
          if (printer.errorMessage != null) _buildDetailRow('Erro', printer.errorMessage!, Icons.error, copyable: true),
        ]),
        _buildSection('Contadores', [
          if (printer.totalPageCount != null) _buildDetailRow('Total de Páginas', printer.totalPageCount.toString(), Icons.description),
          if (printer.colorPageCount != null) _buildDetailRow('Páginas Coloridas', printer.colorPageCount.toString(), Icons.color_lens),
          if (printer.blackWhitePageCount != null) _buildDetailRow('Páginas P&B', printer.blackWhitePageCount.toString(), Icons.filter_b_and_w),
        ]),
        _buildSection('Capacidades', [
          _buildDetailRow('Impressão Duplex', printer.isDuplex == true ? 'Sim' : 'Não', Icons.compare_arrows),
          _buildDetailRow('Impressão Colorida', printer.isColor == true ? 'Sim' : 'Não', Icons.palette),
        ]),
      ]);

  Widget _buildTypeDetails(List<Widget> sections) {
    return Column(children: sections.map((s) => Padding(padding: const EdgeInsets.only(bottom: 20), child: s)).toList());
  }
}