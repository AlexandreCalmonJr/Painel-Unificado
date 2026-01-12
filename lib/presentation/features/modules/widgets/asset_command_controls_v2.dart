// File: lib/modules/widgets/asset_command_controls_v2.dart
// VERSÃO MIGRADA USANDO BaseCommandMenu

import 'package:flutter/material.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/data/models/asset_module_base_model.dart';
import 'package:painel_windowns/presentation/features/modules/widgets/send_command_dialog.dart';
import 'package:painel_windowns/presentation/shared/widgets/dialogs/base_dialog.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/module_management_service.dart';


class AssetCommandControlsV2 extends StatelessWidget {

  const AssetCommandControlsV2({
    super.key,
    required this.asset,
    required this.assetType,
    required this.token,
    required this.authService, // ✅ Adicionado
    this.onCommandExecuted,
  });
  final ManagedAsset asset;
  final String assetType;
  final String token;
  final AuthService authService; // ✅ Adicionado
  final VoidCallback? onCommandExecuted;

  @override
  Widget build(BuildContext context) {
    return BaseCommandMenu<ManagedAsset>(
      item: asset,
      actions: [
        CommandAction<ManagedAsset>(
          label: 'Enviar Comando',
          icon: Icons.terminal,
          onTap: _sendCommand,
          color: Colors.blue,
        ),
        CommandAction<ManagedAsset>(
          label: 'Marcar Manutenção',
          icon: Icons.build,
          onTap: _setMaintenance,
          isVisible: (asset) => asset.status != 'maintenance',
        ),
        CommandAction<ManagedAsset>(
          label: 'Retornar à Produção',
          icon: Icons.check_circle,
          onTap: _returnToProduction,
          isVisible: (asset) => asset.status == 'maintenance',
          color: AppColors.success,
        ),
        CommandAction<ManagedAsset>(
          label: 'Ver Detalhes',
          icon: Icons.visibility,
          onTap: _viewDetails,
        ),
        CommandAction<ManagedAsset>(
          label: 'Deletar Ativo',
          icon: Icons.delete_forever,
          onTap: _deleteAsset,
          requiresConfirmation: true,
          confirmTitle: 'Deletar ativo?',
          confirmMessage:
              'Esta ação não pode ser desfeita. O ativo será removido permanentemente.',
          isDestructive: true,
          color: AppColors.danger,
        ),
      ],
    );
  }

  Future<void> _sendCommand(BuildContext context, ManagedAsset asset) async {
    await showDialog(
      context: context,
      builder:
          (context) => SendCommandDialog(
            asset: asset,
            moduleId: assetType,
            authService: authService,
            onCommandSent: () {
              onCommandExecuted?.call();
            },
          ),
    );
  }

  Future<void> _setMaintenance(BuildContext context, ManagedAsset asset) async {
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
    // ✅ CORREÇÃO: Usando setMaintenanceMode com argumentos corretos
    await service.setMaintenanceMode(
      moduleId: assetType,
      assetId: asset.id,
      maintenanceMode: true,
      reason: data['reason'] ?? '',
    );

    onCommandExecuted?.call();
  }

  Future<void> _returnToProduction(
    BuildContext context,
    ManagedAsset asset,
  ) async {
    final service = ModuleManagementService(authService: authService);
    // ✅ CORREÇÃO: Usando setMaintenanceMode com maintenanceMode: false
    await service.setMaintenanceMode(
      moduleId: assetType,
      assetId: asset.id,
      maintenanceMode: false,
    );

    onCommandExecuted?.call();
  }

  Future<void> _viewDetails(BuildContext context, ManagedAsset asset) async {
    Navigator.pushNamed(
      context,
      '/asset-details',
      arguments: {'assetId': asset.id, 'assetType': assetType},
    );
  }

  Future<void> _deleteAsset(BuildContext context, ManagedAsset asset) async {
    final service = ModuleManagementService(authService: authService);
    // ✅ CORREÇÃO: Usando deleteAsset com argumentos corretos e sem token
    await service.deleteAsset(moduleId: assetType, assetId: asset.id);

    onCommandExecuted?.call();
  }
}
