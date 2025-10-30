import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:painel_windowns/models/totem.dart';
import 'package:painel_windowns/services/auth_service.dart';

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
        statusIcon = Icons.cloud_done_outlined;
        break;
      case 'offline':
        status = 'Offline';
        statusColor = Colors.red;
        statusIcon = Icons.cloud_off_outlined;
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

    return {
      'status': status,
      'color': statusColor,
      'icon': statusIcon,
    };
  }

  @override
  Widget build(BuildContext context) {
    final totemStatus = _getTotemStatus();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          _buildHeader(context, totemStatus),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildQuickStats(),
                  const SizedBox(height: 16),
                  _buildGeneralInfoCard(context),
                  const SizedBox(height: 16),
                  _buildHardwareCard(context),
                  const SizedBox(height: 16),
                  _buildSoftwareCard(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildHeader(
      BuildContext context, Map<String, dynamic> totemStatus) {
    final headerColor = totemStatus['color'] as Color;
    final headerIcon = totemStatus['icon'] as IconData;
    final status = totemStatus['status'] as String;

    return SliverAppBar(
      backgroundColor: headerColor,
      foregroundColor: Colors.white,
      pinned: true,
      expandedHeight: 120.0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        centerTitle: false,
        title: Text(
          totem.hostname,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        background: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(status,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Icon(headerIcon, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    DateFormat('dd/MM/yyyy HH:mm:ss')
        .format(totem.lastSeen.toLocal());
    final minutesSinceLastSeen = 
        DateTime.now().difference(totem.lastSeen.toLocal()).inMinutes;

    return Row(
      children: [
        Expanded(
          child: _buildSmallInfoCard(
            icon: Icons.location_on,
            label: 'Localização',
            value: totem.unit ?? totem.location ?? 'N/A',
            iconColor: Colors.blue.shade600,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSmallInfoCard(
            icon: Icons.access_time,
            label: 'Última Conexão',
            value: '$minutesSinceLastSeen min',
            iconColor: Colors.purple.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralInfoCard(BuildContext context) {
    return _buildSectionCard(
      title: 'Informações Gerais',
      icon: Icons.computer,
      iconColor: Colors.blue.shade700,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Identificação'),
          _buildDetailRow(
            Icons.dns_outlined,
            'Hostname:',
            totem.hostname,
          ),
          _buildDetailRow(
            Icons.business_outlined,
            'Unidade/Localização:',
            totem.unit ?? totem.location ?? 'N/A',
          ),
          _buildDetailRow(
            Icons.category_outlined,
            'Tipo de Totem:',
            totem.totemType,
          ),
          _buildDetailRow(
            Icons.devices_outlined,
            'Modelo:',
            totem.model,
          ),
          _buildSectionTitle('Rede'),
          _buildDetailRow(
            Icons.lan_outlined,
            'Endereço IP:',
            totem.ip,
          ),
          _buildDetailRow(
            Icons.schedule,
            'Última vez visto:',
            DateFormat('dd/MM/yyyy HH:mm:ss').format(totem.lastSeen.toLocal()),
          ),
        ],
      ),
    );
  }

  Widget _buildHardwareCard(BuildContext context) {
    return _buildSectionCard(
      title: 'Hardware e Periféricos',
      icon: Icons.memory,
      iconColor: Colors.green.shade700,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Especificações'),
          _buildDetailRow(
            Icons.qr_code_scanner,
            'Número de Série:',
            totem.serialNumber,
          ),
          _buildDetailRow(
            Icons.confirmation_number_outlined,
            'Service Tag:',
            totem.serviceTag,
          ),
          _buildDetailRow(
            Icons.memory_outlined,
            'Memória RAM:',
            totem.ram,
          ),
          _buildDetailRow(
            Icons.storage_outlined,
            'Tipo de Armazenamento:',
            totem.hdType,
          ),
          _buildDetailRow(
            Icons.sd_storage_outlined,
            'Capacidade:',
            totem.hdStorage,
          ),
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
    return _buildSectionCard(
      title: 'Software Instalado',
      icon: Icons.apps,
      iconColor: Colors.orange.shade700,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Versões de Software'),
          _buildDetailRow(
            Icons.web,
            'Mozilla Firefox:',
            totem.mozillaVersion,
          ),
          _buildDetailRow(
            Icons.code,
            'Java:',
            totem.javaVersion,
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('Programas Instalados'),
          if (totem.installedPrograms.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    Icon(Icons.inbox, color: Colors.grey[400], size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'Nenhum programa listado',
                      style: TextStyle(color: Colors.grey[600]),
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

  Widget _buildSmallInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black.withOpacity(0.7),
          letterSpacing: 0.8,
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
            width: 140,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
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
            child: Icon(
              Icons.apps,
              color: Colors.blue.shade700,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              program,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}