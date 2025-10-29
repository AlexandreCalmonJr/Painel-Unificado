import 'package:flutter/material.dart';
import 'package:painel_windowns/devices/utils/helpers.dart'; // Assuma que helpers.dart existe com funções como formatDateTime
import 'package:painel_windowns/models/asset_module_base.dart'; // Importe o modelo base
import 'package:painel_windowns/models/desktop.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/module_management_service.dart';

// Temporary extension to provide fetchAssetHistory so the screen compiles.
// Prefer implementing this method inside ModuleManagementService (services/module_management_service.dart)
// with the real API logic; this extension acts as a safe placeholder returning an empty list.
extension ModuleManagementServiceAssetHistory on ModuleManagementService {
  Future<List<Map<String, dynamic>>> fetchAssetHistory(String token, String assetId) async {

    return <Map<String, dynamic>>[];
  }
}

class AssetDetailScreen extends StatefulWidget {
  final ManagedAsset asset;
  final AuthService authService;
  final AssetModuleConfig moduleConfig; // Para contexto do módulo

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
  final ModuleManagementService _moduleService = ModuleManagementService(authService: AuthService()); // Instancie conforme necessário
  late Future<List<Map<String, dynamic>>> _assetHistoryFuture; // Para histórico de manutenção ou similar
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _assetHistoryFuture = _fetchAssetHistory();
  }

  Future<List<Map<String, dynamic>>> _fetchAssetHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final token = widget.authService.currentToken;
      if (token == null || token.isEmpty) {
        print('DEBUG: Token não disponível');
        return [];
      }

      // Assuma que há um método fetchAssetHistory na ModuleManagementService
      // Você precisa implementar isso no service, similar a fetchLocationHistory para devices
      final history = await _moduleService.fetchAssetHistory(token, widget.asset.id);

      print('DEBUG: Histórico recebido: ${history.length} itens');
      return history;
    } catch (e) {
      print('DEBUG: Erro ao buscar histórico do ativo: $e');
      return [];
    } finally {
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  void _refreshAssetHistory() {
    setState(() {
      _assetHistoryFuture = _fetchAssetHistory();
    });
  }

  Map<String, dynamic> _getAssetStatus() {
    String status;
    Color statusColor;
    IconData statusIcon;

    switch (widget.asset.status) {
      case 'online':
        status = 'Online';
        statusColor = Colors.green;
        statusIcon = Icons.cloud_done_outlined;
        break;
      case 'offline':
        status = 'Offline';
        statusColor = Colors.red;
        statusIcon = Icons.cloud_off_outlined;
        break;
      case 'maintenance':
        status = 'Em Manutenção';
        statusColor = Colors.orange;
        statusIcon = Icons.build_outlined;
        break;
      case 'retired':
        status = 'Aposentado';
        statusColor = Colors.purple;
        statusIcon = Icons.archive_outlined;
        break;
      default:
        status = 'Desconhecido';
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
        break;
    }

    return {
      'status': status,
      'color': statusColor,
      'icon': statusIcon,
    };
  }

  @override
  Widget build(BuildContext context) {
    final assetStatus = _getAssetStatus();
    // Implemente o histórico de manutenção similar ao device (use custom_data ou campos específicos)
    final maintenanceHistory = widget.asset.customData['maintenance_history'] as List? ?? [];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshAssetHistory();
        },
        child: CustomScrollView(
          slivers: [
            _buildHeader(context, assetStatus),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionCard(
                      title: 'Informações Gerais',
                      icon: Icons.info_outline,
                      iconColor: Colors.blue,
                      child: Column(
                        children: [
                          _buildDetailRow(Icons.devices, 'Nome', widget.asset.assetName),
                          _buildDetailRow(Icons.qr_code, 'Serial', widget.asset.serialNumber),
                          _buildDetailRow(Icons.type_specimen, 'Tipo', widget.asset.assetType),
                          _buildDetailRow(Icons.location_on, 'Localização', widget.asset.location ?? 'N/A'),
                          _buildDetailRow(Icons.person, 'Atribuído a', widget.asset.assignedTo ?? 'N/A'),
                          // Adicione campos específicos baseados no tipo (ex: para desktop: hostname, etc.)
                          if (widget.asset.assetType == 'desktop') ...[
                            _buildDetailRow(Icons.computer, 'Hostname', (widget.asset as Desktop).hostname), // Cast se necessário
                          ],
                          // Expanda para outros tipos
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: 'Histórico de Manutenção',
                      icon: Icons.history,
                      iconColor: Colors.orange,
                      child: _isLoadingHistory
                          ? const Center(child: CircularProgressIndicator())
                          : FutureBuilder<List<Map<String, dynamic>>>(
                              future: _assetHistoryFuture,
                              builder: (context, snapshot) {
                                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                  return Column(
                                    children: snapshot.data!.map((entry) {
                                      final timestamp = DateTime.parse(entry['timestamp']);
                                      return _buildTimelineTile(
                                        icon: Icons.event_note,
                                        title: entry['status'],
                                        subtitle: '${formatDateTime(timestamp)} - ${entry['reason'] ?? ''}',
                                        color: Colors.blue,
                                      );
                                    }).toList(),
                                  );
                                } else {
                                  return const Text('Nenhum histórico disponível');
                                }
                              },
                            ),
                    ),
                    // Adicione mais seções como hardware, software, etc., baseadas no tipo de ativo
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Funções auxiliares semelhantes ao device_detail_screen.dart
  SliverAppBar _buildHeader(BuildContext context, Map<String, dynamic> status) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(widget.asset.assetName, style: const TextStyle(color: Colors.white)),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [status['color'], status['color'].withOpacity(0.7)],
            ),
          ),
          child: Center(
            child: Icon(status['icon'], size: 80, color: Colors.white.withOpacity(0.8)),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
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
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 16),
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(width: 2, height: 8, color: isFirst ? Colors.transparent : Colors.grey[300]),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.2)),
                child: Icon(icon, color: color, size: 18),
              ),
              Expanded(child: Container(width: 2, color: isLast ? Colors.transparent : Colors.grey[300])),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}