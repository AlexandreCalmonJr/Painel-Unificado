// File: lib/presentation/shared/widgets/cards/mobile_table_columns.dart
// Helper functions to build table columns for devices

import 'package:flutter/material.dart';
import 'package:painel_windowns/presentation/shared/widgets/cards/managed_assets_card.dart';
import 'package:painel_windowns/services/auth_service.dart';

/// Builds standard device table columns
List<AssetTableColumn<Device>> buildDeviceTableColumns(
  AuthService authService,
) {
  return [
    AssetTableColumn<Device>(
      label: 'Dispositivo',
      builder:
          (device) => InkWell(
            onTap: () {}, // Will be handled by card config
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.smartphone,
                    size: 20,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      device.deviceName ?? 'N/A',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (device.battery != null)
                      Text(
                        'Bateria: ${device.battery}%',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ],
            ),
          ),
      csvBuilder: (device) => device.deviceName ?? 'N/A',
    ),
    AssetTableColumn<Device>(
      label: 'Modelo',
      builder: (device) => Text(device.deviceModel ?? 'N/A'),
      csvBuilder: (device) => device.deviceModel ?? 'N/A',
    ),
    AssetTableColumn<Device>(
      label: 'Serial',
      builder: (device) => Text(device.serialNumber ?? 'N/A'),
      csvBuilder: (device) => device.serialNumber ?? 'N/A',
    ),
    AssetTableColumn<Device>(
      label: 'IMEI',
      builder: (device) => Text(device.imei ?? 'N/A'),
      csvBuilder: (device) => device.imei ?? 'N/A',
    ),
    AssetTableColumn<Device>(
      label: 'Status',
      builder: (device) {
        String statusText;
        Color statusColor;
        switch (device.displayStatus) {
          case DeviceStatusType.collectedByIT:
            statusText = 'Recolhido';
            statusColor = Colors.purple;
            break;
          case DeviceStatusType.maintenance:
            statusText = 'Manutenção';
            statusColor = Colors.orange;
            break;
          case DeviceStatusType.online:
            statusText = 'Online';
            statusColor = Colors.green;
            break;
          case DeviceStatusType.unmonitored:
            statusText = 'Não Monitorado';
            statusColor = Colors.grey;
            break;
          default:
            statusText = 'Offline';
            statusColor = Colors.red;
            break;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
      csvBuilder: (device) {
        switch (device.displayStatus) {
          case DeviceStatusType.collectedByIT:
            return 'Recolhido pelo TI';
          case DeviceStatusType.maintenance:
            return 'Em Manutenção';
          case DeviceStatusType.online:
            return 'Online';
          case DeviceStatusType.unmonitored:
            return 'Sem Monitorar';
          default:
            return 'Offline';
        }
      },
    ),
    AssetTableColumn<Device>(
      label: 'Última Sincronização',
      builder: (device) => Text(formatDateTime(parseLastSeen(device.lastSeen))),
      csvBuilder: (device) => formatDateTime(parseLastSeen(device.lastSeen)),
    ),
    AssetTableColumn<Device>(
      label: 'Unidade',
      builder: (device) => Text(device.unit ?? 'N/D'),
      csvBuilder: (device) => device.unit ?? 'N/A',
    ),
    AssetTableColumn<Device>(
      label: 'Setor/Andar',
      builder:
          (device) =>
              Text('${device.sector ?? "N/D"} / ${device.floor ?? "N/D"}'),
      csvBuilder:
          (device) => '${device.sector ?? "N/A"} / ${device.floor ?? "N/A"}',
    ),
  ];
}

/// Builds device card configuration
AssetCardConfig<Device> buildDeviceCardConfig(
  BuildContext context,
  AuthService authService,
) {
  return AssetCardConfig<Device>(
    csvFileName: 'dispositivos',
    onItemTap: (context, device) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  DeviceDetailScreen(device: device, authService: authService),
        ),
      );
    },
    sortComparator: (a, b) {
      int getPriority(Device device) {
        if (device.displayStatus == DeviceStatusType.unmonitored) return 0;
        return 1;
      }

      final priorityA = getPriority(a);
      final priorityB = getPriority(b);

      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }
      return (a.deviceName ?? '').toLowerCase().compareTo(
        (b.deviceName ?? '').toLowerCase(),
      );
    },
  );
}
