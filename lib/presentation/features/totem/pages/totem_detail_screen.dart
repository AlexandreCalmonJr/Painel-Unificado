import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:painel_windowns/models/totem.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/widgets/common/app_card.dart';

class TotemDetailScreen extends StatelessWidget {
  final Totem totem;
  final AuthService authService;

  const TotemDetailScreen({
    super.key,
    required this.totem,
    required this.authService,
  });

  Map<String, dynamic> _getTotemStatus() {
    String status;
    Color statusColor;
    IconData statusIcon;

    switch (totem.status.toLowerCase()) {
      case 'online':
        status = 'Online';
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'offline':
        status = 'Offline';
        statusColor = Colors.red;
        statusIcon = Icons.error_outline;
        break;
      case 'maintenance':
      case 'com erro':
        status = 'Manutenção';
        statusColor = Colors.orange;
        statusIcon = Icons.build_outlined;
        break;
      default:
        status = totem.status;
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return {'status': status, 'color': statusColor, 'icon': statusIcon};
  }

  @override
  Widget build(BuildContext context) {
    final totemStatus = _getTotemStatus();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          totem.hostname,
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
              color: (totemStatus['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (totemStatus['color'] as Color).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  totemStatus['icon'] as IconData,
                  size: 16,
                  color: totemStatus['color'] as Color,
                ),
                const SizedBox(width: 8),
                Text(
                  totemStatus['status'] as String,
                  style: TextStyle(
                    color: totemStatus['color'] as Color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                      _buildGeneralInfoCard(context),
                      const SizedBox(height: 24),
                      _buildHardwareCard(context),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 3,
                  child: Column(children: [_buildSoftwareCard(context)]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    final minutesSinceLastSeen =
        DateTime.now().difference(totem.lastSeen.toLocal()).inMinutes;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.location_on,
            label: 'Localização',
            value: totem.unit ?? totem.location ?? 'N/A',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.access_time,
            label: 'Última Conexão',
            value: '$minutesSinceLastSeen min atrás',
            color: Colors.purple,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.devices_outlined,
            label: 'Modelo',
            value: totem.model,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.category_outlined,
            label: 'Tipo',
            value: totem.totemType,
            color: Colors.teal,
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
          Expanded(
            child: Column(
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
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralInfoCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle('Informações Gerais', Icons.computer),
          const SizedBox(height: 24),
          _buildSectionTitle('Identificação'),
          _buildDetailRow('Hostname', totem.hostname),
          _buildDetailRow('Unidade', totem.unit ?? totem.location ?? 'N/A'),
          _buildDetailRow('Tipo', totem.totemType),
          _buildDetailRow('Modelo', totem.model),
          const Divider(height: 32),
          _buildSectionTitle('Rede'),
          _buildDetailRow('IP', totem.ip),
          _buildDetailRow('MAC Address', totem.macAddress),
          _buildDetailRow('BSSID', totem.macAddressRadio),
          _buildDetailRow(
            'Última vez visto',
            DateFormat('dd/MM/yyyy HH:mm:ss').format(totem.lastSeen.toLocal()),
          ),
        ],
      ),
    );
  }

  Widget _buildHardwareCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle('Hardware e Periféricos', Icons.memory),
          const SizedBox(height: 24),
          _buildSectionTitle('Especificações'),
          _buildDetailRow('Serial', totem.serialNumber),
          _buildDetailRow('Service Tag', totem.serviceTag),
          _buildDetailRow('Memória RAM', totem.ram),
          _buildDetailRow(
            'Armazenamento',
            '${totem.hdType} ${totem.hdStorage}',
          ),
          const Divider(height: 32),
          _buildSectionTitle('Periféricos'),
          _buildPeripheralStatus(
            'Impressora Zebra',
            totem.zebraStatus,
            Icons.print_outlined,
          ),
          _buildPeripheralStatus(
            'Impressora Bematech',
            totem.bematechStatus,
            Icons.print_outlined,
          ),
          _buildPeripheralStatus(
            'Impressora Padrão',
            totem.printerStatus,
            Icons.print_outlined,
          ),
          _buildPeripheralStatus(
            'Leitor Biométrico',
            totem.biometricReaderStatus,
            Icons.fingerprint,
          ),
        ],
      ),
    );
  }

  Widget _buildSoftwareCard(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTitle('Software Instalado', Icons.apps),
          const SizedBox(height: 24),
          _buildSectionTitle('Versões'),
          _buildDetailRow('Mozilla Firefox', totem.mozillaVersion),
          _buildDetailRow('Java', totem.javaVersion),
          const Divider(height: 32),
          _buildSectionTitle('Programas Instalados'),
          if (totem.installedPrograms.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    Icon(Icons.inbox, color: Colors.grey[300], size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Nenhum programa listado',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            )
          else
            ...totem.installedPrograms.map(
              (program) => _buildProgramItem(program),
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

  Widget _buildPeripheralStatus(String name, String status, IconData icon) {
    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'online':
      case 'ok':
      case 'funcionando':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'offline':
      case 'erro':
      case 'com erro':
        statusColor = Colors.red;
        statusIcon = Icons.error_outline;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramItem(String program) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.apps, color: Colors.blue.shade700, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              program,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
