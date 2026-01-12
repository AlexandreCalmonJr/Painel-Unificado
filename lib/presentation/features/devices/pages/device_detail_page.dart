import 'package:flutter/material.dart';
import 'package:painel_windowns/core/utils/helpers.dart';
import 'package:painel_windowns/data/models/device_model.dart';
import 'package:painel_windowns/presentation/shared/widgets/cards/app_card.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/device_service.dart';


class DeviceDetailScreen extends StatefulWidget {

  const DeviceDetailScreen({
    super.key,
    required this.device,
    required this.authService,
  });
  final Device device;
  final AuthService authService;

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  final DeviceService _deviceService = DeviceService();
  late Future<List<Map<String, dynamic>>> _locationHistoryFuture;
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _locationHistoryFuture = _fetchLocationHistory();
  }

  Future<List<Map<String, dynamic>>> _fetchLocationHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });

    try {
      final token = widget.authService.currentToken;

      if (token == null || token.isEmpty) {
        return [];
      }

      final String? serialNumber = widget.device.serialNumber;

      if (serialNumber == null || serialNumber.isEmpty) {
        return [];
      }

      final history = await _deviceService.fetchLocationHistory(
        token,
        serialNumber,
      );

      return history;
    } catch (e) {
      print('DEBUG: ERRO FATAL ao buscar histórico de localização: $e');
      return [];
    } finally {
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  void _refreshLocationHistory() {
    setState(() {
      _locationHistoryFuture = _fetchLocationHistory();
    });
  }

  Map<String, dynamic> _getDeviceStatus() {
    String status;
    Color statusColor;
    IconData statusIcon;

    switch (widget.device.displayStatus) {
      case DeviceStatusType.online:
        status = 'Online';
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        break;
      case DeviceStatusType.offline:
        status = 'Offline';
        statusColor = Colors.red;
        statusIcon = Icons.error_outline;
        break;
      case DeviceStatusType.maintenance:
        status = 'Em Manutenção';
        statusColor = Colors.orange;
        statusIcon = Icons.build_outlined;
        break;
      case DeviceStatusType.collectedByIT:
        status = 'Recolhido pelo TI';
        statusColor = Colors.purple;
        statusIcon = Icons.inventory_2_outlined;
        break;
      case DeviceStatusType.unmonitored:
        status = 'Sem Monitorar';
        statusColor = Colors.grey;
        statusIcon = Icons.visibility_off_outlined;
        break;
    }

    return {'status': status, 'color': statusColor, 'icon': statusIcon};
  }

  @override
  Widget build(BuildContext context) {
    final maintenanceHistory = widget.device.maintenanceHistory ?? [];
    final deviceStatus = _getDeviceStatus();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.device.deviceName ?? 'Detalhes do Dispositivo',
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
              color: (deviceStatus['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (deviceStatus['color'] as Color).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  deviceStatus['icon'] as IconData,
                  size: 16,
                  color: deviceStatus['color'] as Color,
                ),
                const SizedBox(width: 8),
                Text(
                  deviceStatus['status'] as String,
                  style: TextStyle(
                    color: deviceStatus['color'] as Color,
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
        onRefresh: () async {
          _refreshLocationHistory();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuickStats(),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildDetailedInfoCard(context),
                        const SizedBox(height: 24),
                        if (widget.device.maintenanceStatus ?? false)
                          _buildMaintenanceStatusCard(context),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _buildLocationHistoryCard(context),
                        const SizedBox(height: 24),
                        _buildMaintenanceHistoryCard(
                          context,
                          maintenanceHistory,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaintenanceStatusCard(BuildContext context) {
    final maintenanceReason = widget.device.maintenanceReason ?? '';
    final isCollectedByIT = maintenanceReason == 'collected_by_it';
    final statusText = isCollectedByIT ? 'Recolhido pelo TI' : 'Em Manutenção';
    final statusColor = isCollectedByIT ? Colors.purple : Colors.orange;
    final statusIcon =
        isCollectedByIT ? Icons.inventory_2_outlined : Icons.build_outlined;

    return AppCard(
      border: Border.all(color: statusColor.withOpacity(0.3)),
      backgroundColor: statusColor.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 24),
              const SizedBox(width: 12),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
          if (widget.device.maintenanceTicket?.isNotEmpty ?? false) ...[
            const SizedBox(height: 16),
            _buildMaintenanceDetail(
              isCollectedByIT
                  ? 'Motivo do Recolhimento:'
                  : 'Número do Chamado:',
              widget.device.maintenanceTicket!,
              statusColor,
            ),
          ],
          if (maintenanceReason.isNotEmpty &&
              maintenanceReason != 'collected_by_it' &&
              maintenanceReason != 'maintenance') ...[
            const SizedBox(height: 8),
            _buildMaintenanceDetail(
              'Motivo Adicional:',
              maintenanceReason,
              statusColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMaintenanceDetail(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, color: color)),
      ],
    );
  }

  Widget _buildQuickStats() {
    final lastSeenTime = parseLastSeen(widget.device.lastSeen);
    final minutesSinceSync =
        lastSeenTime != null
            ? DateTime.now().difference(lastSeenTime).inMinutes
            : null;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.battery_charging_full,
            label: 'Bateria',
            value: '${widget.device.battery?.toInt() ?? 'N/A'}%',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.sync,
            label: 'Último Sync',
            value:
                minutesSinceSync != null
                    ? '$minutesSinceSync min atrás'
                    : 'N/A',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.wifi,
            label: 'Rede',
            value: widget.device.network ?? 'N/A',
            color: Colors.purple,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.storage,
            label: 'Modelo',
            value: widget.device.deviceModel ?? 'N/A',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedInfoCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle('Informações do Dispositivo', Icons.info_outline),
          const SizedBox(height: 24),
          _buildSectionTitle('Identificação'),
          _buildDetailRow('Serial', widget.device.serialNumber ?? 'N/A'),
          _buildDetailRow('IMEI', widget.device.imei ?? 'N/A'),
          _buildDetailRow('ID Interno', widget.device.deviceId ?? 'N/A'),
          const Divider(height: 32),
          _buildSectionTitle('Localização'),
          _buildDetailRow('Unidade', widget.device.unit ?? 'N/A'),
          _buildDetailRow('Setor', widget.device.sector ?? 'Desconhecido'),
          _buildDetailRow('Andar', widget.device.floor ?? 'Desconhecido'),
          const Divider(height: 32),
          _buildSectionTitle('Rede & Conexão'),
          _buildDetailRow('IP', widget.device.ipAddress ?? 'N/A'),
          _buildDetailRow('MAC', widget.device.macAddress ?? 'N/A'),
          _buildDetailRow('BSSID', widget.device.macAddressRadio ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildLocationHistoryCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCardTitle(
                'Histórico de Localização',
                Icons.location_on_outlined,
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: _refreshLocationHistory,
                tooltip: 'Atualizar histórico',
                color: Colors.grey[600],
              ),
            ],
          ),
          const SizedBox(height: 24),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _locationHistoryFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  _isLoadingHistory) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Erro ao carregar: ${snapshot.error}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.location_off_outlined,
                          color: Colors.grey[300],
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Nenhum histórico encontrado',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final history = snapshot.data!;

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final entry = history[index];
                  final sector = entry['sector']?.toString() ?? 'N/A';
                  final floor = entry['floor']?.toString() ?? 'N/A';
                  final location = '$sector - $floor';
                  final timestamp = entry['timestamp']?.toString() ?? '';

                  return _buildTimelineTile(
                    title: location,
                    subtitle: formatDateTime(parseLastSeen(timestamp)),
                    isFirst: index == 0,
                    isLast: index == history.length - 1,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceHistoryCard(
    BuildContext context,
    List<Map<String, dynamic>> history,
  ) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle('Histórico de Manutenção', Icons.history),
          const SizedBox(height: 24),
          history.isEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.assignment_turned_in_outlined,
                        color: Colors.grey[300],
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nenhum registro de manutenção',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              )
              : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final entry = history[index];
                  final date = parseLastSeen(entry['timestamp']);
                  final entryStatus = entry['status']?.toString() ?? '';
                  final ticket =
                      entry['ticket'] != null
                          ? " • Chamado: ${entry['ticket']}"
                          : '';
                  final reason =
                      entry['reason'] != null
                          ? "\nMotivo: ${entry['reason']}"
                          : '';

                  String displayStatus;
                  Color displayColor;

                  switch (entryStatus) {
                    case 'entered_maintenance':
                      displayStatus = 'Entrou em manutenção';
                      displayColor = Colors.orange;
                      break;
                    case 'returned_to_production':
                      displayStatus = 'Retornou à produção';
                      displayColor = Colors.green;
                      break;
                    case 'collected_by_it':
                      displayStatus = 'Recolhido pelo TI';
                      displayColor = Colors.purple;
                      break;
                    default:
                      displayStatus = entryStatus;
                      displayColor = Colors.grey;
                  }

                  return _buildTimelineTile(
                    title: displayStatus,
                    subtitle: '${formatDateTime(date)}$ticket$reason',
                    color: displayColor,
                    isFirst: index == 0,
                    isLast: index == history.length - 1,
                  );
                },
              ),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey[500],
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTile({
    required String title,
    required String subtitle,
    Color color = Colors.blue,
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
                    border: Border.all(color: color, width: 2),
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
}
