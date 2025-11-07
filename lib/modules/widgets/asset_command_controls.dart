// File: lib/widgets/asset_command_controls.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/module_management_service.dart';

enum AssetAction {
  setMaintenance,
  returnToProduction,
  delete,
  viewDetails,
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
        _showMaintenanceDialog(context, service);
        break;

      case AssetAction.returnToProduction:
        _showReturnToProductionDialog(context, service);
        break;

      case AssetAction.delete:
        _showDeleteDialog(context, service);
        break;

      case AssetAction.viewDetails:
        // Implementar visualização de detalhes
        break;
    }
  }

  /// Diálogo para marcar manutenção
  void _showMaintenanceDialog(
      BuildContext context, ModuleManagementService service) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.build_outlined,
                  color: Colors.orange, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Marcar para Manutenção'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ativo: ${asset.assetName}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'Motivo/Chamado',
                hintText: 'Ex: Chamado #12345 - Manutenção preventiva',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = reasonController.text.trim();

              Navigator.pop(ctx);

              // Mostra loading
              _showLoadingDialog(context);

              try {
                final result = await service.setMaintenanceMode(
                  moduleId: moduleId,
                  assetId: asset.id,
                  maintenanceMode: true,
                  reason: reason.isNotEmpty ? reason : null,
                );
                // Fecha loading
                if (context.mounted) Navigator.pop(context);
                // Mostra resultado
                if (context.mounted) _showResultSnackbar(context, result);

                if (result['success'] == true) {
                  onCommandExecuted();
                }
              } catch (e) {
                // Fecha loading em caso de erro
                if (context.mounted) Navigator.pop(context);
                if (context.mounted) {
                  _showResultSnackbar(context, {
                    'success': false,
                    'message': 'Erro: ${e.toString()}'
                  });
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  /// Diálogo para retornar à produção
  void _showReturnToProductionDialog(
      BuildContext context, ModuleManagementService service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check_circle_outline,
                  color: Colors.green, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Retornar à Produção'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deseja retornar o ativo à produção?',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.devices, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      asset.assetName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);

              // Mostra loading
              _showLoadingDialog(context);
              try {
                final result = await service.setMaintenanceMode(
                  moduleId: moduleId,
                  assetId: asset.id,
                  maintenanceMode: false,
                );

                // Fecha loading
                if (context.mounted) Navigator.pop(context);
                // Mostra resultado
                if (context.mounted) _showResultSnackbar(context, result);

                if (result['success'] == true) {
                  onCommandExecuted();
                }
              } catch (e) {
                // Fecha loading em caso de erro
                if (context.mounted) Navigator.pop(context);
                if (context.mounted) {
                  _showResultSnackbar(context, {
                    'success': false,
                    'message': 'Erro: ${e.toString()}'
                  });
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  /// Diálogo para excluir ativo
  void _showDeleteDialog(BuildContext context, ModuleManagementService service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Confirmar Exclusão'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Esta ação é irreversível!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Deseja realmente excluir o ativo:',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.assetName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Serial: ${asset.serialNumber}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);

              // Mostra loading
              _showLoadingDialog(context);
              
              try {
                // ✅ CORRIGIDO: Chamada de delete movida para dentro do try/catch
                await service.deleteAsset(
                  moduleId: moduleId,
                  assetId: asset.id,
                );

                // Fecha loading
                if (context.mounted) Navigator.pop(context);

                // Mostra resultado
                if (context.mounted) {
                  _showResultSnackbar(context,
                      {'success': true, 'message': 'Ativo excluído com sucesso'});
                }

                onCommandExecuted();
              } catch (e) {
                // Fecha loading em caso de erro
                if (context.mounted) Navigator.pop(context);
                if (context.mounted) {
                  _showResultSnackbar(context, {
                    'success': false,
                    'message': 'Erro ao excluir: ${e.toString()}'
                  });
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  /// Mostra diálogo de loading
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Processando...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Mostra snackbar com resultado da operação
  void _showResultSnackbar(BuildContext context, Map<String, dynamic> result) {
    final isSuccess = result['success'] == true;
    final message = result['message'] ??
        (isSuccess
            ? 'Operação realizada com sucesso'
            : 'Erro ao processar operação');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isInMaintenance = asset.status.toLowerCase() == 'maintenance';

    return PopupMenuButton<AssetAction>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'Ações',
      onSelected: (action) => _handleAction(context, action),
      itemBuilder: (BuildContext context) {
        return [
          if (isInMaintenance)
            const PopupMenuItem<AssetAction>(
              value: AssetAction.returnToProduction,
              child: ListTile(
                leading: Icon(Icons.check_circle_outline, color: Colors.green),
                title: Text('Retornar à Produção'),
                contentPadding: EdgeInsets.zero,
              ),
            )
          else
            const PopupMenuItem<AssetAction>(
              value: AssetAction.setMaintenance,
              child: ListTile(
                leading: Icon(Icons.build_outlined, color: Colors.orange),
                title: Text('Marcar Manutenção'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          const PopupMenuDivider(),
          const PopupMenuItem<AssetAction>(
            value: AssetAction.delete,
            child: ListTile(
              leading: Icon(Icons.delete_forever_outlined, color: Colors.red),
              title: Text('Excluir', style: TextStyle(color: Colors.red)),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ];
      },
    );
  }
}