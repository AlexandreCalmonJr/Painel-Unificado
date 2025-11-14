// File: lib/modules/asset_detail_screen.dart (REVISADO E REPAGINADO)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:painel_windowns/devices/utils/helpers.dart'; // Importe seu helper de data
import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/models/desktop.dart';
import 'package:painel_windowns/models/notebook.dart';
import 'package:painel_windowns/models/painel.dart';
import 'package:painel_windowns/models/printer.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/module_management_service.dart';

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

      // ✅ CORREÇÃO: Usa o 'moduleConfig.id' e 'asset.id' para a chamada
      return await _moduleService.fetchAssetHistory(
        token,
        widget.moduleConfig.id, // Passa o ModuleID
        widget.asset.id, // Passa o AssetID
      );
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
    String text;
    switch (status.toLowerCase()) {
      case 'online':
        color = Colors.green;
        text = 'Online';
        break;
      case 'maintenance':
        color = Colors.orange;
        text = 'Manutenção';
        break;
      default:
        color = Colors.red;
        text = 'Offline';
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
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            text.toUpperCase(),
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
                // ✅ NOVO: LayoutBuilder para layout responsivo
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Usa 2 colunas se a tela for larga (ex: > 800px)
                    if (constraints.maxWidth > 800) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3, // Coluna principal (mais larga)
                            child: _buildPrimaryColumn(),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2, // Coluna secundária (mais estreita)
                            child: _buildSecondaryColumn(),
                          ),
                        ],
                      );
                    }
                    // Usa 1 coluna se a tela for estreita
                    return Column(
                      children: [
                        _buildPrimaryColumn(),
                        const SizedBox(height: 16),
                        _buildSecondaryColumn(),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ NOVO: Coluna da Esquerda (Informações Principais)
  Widget _buildPrimaryColumn() {
    return Column(
      children: [
        // === Informações Básicas ===
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
        const SizedBox(height: 16),
        // === Detalhes Específicos por Tipo ===
        _buildAssetSpecificDetails(),
      ],
    );
  }

  // ✅ NOVO: Coluna da Direita (Histórico e Dados Extras)
  Widget _buildSecondaryColumn() {
    return Column(
      children: [
        // === Status e Conexão ===
        _buildSectionCard(
          title: 'Status e Conexão',
          icon: Icons.monitor_heart_outlined,
          children: [
            _buildDetailRow(
              'Última Sincronização',
              formatDateTime(widget.asset.lastSeen), // Usa o helper de data
              Icons.access_time,
            ),
            _buildDetailRow(
              'Tempo Ligado (Uptime)',
              widget.asset.uptime ?? 'N/D',
              Icons.timer,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // === Histórico de Manutenção ===
        _buildSectionCard(
          title: 'Histórico de Manutenção',
          icon: Icons.history,
          trailing: IconButton(
            // Botão de Refresh
            icon: const Icon(Icons.refresh, size: 20, color: Colors.grey),
            onPressed: _refreshAssetHistory,
            tooltip: 'Atualizar Histórico',
          ),
          children: [
            _isLoadingHistory
                ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                )
                : FutureBuilder<List<Map<String, dynamic>>>(
                  future: _assetHistoryFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Erro: ${snapshot.error}'));
                    }
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return Column(
                        children:
                            snapshot.data!.map((entry) {
                              final timestamp = DateTime.parse(
                                entry['timestamp'] as String,
                              );
                              return _buildTimelineTile(
                                title: entry['status'] as String,
                                subtitle:
                                    '${formatDateTime(timestamp)} - ${entry['reason'] ?? ''}',
                              );
                            }).toList(),
                      );
                    }
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Nenhum histórico disponível'),
                      ),
                    );
                  },
                ),
          ],
        ),
        const SizedBox(height: 16),

        // === Dados Customizados ===
        _buildSectionCard(
          title: 'Dados Customizados',
          icon: Icons.extension,
          children: [
            _buildDetailRow(
              'Campo 1',
              widget.asset.customData['custom_field_1']?.toString() ?? 'N/A',
              Icons.info_outline,
            ),
            _buildDetailRow(
              'Campo 2',
              widget.asset.customData['custom_field_2']?.toString() ?? 'N/A',
              Icons.info_outline,
            ),
          ],
        ),
      ],
    );
  }

  // --- Funções Helper de UI (Novas e Antigas) ---

  SliverAppBar _buildHeader() {
    final statusInfo = {
      'online': {
        'color': Colors.green,
        'icon': Icons.cloud_done_outlined,
        'text': 'Online',
      },
      'offline': {
        'color': Colors.red,
        'icon': Icons.cloud_off_outlined,
        'text': 'Offline',
      },
      'maintenance': {
        'color': Colors.orange,
        'icon': Icons.build_outlined,
        'text': 'Em Manutenção',
      },
      'retired': {
        'color': Colors.purple,
        'icon': Icons.archive_outlined,
        'text': 'Aposentado',
      },
    };

    final status =
        statusInfo[widget.asset.status.toLowerCase()] ??
        {
          'color': Colors.grey,
          'icon': Icons.help_outline,
          'text': 'Desconhecido',
        };

    return SliverAppBar(
      backgroundColor: status['color'] as Color,
      foregroundColor: Colors.white,
      pinned: true,
      expandedHeight: 120.0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        centerTitle: false,
        title: Text(
          widget.asset.assetName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildStatusChip(status['text'] as String),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
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
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(value, style: const TextStyle(fontSize: 14)),
                ),
                if (copyable)
                  InkWell(
                    onTap: () => _copyToClipboard(value, label),
                    child: Icon(Icons.copy, size: 16, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTile({required String title, required String subtitle}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(0.2),
                ),
                child: const Icon(
                  Icons.event_note,
                  color: Colors.blue,
                  size: 16,
                ),
              ),
              Expanded(child: Container(width: 2, color: Colors.grey[300])),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 16.0,
              ), // Espaçamento inferior
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Funções de Detalhes Específicos ---
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
