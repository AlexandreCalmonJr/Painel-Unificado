// File: lib/modules/widgets/asset_command_controls_v2.dart
// VERSÃO MIGRADA USANDO BaseCommandMenu

import 'package:flutter/material.dart';
import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/services/module_management_service.dart';
import 'package:painel_windowns/widgets/common/base_command_menu.dart';
import 'package:painel_windowns/widgets/dialogs/base_dialog.dart';
import 'package:painel_windowns/utils/app_constants.dart';

class AssetCommandControlsV2 extends StatelessWidget {
  final ManagedAsset asset;
  final String assetType;
  final String token;
  final VoidCallback? onCommandExecuted;

  const AssetCommandControlsV2({
    super.key,
    required this.asset,
    required this.assetType,
    required this.token,
    this.onCommandExecuted,
  });

  @override
  Widget build(BuildContext context) {
    return BaseCommandMenu<ManagedAsset>(
      item: asset,
      actions: [
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

    final service = ModuleManagementService();
    final result = await service.setAssetMaintenance(
      token: token,
      assetType: assetType,
      assetId: asset.id,
      reason: data['reason'] ?? '',
      ticketNumber: data['ticketNumber'] ?? '',
    );

    if (result['success']) {
      onCommandExecuted?.call();
    } else {
      throw Exception(result['message'] ?? 'Erro ao marcar manutenção');
    }
  }

  Future<void> _returnToProduction(BuildContext context, ManagedAsset asset) async {
    final service = ModuleManagementService();
    final result = await service.returnAssetToProduction(
      token: token,
      assetType: assetType,
      assetId: asset.id,
    );

    if (result['success']) {
      onCommandExecuted?.call();
    } else {
      throw Exception(result['message'] ?? 'Erro ao retornar à produção');
    }
  }

  Future<void> _viewDetails(BuildContext context, ManagedAsset asset) async {
    // Navegação para detalhes já é feita pelo onTap da tabela
    // Este comando pode ser usado em outros contextos
    Navigator.pushNamed(
      context,
      '/asset-details',
      arguments: {'assetId': asset.id, 'assetType': assetType},
    );
  }

  Future<void> _deleteAsset(BuildContext context, ManagedAsset asset) async {
    final service = ModuleManagementService();
    final result = await service.deleteAsset(
      token: token,
      assetType: assetType,
      assetId: asset.id,
    );

    if (result['success']) {
      onCommandExecuted?.call();
    } else {
      throw Exception(result['message'] ?? 'Erro ao deletar ativo');
    }
  }
}
