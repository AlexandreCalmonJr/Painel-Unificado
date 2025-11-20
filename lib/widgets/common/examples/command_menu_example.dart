// File: lib/widgets/common/examples/command_menu_example.dart
// Exemplo de uso do BaseCommandMenu

import 'package:flutter/material.dart';
import 'package:painel_windowns/models/device.dart';
import 'package:painel_windowns/widgets/common/base_command_menu.dart';
import 'package:painel_windowns/utils/app_constants.dart';

class DeviceCommandMenuExample extends StatelessWidget {
  final Device device;
  final Function(Device) onLock;
  final Function(Device, String) onSetMaintenance;
  final Function(Device) onDelete;

  const DeviceCommandMenuExample({
    super.key,
    required this.device,
    required this.onLock,
    required this.onSetMaintenance,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCommandMenu<Device>(
      item: device,
      actions: [
        CommandAction<Device>(
          label: 'Bloquear Dispositivo',
          icon: Icons.lock,
          onTap: (context, device) async {
            onLock(device);
          },
          requiresConfirmation: true,
          confirmTitle: 'Bloquear dispositivo?',
          confirmMessage: 'O dispositivo ${device.deviceName} será bloqueado.',
        ),
        CommandAction<Device>(
          label: 'Marcar Manutenção',
          icon: Icons.build,
          onTap: (context, device) async {
            // Aqui você pode usar BaseDialog.input para pedir o motivo
            onSetMaintenance(device, 'Manutenção programada');
          },
          isVisible: (device) => device.status != 'maintenance',
        ),
        CommandAction<Device>(
          label: 'Deletar',
          icon: Icons.delete,
          onTap: (context, device) async {
            onDelete(device);
          },
          requiresConfirmation: true,
          confirmTitle: 'Deletar dispositivo?',
          confirmMessage: 'Esta ação não pode ser desfeita.',
          isDestructive: true,
          color: AppColors.danger,
        ),
      ],
    );
  }
}
