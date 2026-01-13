// File: lib/presentation/shared/widgets/controls/unified_command_controls.dart
// Unified command controls for devices and assets

import 'package:flutter/material.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/data/models/asset_module_base_model.dart';
import 'package:painel_windowns/data/models/device_model.dart';
import 'package:painel_windowns/presentation/features/modules/widgets/send_command_dialog.dart';
import 'package:painel_windowns/presentation/shared/widgets/dialogs/base_dialog.dart';
import 'package:painel_windowns/presentation/shared/widgets/menus/base_command_menu.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/device_service.dart';
import 'package:painel_windowns/services/module_management_service.dart';

/// Configuration for command actions specific to item type
class CommandConfig<T> {
  const CommandConfig({
    this.moduleId,
    this.getSerialNumber,
    this.getAssetId,
    this.getStatus,
  });

  final String? moduleId;
  final String? Function(T item)? getSerialNumber;
  final String? Function(T item)? getAssetId;
  final String? Function(T item)? getStatus;
}

/// Unified command controls widget for devices and assets
class UnifiedCommandControls<T> extends StatelessWidget {
  const UnifiedCommandControls({
    required this.item,
    required this.authService,
    super.key,
    this.config,
    this.token,
    this.onCommandExecuted,
    this.customActions,
  });

  final T item;
  final AuthService authService;
  final CommandConfig<T>? config;
  final String? token;
  final VoidCallback? onCommandExecuted;
  final List<CommandAction<T>>? customActions;

  @override
  Widget build(BuildContext context) {
    // Build actions based on item type
    final actions = customActions ?? _buildDefaultActions();

    return BaseCommandMenu<T>(item: item, actions: actions);
  }

  List<CommandAction<T>> _buildDefaultActions() {
    // Check if T is Device
    if (T == Device) {
      return _buildDeviceActions() as List<CommandAction<T>>;
    }
    // Check if T is ManagedAsset
    if (T == ManagedAsset) {
      return _buildAssetActions() as List<CommandAction<T>>;
    }
    return [];
  }

  List<CommandAction<Device>> _buildDeviceActions() {
    return [
      CommandAction<Device>(
        label: 'Bloquear Dispositivo',
        icon: Icons.lock,
        onTap: _lockDevice as Future<void> Function(BuildContext, Device),
        color: Colors.orange,
      ),
      CommandAction<Device>(
        label: 'Marcar Manutenção',
        icon: Icons.build,
        onTap:
            _setDeviceMaintenance
                as Future<void> Function(BuildContext, Device),
        isVisible: (device) => !((device.maintenanceStatus) ?? false),
      ),
      CommandAction<Device>(
        label: 'Retornar à Produção',
        icon: Icons.check_circle,
        onTap:
            _returnDeviceToProduction
                as Future<void> Function(BuildContext, Device),
        isVisible: (device) => device.maintenanceStatus == true,
        color: AppColors.success,
      ),
      CommandAction<Device>(
        label: 'Instalar App',
        icon: Icons.download,
        onTap: _installApp as Future<void> Function(BuildContext, Device),
        color: Colors.blue,
      ),
      CommandAction<Device>(
        label: 'Desinstalar App',
        icon: Icons.delete_outline,
        onTap: _uninstallApp as Future<void> Function(BuildContext, Device),
      ),
      CommandAction<Device>(
        label: 'Deletar Dispositivo',
        icon: Icons.delete_forever,
        onTap: _deleteDevice as Future<void> Function(BuildContext, Device),
        requiresConfirmation: true,
        confirmTitle: 'Deletar dispositivo?',
        confirmMessage:
            'Esta ação não pode ser desfeita. O dispositivo será removido permanentemente.',
        isDestructive: true,
        color: AppColors.danger,
      ),
    ];
  }

  List<CommandAction<ManagedAsset>> _buildAssetActions() {
    return [
      CommandAction<ManagedAsset>(
        label: 'Enviar Comando',
        icon: Icons.terminal,
        onTap:
            _sendAssetCommand
                as Future<void> Function(BuildContext, ManagedAsset),
        color: Colors.blue,
      ),
      CommandAction<ManagedAsset>(
        label: 'Marcar Manutenção',
        icon: Icons.build,
        onTap:
            _setAssetMaintenance
                as Future<void> Function(BuildContext, ManagedAsset),
        isVisible: (asset) => asset.status != 'maintenance',
      ),
      CommandAction<ManagedAsset>(
        label: 'Retornar à Produção',
        icon: Icons.check_circle,
        onTap:
            _returnAssetToProduction
                as Future<void> Function(BuildContext, ManagedAsset),
        isVisible: (asset) => asset.status == 'maintenance',
        color: AppColors.success,
      ),
      CommandAction<ManagedAsset>(
        label: 'Deletar Ativo',
        icon: Icons.delete_forever,
        onTap:
            _deleteAsset as Future<void> Function(BuildContext, ManagedAsset),
        requiresConfirmation: true,
        confirmTitle: 'Deletar ativo?',
        confirmMessage:
            'Esta ação não pode ser desfeita. O ativo será removido permanentemente.',
        isDestructive: true,
        color: AppColors.danger,
      ),
    ];
  }

  // Device-specific actions
  Future<void> _lockDevice(BuildContext context, dynamic device) async {
    await _executeDeviceCommand(context, 'lock', {});
  }

  Future<void> _setDeviceMaintenance(
    BuildContext context,
    dynamic device,
  ) async {
    final data = await BaseDialog.form(
      context: context,
      title: 'Marcar Manutenção',
      fields: [
        FormFieldConfig(
          key: 'reason',
          label: 'Motivo',
          hint: 'Descreva o problema...',
        ),
        FormFieldConfig(
          key: 'ticketNumber',
          label: 'Número do Chamado',
          hint: 'Ex: #12345',
        ),
      ],
    );

    if (data == null) return;

    await _executeDeviceCommand(context, 'set_maintenance', {
      'reason': data['reason'],
      'ticket': data['ticketNumber'],
    });
  }

  Future<void> _returnDeviceToProduction(
    BuildContext context,
    dynamic device,
  ) async {
    await _executeDeviceCommand(context, 'return_to_production', {});
  }

  Future<void> _installApp(BuildContext context, dynamic device) async {
    final data = await BaseDialog.form(
      context: context,
      title: 'Instalar Aplicativo',
      fields: [
        FormFieldConfig(
          key: 'packageName',
          label: 'Nome do Pacote',
          hint: 'Ex: com.example.app',
        ),
      ],
    );

    if (data == null) return;

    await _executeDeviceCommand(context, 'install_app', {
      'packageName': data['packageName'],
    });
  }

  Future<void> _uninstallApp(BuildContext context, dynamic device) async {
    final data = await BaseDialog.form(
      context: context,
      title: 'Desinstalar Aplicativo',
      fields: [
        FormFieldConfig(
          key: 'packageName',
          label: 'Nome do Pacote',
          hint: 'Ex: com.example.app',
        ),
      ],
    );

    if (data == null) return;

    await _executeDeviceCommand(context, 'uninstall_app', {
      'packageName': data['packageName'],
    });
  }

  Future<void> _deleteDevice(BuildContext context, dynamic device) async {
    final deviceService = DeviceService();
    final serialNumber =
        config?.getSerialNumber?.call(item as T) ??
        (item as Device).serialNumber;

    if (serialNumber == null || token == null) return;

    try {
      await deviceService.deleteDevice(token!, serialNumber);
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
            content: Text('Erro ao deletar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _executeDeviceCommand(
    BuildContext context,
    String command,
    Map<String, dynamic> parameters,
  ) async {
    final deviceService = DeviceService();
    final serialNumber =
        config?.getSerialNumber?.call(item as T) ??
        (item as Device).serialNumber;

    if (serialNumber == null || token == null) return;

    try {
      await deviceService.sendCommand(
        token!,
        serialNumber,
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

  // Asset-specific actions
  Future<void> _sendAssetCommand(BuildContext context, dynamic asset) async {
    await showDialog<void>(
      context: context,
      builder:
          (context) => SendCommandDialog(
            asset: asset as ManagedAsset,
            moduleId: config?.moduleId ?? '',
            authService: authService,
            onCommandSent: () {
              onCommandExecuted?.call();
            },
          ),
    );
  }

  Future<void> _setAssetMaintenance(BuildContext context, dynamic asset) async {
    final data = await BaseDialog.form(
      context: context,
      title: 'Marcar Manutenção',
      fields: [
        FormFieldConfig(
          key: 'reason',
          label: 'Motivo',
          hint: 'Descreva o problema...',
        ),
        FormFieldConfig(
          key: 'ticketNumber',
          label: 'Número do Chamado',
          hint: 'Ex: #12345',
        ),
      ],
    );

    if (data == null) return;

    final service = ModuleManagementService(authService: authService);
    final assetId =
        config?.getAssetId?.call(item as T) ?? (asset as ManagedAsset).id;

    await service.setMaintenanceMode(
      moduleId: config?.moduleId ?? '',
      assetId: assetId,
      maintenanceMode: true,
      reason: data['reason'] as String? ?? '',
    );

    onCommandExecuted?.call();
  }

  Future<void> _returnAssetToProduction(
    BuildContext context,
    dynamic asset,
  ) async {
    final service = ModuleManagementService(authService: authService);
    final assetId =
        config?.getAssetId?.call(item as T) ?? (asset as ManagedAsset).id;

    await service.setMaintenanceMode(
      moduleId: config?.moduleId ?? '',
      assetId: assetId,
      maintenanceMode: false,
    );

    onCommandExecuted?.call();
  }

  Future<void> _deleteAsset(BuildContext context, dynamic asset) async {
    final service = ModuleManagementService(authService: authService);
    final assetId =
        config?.getAssetId?.call(item as T) ?? (asset as ManagedAsset).id;

    await service.deleteAsset(
      moduleId: config?.moduleId ?? '',
      assetId: assetId,
    );

    onCommandExecuted?.call();
  }
}
