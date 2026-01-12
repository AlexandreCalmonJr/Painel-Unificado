// File: lib/devices/widgets/command_controls_v2.dart
// VERSÃO MIGRADA USANDO BaseCommandMenu

import 'package:flutter/material.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/data/models/device_model.dart';
import 'package:painel_windowns/presentation/shared/widgets/dialogs/base_dialog.dart';
import 'package:painel_windowns/services/device_service.dart';

class CommandControlsV2 extends StatelessWidget {

  const CommandControlsV2({
    super.key,
    required this.device,
    required this.token,
    this.onCommandExecuted,
  });
  final Device device;
  final String token;
  final VoidCallback? onCommandExecuted;

  @override
  Widget build(BuildContext context) {
    return BaseCommandMenu<Device>(
      item: device,
      actions: [
        CommandAction<Device>(
          label: 'Bloquear Dispositivo',
          icon: Icons.lock,
          onTap: _lockDevice,
          requiresConfirmation: true,
          confirmTitle: 'Bloquear dispositivo?',
          confirmMessage: 'O dispositivo ${device.deviceName} será bloqueado.',
        ),
        CommandAction<Device>(
          label: 'Marcar Manutenção',
          icon: Icons.build,
          onTap: _setMaintenance,
          isVisible: (device) => device.status != 'maintenance',
        ),
        CommandAction<Device>(
          label: 'Retornar à Produção',
          icon: Icons.check_circle,
          onTap: _returnToProduction,
          isVisible: (device) => device.status == 'maintenance',
          color: AppColors.success,
        ),
        CommandAction<Device>(
          label: 'Instalar Aplicativo',
          icon: Icons.download,
          onTap: _installApp,
        ),
        CommandAction<Device>(
          label: 'Desinstalar Aplicativo',
          icon: Icons.delete_outline,
          onTap: _uninstallApp,
        ),
        CommandAction<Device>(
          label: 'Deletar Dispositivo',
          icon: Icons.delete_forever,
          onTap: _deleteDevice,
          requiresConfirmation: true,
          confirmTitle: 'Deletar dispositivo?',
          confirmMessage:
              'Esta ação não pode ser desfeita. O dispositivo ${device.deviceName} será removido permanentemente.',
          isDestructive: true,
          color: AppColors.danger,
        ),
      ],
    );
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

    await _executeCommand(context, 'uninstall_app', {'packageName': packageName});
  }

  Future<void> _deleteDevice(BuildContext context, Device device) async {
    final service = DeviceService();
    // O serviço retorna uma String com a mensagem de sucesso ou lança exceção
    await service.deleteDevice(token, device.serialNumber!);
    onCommandExecuted?.call();
  }

  Future<void> _executeCommand(
    BuildContext context,
    String command,
    Map<String, dynamic> parameters,
  ) async {
    final service = DeviceService();
    // O serviço retorna uma String com a mensagem de sucesso ou lança exceção
    await service.sendCommand(
      token,
      device.serialNumber!,
      command,
      parameters,
    );
    onCommandExecuted?.call();
  }
}
