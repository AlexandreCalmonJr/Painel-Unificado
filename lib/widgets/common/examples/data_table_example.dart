// File: lib/widgets/common/examples/data_table_example.dart
// Exemplo de uso do BaseDataTable

import 'package:flutter/material.dart';
import 'package:painel_windowns/models/device.dart';
import 'package:painel_windowns/widgets/common/index.dart';
import 'package:painel_windowns/utils/app_constants.dart';

class DeviceTableExample extends StatelessWidget {
  final List<Device> devices;
  final Function(Device) onDeviceSelected;
  final Function(Device) onEditDevice;
  final Function(Device) onDeleteDevice;

  const DeviceTableExample({
    super.key,
    required this.devices,
    required this.onDeviceSelected,
    required this.onEditDevice,
    required this.onDeleteDevice,
  });

  @override
  Widget build(BuildContext context) {
    return BaseDataTable<Device>(
      items: devices,
      columns: [
        DataTableColumn<Device>(
          label: 'Nome',
          builder:
              (device) => DataTableCellWidget(
                value: device.deviceName,
                isClickable: true,
                onTap: () => onDeviceSelected(device),
              ),
        ),
        DataTableColumn<Device>(
          label: 'Status',
          builder:
              (device) =>
                  StatusChip(status: device.status, type: StatusType.device),
        ),
        DataTableColumn<Device>(
          label: 'Bateria',
          builder:
              (device) => BatteryIcon(
                batteryLevel: device.battery,
                showPercentage: true,
              ),
        ),
        DataTableColumn<Device>(
          label: 'Localização',
          value:
              (device) => '${device.unit ?? 'N/D'} - ${device.sector ?? 'N/D'}',
        ),
        DataTableColumn<Device>(
          label: 'Última Sincronização',
          value: (device) => device.lastSeen ?? '-',
        ),
      ],
      actions: [
        TableAction<Device>(
          icon: Icons.edit,
          label: 'Editar',
          onTap: onEditDevice,
        ),
        TableAction<Device>(
          icon: Icons.delete,
          label: 'Deletar',
          onTap: onDeleteDevice,
          color: AppColors.danger,
        ),
      ],
      showPagination: true,
      pageSize: 10,
    );
  }
}
