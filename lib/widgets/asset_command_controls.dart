// Crie um novo widget: lib/widgets/asset_command_controls.dart
// Adaptado de command_controls.dart para ativos. Ações como update status, delete, etc.
// As ações chamam métodos da ModuleManagementService (ex: updateAsset, deleteAsset).

import 'package:flutter/material.dart';
import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/module_management_service.dart';

enum AssetAction {
  setMaintenance,
  returnToProduction,
  delete,
  // Adicione mais ações específicas para ativos, ex: reboot, updateSoftware
}

class AssetCommandControls extends StatelessWidget {
  final ManagedAsset asset;
  final String moduleId;
  final AuthService authService;
  final VoidCallback onCommandExecuted;

  const AssetCommandControls({
    super.key,
    required this.asset,
    required this.moduleId,
    required this.authService,
    required this.onCommandExecuted,
  });

  void _handleAction(BuildContext context, AssetAction action) {
    final service = ModuleManagementService(authService: authService);

    switch (action) {
      case AssetAction.setMaintenance:
        // Similar ao _showMaintenanceDialog em command_controls
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Marcar para Manutenção'),
            content: TextField(
              decoration: const InputDecoration(labelText: 'Motivo/Chamado'),
              onSubmitted: (value) async {
                await service.updateAsset(moduleId: moduleId, assetId: asset.id, updateData: {
                  'status': 'maintenance',
                  'custom_data': {'maintenance_reason': value},
                });
                onCommandExecuted();
                Navigator.pop(ctx);
              },
            ),
          ),
        );
        break;
      case AssetAction.returnToProduction:
        // Confirmação similar
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Retornar à Produção?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
              TextButton(
                onPressed: () async {
                  await service.updateAsset(moduleId: moduleId, assetId: asset.id, updateData: {'status': 'online'});
                  onCommandExecuted();
                  Navigator.pop(ctx);
                },
                child: const Text('Confirmar'),
              ),
            ],
          ),
        );
        break;
      case AssetAction.delete:
        // Similar ao delete em command_controls
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Excluir Ativo?'),
            content: const Text('Esta ação é irreversível.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
              TextButton(
                onPressed: () async {
                  await service.deleteAsset(moduleId: moduleId, assetId: asset.id);
                  onCommandExecuted();
                  Navigator.pop(ctx);
                },
                child: const Text('Excluir', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AssetAction>(
      onSelected: (action) => _handleAction(context, action),
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem<AssetAction>(
            value: AssetAction.setMaintenance,
            child: ListTile(leading: Icon(Icons.build_outlined), title: Text('Manutenção')),
          ),
          const PopupMenuItem<AssetAction>(
            value: AssetAction.returnToProduction,
            child: ListTile(leading: Icon(Icons.check_circle_outline, color: Colors.green), title: Text('Retornar à Produção')),
          ),
          const PopupMenuItem<AssetAction>(
            value: AssetAction.delete,
            child: ListTile(leading: Icon(Icons.delete_forever_outlined, color: Colors.red), title: Text('Excluir', style: TextStyle(color: Colors.red))),
          ),
          // Adicione mais itens conforme necessário
        ];
      },
    );
  }
}