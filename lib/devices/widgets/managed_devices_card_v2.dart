// File: lib/devices/widgets/managed_devices_card_v2.dart
// VERSÃO MIGRADA USANDO WIDGETS BASE REUTILIZÁVEIS

import 'package:flutter/material.dart';
import 'package:painel_windowns/models/device.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/widgets/common/index.dart';
import 'package:painel_windowns/utils/app_constants.dart';
import 'package:painel_windowns/devices/device_detail_screen.dart';

class ManagedDevicesCardV2 extends StatelessWidget {
  final List<Device> devices;
  final AuthService authService;
  final VoidCallback? onRefresh;

  const ManagedDevicesCardV2({
    super.key,
    required this.devices,
    required this.authService,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      title: 'Dispositivos Gerenciados',
      actions: [
        if (onRefresh != null)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRefresh,
            tooltip: 'Atualizar',
          ),
        IconButton(
          icon: const Icon(Icons.file_download),
          onPressed: () => _exportDevices(context),
          tooltip: 'Exportar CSV',
        ),
      ],
      child: BaseDataTable<Device>(
        items: devices,
        columns: [
          DataTableColumn<Device>(
            label: 'Nome',
            builder: (device) => TableCell(
              value: device.deviceName ?? 'Sem nome',
              isClickable: true,
              onTap: () => _navigateToDetails(context, device),
            ),
          ),
          DataTableColumn<Device>(
            label: 'Status',
            builder: (device) => StatusChip(
              status: device.status ?? 'offline',
              type: StatusType.device,
              isCompact: true,
            ),
          ),
          DataTableColumn<Device>(
            label: 'Bateria',
            builder: (device) => BatteryIcon(
              batteryLevel: device.batteryLevel,
              showPercentage: true,
              size: 18,
            ),
          ),
          DataTableColumn<Device>(
            label: 'Localização',
            value: (device) => device.location ?? '-',
          ),
          DataTableColumn<Device>(
            label: 'Serial',
            value: (device) => device.serialNumber ?? '-',
          ),
          DataTableColumn<Device>(
            label: 'Última Atualização',
            value: (device) {
              if (device.lastUpdate == null) return '-';
              final diff = DateTime.now().difference(device.lastUpdate!);
              if (diff.inMinutes < 60) return '${diff.inMinutes}m atrás';
              if (diff.inHours < 24) return '${diff.inHours}h atrás';
              return '${diff.inDays}d atrás';
            },
          ),
        ],
        actions: _buildDeviceActions(),
        showPagination: true,
        pageSize: 10,
      ),
    );
  }

  List<TableAction<Device>> _buildDeviceActions() {
    if (!authService.isAdmin) {
      return [
        TableAction<Device>(
          icon: Icons.visibility,
          label: 'Ver Detalhes',
          onTap: (device) => {}, // Implementar navegação
        ),
      ];
    }

    return [
      TableAction<Device>(
        icon: Icons.edit,
        label: 'Editar',
        onTap: (device) => {}, // Implementar edição
      ),
      TableAction<Device>(
        icon: Icons.build,
        label: 'Manutenção',
        onTap: (device) => {}, // Implementar manutenção
        isVisible: (device) => device.status != 'maintenance',
      ),
      TableAction<Device>(
        icon: Icons.delete,
        label: 'Deletar',
        onTap: (device) => {}, // Implementar deleção
        color: AppColors.danger,
      ),
    ];
  }

  void _navigateToDetails(BuildContext context, Device device) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceDetailScreen(
          device: device,
          authService: authService,
        ),
      ),
    );
  }

  void _exportDevices(BuildContext context) {
    // TODO: Implementar exportação CSV
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exportação em desenvolvimento')),
    );
  }
}
