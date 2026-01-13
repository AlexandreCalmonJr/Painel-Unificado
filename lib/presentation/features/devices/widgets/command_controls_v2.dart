// File: lib/presentation/features/devices/widgets/command_controls_v2.dart
// Command controls using PopupMenuButton

import 'package:flutter/material.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/data/models/device_model.dart';
import 'package:painel_windowns/presentation/shared/widgets/dialogs/base_dialog.dart';
import 'package:painel_windowns/services/device_service.dart';

class CommandControlsV2 extends StatelessWidget {
  const CommandControlsV2({
    required this.device, required this.token, super.key,
    this.onCommandExecuted,
  });
  final Device device;
  final String token;
  final VoidCallback? onCommandExecuted;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'Ações do dispositivo',
      onSelected: (value) async {
        switch (value) {
          case 'lock':
            final confirmed = await _showConfirmDialog(
              context,
              'Bloquear dispositivo?',
              'O dispositivo ${device.deviceName} será bloqueado.',
            );
            if (confirmed) await _lockDevice(context, device);
            break;
          case 'maintenance':
            await _setMaintenance(context, device);
            break;
          case 'production':
            await _returnToProduction(context, device);
            break;
          case 'install':
            await _installApp(context, device);
            break;
          case 'uninstall':
            await _uninstallApp(context, device);
            break;
          case 'delete':
            final confirmed = await _showConfirmDialog(
              context,
              'Deletar dispositivo?',
              'Esta ação não pode ser desfeita. O dispositivo ${device.deviceName} será removido permanentemente.',
              isDestructive: true,
            );
            if (confirmed) await _deleteDevice(context, device);
            break;
        }
      },
      itemBuilder:
          (context) => [
            const PopupMenuItem(
              value: 'lock',
              child: Row(
                children: [
                  Icon(Icons.lock, size: 18),
                  SizedBox(width: 12),
                  Text('Bloquear Dispositivo'),
                ],
              ),
            ),
            if (device.status != 'maintenance')
              const PopupMenuItem(
                value: 'maintenance',
                child: Row(
                  children: [
                    Icon(Icons.build, size: 18),
                    SizedBox(width: 12),
                    Text('Marcar Manutenção'),
                  ],
                ),
              ),
            if (device.status == 'maintenance')
              const PopupMenuItem(
                value: 'production',
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 18,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Retornar à Produção',
                      style: TextStyle(color: AppColors.success),
                    ),
                  ],
                ),
              ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'install',
              child: Row(
                children: [
                  Icon(Icons.download, size: 18),
                  SizedBox(width: 12),
                  Text('Instalar Aplicativo'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'uninstall',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 18),
                  SizedBox(width: 12),
                  Text('Desinstalar Aplicativo'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_forever, size: 18, color: AppColors.danger),
                  SizedBox(width: 12),
                  Text(
                    'Deletar Dispositivo',
                    style: TextStyle(color: AppColors.danger),
                  ),
                ],
              ),
            ),
          ],
    );
  }

  Future<bool> _showConfirmDialog(
    BuildContext context,
    String title,
    String message, {
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDestructive ? AppColors.danger : null,
                  foregroundColor: isDestructive ? Colors.white : null,
                ),
                child: const Text('Confirmar'),
              ),
            ],
          ),
    );
    return result ?? false;
  }

  Future<void> _lockDevice(BuildContext context, Device device) async {
    await _executeCommand(context, 'lock_device', {});
  }

  Future<void> _setMaintenance(BuildContext context, Device device) async {
    final reason = await BaseDialog.input(
      context: context,
      title: 'Motivo da Manutenção',
      label: 'Descreva o motivo',
      hint: 'Ex: Tela quebrada, bateria com problema...',
    );

    if (reason == null || reason.isEmpty) return;

    await _executeCommand(context, 'set_maintenance', {
      'reason': reason,
      'ticketNumber': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

  Future<void> _returnToProduction(BuildContext context, Device device) async {
    await _executeCommand(context, 'return_to_production', {});
  }

  Future<void> _installApp(BuildContext context, Device device) async {
    final url = await BaseDialog.input(
      context: context,
      title: 'Instalar Aplicativo',
      label: 'URL do APK',
      hint: 'https://example.com/app.apk',
    );

    if (url == null || url.isEmpty) return;

    await _executeCommand(context, 'install_app', {'url': url});
  }

  Future<void> _uninstallApp(BuildContext context, Device device) async {
    final packageName = await BaseDialog.input(
      context: context,
      title: 'Desinstalar Aplicativo',
      label: 'Nome do Pacote',
      hint: 'com.example.app',
    );

    if (packageName == null || packageName.isEmpty) return;

    await _executeCommand(context, 'uninstall_app', {
      'packageName': packageName,
    });
  }

  Future<void> _deleteDevice(BuildContext context, Device device) async {
    final service = DeviceService();
    try {
      await service.deleteDevice(token, device.serialNumber!);
      onCommandExecuted?.call();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dispositivo deletado com sucesso')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao deletar dispositivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _executeCommand(
    BuildContext context,
    String command,
    Map<String, dynamic> parameters,
  ) async {
    final service = DeviceService();
    try {
      await service.sendCommand(
        token,
        device.serialNumber!,
        command,
        parameters,
      );
      onCommandExecuted?.call();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comando executado com sucesso')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao executar comando: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
