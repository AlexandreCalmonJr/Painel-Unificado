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
import 'package:painel_windowns/widgets/common/app_card.dart';

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
  late final ModuleManagementService _moduleService;
  late Future<List<Map<String, dynamic>>> _assetHistoryFuture;
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _moduleService = ModuleManagementService(authService: widget.authService);
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
      if (mounted) {
        setState(() => _isLoadingHistory = false);
      }
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

  Map<String, dynamic> _getAssetStatus() {
    Color color;
    String text;
    IconData icon;

    switch (widget.asset.status.toLowerCase()) {
      case 'online':
        color = Colors.green;
        text = 'Online';
        icon = Icons.check_circle_outline;
        break;
      case 'maintenance':
        color = Colors.orange;
        text = 'Manutenção';
        icon = Icons.build_outlined;
        break;
      case 'retired':
        color = Colors.purple;
        text = 'Aposentado';
        icon = Icons.archive_outlined;
        break;
      default:
        color = Colors.red;
        text = 'Offline';
        icon = Icons.error_outline;
    }

    return {'color': color, 'text': text, 'icon': icon};
  }

  @override
  Widget build(BuildContext context) {
    final status = _getAssetStatus();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.asset.assetName,
          style: const TextStyle(color: Colors.black87, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[200], height: 1),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (status['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (status['color'] as Color).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  status['icon'] as IconData,
                  size: 16,
                  color: status['color'] as Color,
                ),
                const SizedBox(width: 8),
                Text(
                  (status['text'] as String).toUpperCase(),
                  style: TextStyle(
                    color: status['color'] as Color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshAssetHistory(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildPrimaryColumn()),
                    const SizedBox(width: 24),
                    Expanded(flex: 2, child: _buildSecondaryColumn()),
                  ],
                );
              }
              return Column(
                children: [
                  _buildPrimaryColumn(),
                  const SizedBox(height: 24),
                  _buildSecondaryColumn(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryColumn() {
    return Column(
      children: [
        _buildSectionCard(
          title: 'Informações Básicas',
          icon: Icons.info_outline,
          children: [
            _buildDetailRow(
              'Serial',
              widget.asset.serialNumber,
              Icons.qr_code,
              copyable: true,
            ),
            _buildDetailRow(
              'Usuário Logado',
              widget.asset.currentUser ?? 'N/D',
              Icons.person_outline,
              copyable: true,
            ),
            _buildDetailRow(
              'Localização',
              widget.asset.location ?? 'N/D',
              Icons.location_on,
            ),
            _buildDetailRow(
              'Unidade',
              widget.asset.unit ?? 'N/D',
              Icons.business,
            ),
            _buildDetailRow(
              'Setor',
              widget.asset.sector ?? 'N/D',
              Icons.domain,
            ),
            _buildDetailRow('Andar', widget.asset.floor ?? 'N/D', Icons.layers),
            _buildDetailRow(
              'Atribuído a',
              widget.asset.assignedTo ?? 'Não atribuído',
              Icons.person,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildAssetSpecificDetails(),
      ],
    );
  }

  Widget _buildSecondaryColumn() {
    return Column(
      children: [
        _buildSectionCard(
          title: 'Status e Conexão',
          icon: Icons.monitor_heart_outlined,
          children: [
            _buildDetailRow(
              'Última Sincronização',
              formatDateTime(widget.asset.lastSeen),
              Icons.access_time,
            ),
            _buildDetailRow(
              'Tempo Ligado (Uptime)',
              widget.asset.uptime ?? 'N/D',
              Icons.timer,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildHistoryCard(),
        const SizedBox(height: 24),
        if (widget.asset.customData.isNotEmpty)
          _buildSectionCard(
            title: 'Dados Customizados',
            icon: Icons.extension,
            children:
                widget.asset.customData.entries.map((entry) {
                  return _buildDetailRow(
                    entry.key,
                    entry.value.toString(),
                    Icons.info_outline,
                  );
                }).toList(),
          ),
      ],
    );
  }

  Widget _buildHistoryCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCardTitle('Histórico de Manutenção', Icons.history),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: _refreshAssetHistory,
                tooltip: 'Atualizar Histórico',
                color: Colors.grey[600],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _isLoadingHistory
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
              : FutureBuilder<List<Map<String, dynamic>>>(
                future: _assetHistoryFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Erro: ${snapshot.error}',
                        style: TextStyle(color: Colors.red[400]),
                      ),
                    );
                  }
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final entry = snapshot.data![index];
                        final timestamp = DateTime.parse(
                          entry['timestamp'] as String,
                        );
                        return _buildTimelineTile(
                          title: entry['status'] as String,
                          subtitle:
                              '${formatDateTime(timestamp)} - ${entry['reason'] ?? ''}',
                          isFirst: index == 0,
                          isLast: index == snapshot.data!.length - 1,
                        );
                      },
                    );
                  }
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.history_toggle_off,
                            color: Colors.grey[300],
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Nenhum histórico disponível',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle(title, icon),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCardTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[800]),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    bool copyable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (copyable)
                  InkWell(
                    onTap: () => _copyToClipboard(value, label),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.copy,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTile({
    required String title,
    required String subtitle,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 16,
                  color: isFirst ? Colors.transparent : Colors.grey[200],
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : Colors.grey[200],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetSpecificDetails() {
    if (widget.asset is Desktop) {
      return _buildSectionCard(
        title: 'Detalhes do Desktop',
        icon: Icons.computer,
        children: _buildDesktopDetails(widget.asset as Desktop),
      );
    } else if (widget.asset is Notebook) {
      return _buildSectionCard(
        title: 'Detalhes do Notebook',
        icon: Icons.laptop,
        children: _buildNotebookDetails(widget.asset as Notebook),
      );
    } else if (widget.asset is Panel) {
      return _buildSectionCard(
        title: 'Detalhes do Painel',
        icon: Icons.tv,
        children: _buildPanelDetails(widget.asset as Panel),
      );
    } else if (widget.asset is Printer) {
      return _buildSectionCard(
        title: 'Detalhes da Impressora',
        icon: Icons.print,
        children: _buildPrinterDetails(widget.asset as Printer),
      );
    }
    return const SizedBox.shrink();
  }

  List<Widget> _buildDesktopDetails(Desktop desktop) => [
    _buildDetailRow('Hostname', desktop.hostname, Icons.dns, copyable: true),
    _buildDetailRow('Modelo', desktop.model, Icons.laptop_chromebook),
    _buildDetailRow('Fabricante', desktop.manufacturer, Icons.business_center),
    _buildDetailRow('Processador', desktop.processor, Icons.memory),
    _buildDetailRow('Memória RAM', desktop.ram, Icons.storage),
    _buildDetailRow('Armazenamento', desktop.storage, Icons.sd_storage),
    _buildDetailRow('Tipo de HD', desktop.storageType, Icons.data_usage),
    _buildDetailRow('SO', desktop.operatingSystem, Icons.computer),
    _buildDetailRow('Versão do SO', desktop.osVersion, Icons.info),
    _buildDetailRow(
      'Endereço IP',
      desktop.ipAddress,
      Icons.network_check,
      copyable: true,
    ),
    _buildDetailRow(
      'MAC Address',
      desktop.macAddress,
      Icons.router,
      copyable: true,
    ),
    _buildDetailRow(
      'Leitor Biométrico',
      desktop.biometricReader ?? 'N/D',
      Icons.fingerprint,
    ),
    _buildDetailRow(
      'Impressora Conectada',
      desktop.connectedPrinter ?? 'N/D',
      Icons.print,
    ),
    _buildDetailRow('Versão Java', desktop.javaVersion ?? 'N/D', Icons.code),
    _buildDetailRow('Navegador', desktop.browserVersion ?? 'N/D', Icons.public),
    _buildDetailRow(
      'Antivírus',
      desktop.antivirusStatus ? 'Ativo' : 'Inativo',
      Icons.security,
    ),
    if (desktop.antivirusVersion != null)
      _buildDetailRow(
        'Versão Antivírus',
        desktop.antivirusVersion!,
        Icons.verified_user,
      ),
  ];

  List<Widget> _buildNotebookDetails(Notebook notebook) => [
    _buildDetailRow('Hostname', notebook.hostname, Icons.dns, copyable: true),
    _buildDetailRow('Modelo', notebook.model, Icons.laptop),
    _buildDetailRow('Fabricante', notebook.manufacturer, Icons.business_center),
    _buildDetailRow('Processador', notebook.processor, Icons.memory),
    _buildDetailRow('Memória RAM', notebook.ram, Icons.storage),
    _buildDetailRow('Armazenamento', notebook.storage, Icons.sd_storage),
    _buildDetailRow(
      'Nível Bateria',
      notebook.batteryLevel != null ? '${notebook.batteryLevel}%' : 'N/D',
      Icons.battery_charging_full,
    ),
    _buildDetailRow(
      'Saúde Bateria',
      notebook.batteryHealth ?? 'N/D',
      Icons.health_and_safety,
    ),
    _buildDetailRow(
      'Endereço IP',
      notebook.ipAddress,
      Icons.network_check,
      copyable: true,
    ),
    _buildDetailRow(
      'MAC Address',
      notebook.macAddress,
      Icons.router,
      copyable: true,
    ),
    _buildDetailRow(
      'Antivírus',
      notebook.antivirusStatus ? 'Ativo' : 'Inativo',
      Icons.security,
    ),
    _buildDetailRow(
      'Criptografia',
      notebook.isEncrypted ? 'Ativa' : 'Inativa',
      Icons.lock,
    ),
  ];

  List<Widget> _buildPanelDetails(Panel panel) => [
    _buildDetailRow('Tamanho da Tela', panel.screenSize, Icons.aspect_ratio),
    _buildDetailRow(
      'Resolução',
      panel.resolution,
      Icons.photo_size_select_large,
    ),
    if (panel.brightness != null)
      _buildDetailRow('Brilho', '${panel.brightness}%', Icons.brightness_6),
    if (panel.volume != null)
      _buildDetailRow('Volume', '${panel.volume}%', Icons.volume_up),
    _buildDetailRow(
      'Endereço IP',
      panel.ipAddress,
      Icons.network_check,
      copyable: true,
    ),
    _buildDetailRow(
      'MAC Address',
      panel.macAddress,
      Icons.router,
      copyable: true,
    ),
    _buildDetailRow('Firmware', panel.firmwareVersion, Icons.system_update),
    _buildDetailRow('Entrada HDMI', panel.hdmiInput ?? 'N/D', Icons.hd),
  ];

  List<Widget> _buildPrinterDetails(Printer printer) => [
    _buildDetailRow(
      'Tipo de Conexão',
      printer.connectionType,
      Icons.settings_input_hdmi,
    ),
    if (printer.ipAddress != null)
      _buildDetailRow(
        'Endereço IP',
        printer.ipAddress!,
        Icons.network_check,
        copyable: true,
      ),
    if (printer.hostComputerName != null)
      _buildDetailRow(
        'Computador Host',
        printer.hostComputerName!,
        Icons.computer,
      ),
    _buildDetailRow('Status', printer.printerStatus, Icons.print),
    if (printer.errorMessage != null)
      _buildDetailRow(
        'Erro',
        printer.errorMessage!,
        Icons.error,
        copyable: true,
      ),
    if (printer.totalPageCount != null)
      _buildDetailRow(
        'Total de Páginas',
        printer.totalPageCount.toString(),
        Icons.description,
      ),
    if (printer.colorPageCount != null)
      _buildDetailRow(
        'Páginas Coloridas',
        printer.colorPageCount.toString(),
        Icons.color_lens,
      ),
    if (printer.blackWhitePageCount != null)
      _buildDetailRow(
        'Páginas P&B',
        printer.blackWhitePageCount.toString(),
        Icons.filter_b_and_w,
      ),
    _buildDetailRow(
      'Impressão Duplex',
      printer.isDuplex == true ? 'Sim' : 'Não',
      Icons.compare_arrows,
    ),
    _buildDetailRow(
      'Impressão Colorida',
      printer.isColor == true ? 'Sim' : 'Não',
      Icons.palette,
    ),
  ];
}
