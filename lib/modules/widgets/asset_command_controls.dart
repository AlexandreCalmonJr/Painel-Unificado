// File: lib/widgets/asset_command_controls.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/command_service.dart'; // ✅ Importado
import 'package:painel_windowns/services/module_management_service.dart';

enum AssetAction {
  sendCommand,
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
    required Function() onEditPressed,
  });

  void _handleAction(BuildContext context, AssetAction action) {
    final moduleService = ModuleManagementService(authService: authService);
    // Instancia o serviço de comandos apenas quando necessário
    final commandService = CommandService(authService);

    switch (action) {
      case AssetAction.sendCommand:
        _showCommandDialog(context, commandService);
        break;

      case AssetAction.setMaintenance:
        _showMaintenanceDialog(context, moduleService);
        break;

      case AssetAction.returnToProduction:
        _showReturnToProductionDialog(context, moduleService);
        break;

      case AssetAction.delete:
        _showDeleteDialog(context, moduleService);
        break;

      case AssetAction.viewDetails:
        break;
    }
  }

  /// ✅ ATUALIZADO: Diálogo com Botões Predefinidos + Custom
  /// ✅ ATUALIZADO: Diálogo com Botões Compactos
  /// ✅ ATUALIZADO: Diálogo Compacto e Controlado
  void _showCommandDialog(BuildContext context, CommandService commandService) {
    final customCommandController = TextEditingController();

    // Helpers de Icone e Cor (mantidos iguais)
    IconData getIcon(String iconName) {
      const icons = {
        'restart_alt': Icons.restart_alt,
        'dns': Icons.dns,
        'print': Icons.print,
        'settings': Icons.settings,
        'print_disabled': Icons.print_disabled,
        'delete_sweep': Icons.delete_sweep,
        'settings_ethernet': Icons.settings_ethernet,
      };
      return icons[iconName] ?? Icons.code;
    }

    Color getColor(String colorName) {
      const colors = {
        'orange': Colors.orange,
        'blue': Colors.blue,
        'purple': Colors.purple,
        'green': Colors.green,
        'teal': Colors.teal,
        'red': Colors.red,
        'indigo': Colors.indigo,
      };
      return colors[colorName] ?? Colors.grey;
    }

    Future<void> executeCommand(String type, {String? customCmd}) async {
      Navigator.pop(context);
      _showLoadingDialog(context);

      final result = await commandService.sendCommand(
        moduleId: moduleId,
        assetId: asset.id,
        commandType: type,
        customCommand: customCmd,
      );

      if (context.mounted) Navigator.pop(context);
      if (context.mounted) _showResultSnackbar(context, result);
      if (result['success'] == true) onCommandExecuted();
    }

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            // ✅ Reduz padding para aproveitar espaço
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.terminal,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text('Enviar Comando', style: TextStyle(fontSize: 18)),
              ],
            ),
            content: SizedBox(
              // ✅ AQUI ESTÁ O SEGREDO: Limita a largura para não esticar na tela toda
              width: 600,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ativo: ${asset.assetName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),

                    const Text(
                      'Ações Rápidas',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ✅ Grid Ajustada
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // 3 botões por linha
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio:
                            2.8, // ✅ Quanto maior este número, mais "achatado" fica o botão
                      ),
                      itemCount: CommandService.predefinedCommands.length,
                      itemBuilder: (context, index) {
                        final key = CommandService.predefinedCommands.keys
                            .elementAt(index);
                        final cmd = CommandService.predefinedCommands[key]!;
                        final color = getColor(cmd['color']);

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => executeCommand(key),
                            borderRadius: BorderRadius.circular(8),
                            hoverColor: color.withOpacity(0.05),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Row(
                                // ✅ Mudei para Row para ficar lado a lado (ícone + texto)
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    getIcon(cmd['icon']),
                                    size: 18,
                                    color: color,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      cmd['label'],
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[800],
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.left,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 15),

                    // Seção Customizada Compacta
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Comando Customizado (Shell)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                height: 40,
                                child: TextField(
                                  controller: customCommandController,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: InputDecoration(
                                    hintText: 'Ex: ipconfig /flushdns',
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 0,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.code,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 40,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final cmd = customCommandController.text.trim();
                              if (cmd.isNotEmpty)
                                executeCommand('custom', customCmd: cmd);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.send, size: 16),
                            label: const Text('Enviar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                style: TextButton.styleFrom(foregroundColor: Colors.grey),
                child: const Text('Cancelar'),
              ),
            ],
          ),
    );
  }

  /// Diálogo para marcar manutenção
  void _showMaintenanceDialog(
    BuildContext context,
    ModuleManagementService service,
  ) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.build_outlined,
                    color: Colors.orange,
                    size: 24,
                  ),
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
                  _showLoadingDialog(context);

                  try {
                    final result = await service.setMaintenanceMode(
                      moduleId: moduleId,
                      assetId: asset.id,
                      maintenanceMode: true,
                      reason: reason.isNotEmpty ? reason : null,
                    );

                    if (context.mounted) Navigator.pop(context);
                    if (context.mounted) _showResultSnackbar(context, result);

                    if (result['success'] == true) {
                      onCommandExecuted();
                    }
                  } catch (e) {
                    if (context.mounted) Navigator.pop(context);
                    if (context.mounted) {
                      _showResultSnackbar(context, {
                        'success': false,
                        'message': 'Erro: ${e.toString()}',
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
    BuildContext context,
    ModuleManagementService service,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 24,
                  ),
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
                  _showLoadingDialog(context);
                  try {
                    final result = await service.setMaintenanceMode(
                      moduleId: moduleId,
                      assetId: asset.id,
                      maintenanceMode: false,
                    );

                    if (context.mounted) Navigator.pop(context);
                    if (context.mounted) _showResultSnackbar(context, result);

                    if (result['success'] == true) {
                      onCommandExecuted();
                    }
                  } catch (e) {
                    if (context.mounted) Navigator.pop(context);
                    if (context.mounted) {
                      _showResultSnackbar(context, {
                        'success': false,
                        'message': 'Erro: ${e.toString()}',
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
  void _showDeleteDialog(
    BuildContext context,
    ModuleManagementService service,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 24,
                  ),
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
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
                  _showLoadingDialog(context);

                  try {
                    await service.deleteAsset(
                      moduleId: moduleId,
                      assetId: asset.id,
                    );

                    if (context.mounted) Navigator.pop(context);

                    if (context.mounted) {
                      _showResultSnackbar(context, {
                        'success': true,
                        'message': 'Ativo excluído com sucesso',
                      });
                    }
                    onCommandExecuted();
                  } catch (e) {
                    if (context.mounted) Navigator.pop(context);
                    if (context.mounted) {
                      _showResultSnackbar(context, {
                        'success': false,
                        'message': 'Erro ao excluir: ${e.toString()}',
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
      builder:
          (ctx) => const Center(
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

  /// Mostra snackbar com resultado
  void _showResultSnackbar(BuildContext context, Map<String, dynamic> result) {
    final isSuccess = result['success'] == true;
    final message =
        result['message'] ??
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
          const PopupMenuItem<AssetAction>(
            value: AssetAction.sendCommand,
            child: ListTile(
              leading: Icon(Icons.terminal, color: Colors.blue),
              title: Text('Enviar Comando'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const PopupMenuDivider(),

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
