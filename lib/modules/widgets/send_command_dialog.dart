// File: lib/modules/widgets/send_command_dialog.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/command_service.dart';

class SendCommandDialog extends StatefulWidget {
  final ManagedAsset asset;
  final String moduleId;
  final AuthService authService;
  final VoidCallback onCommandSent;

  const SendCommandDialog({
    super.key,
    required this.asset,
    required this.moduleId,
    required this.authService,
    required this.onCommandSent,
  });

  @override
  State<SendCommandDialog> createState() => _SendCommandDialogState();
}

class _SendCommandDialogState extends State<SendCommandDialog> {
  late final CommandService _commandService;
  String? _selectedCommandType;
  final _customCommandController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _commandService = CommandService(widget.authService);
  }

  @override
  void dispose() {
    _customCommandController.dispose();
    super.dispose();
  }

  Future<void> _sendCommand() async {
    if (_selectedCommandType == null) {
      _showSnackbar('Selecione um comando', isError: true);
      return;
    }

    if (_selectedCommandType == 'cmd_custom' &&
        _customCommandController.text.trim().isEmpty) {
      _showSnackbar('Digite o comando personalizado', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _commandService.sendCommand(
        moduleId: widget.moduleId,
        assetId: widget.asset.id,
        commandType: _selectedCommandType!,
        customCommand:
            _selectedCommandType == 'cmd_custom'
                ? _customCommandController.text.trim()
                : null,
      );

      if (mounted) {
        Navigator.pop(context);
        _showSnackbar(
          result['message'] ?? 'Comando enviado com sucesso',
          isError: result['success'] != true,
        );
        if (result['success'] == true) {
          widget.onCommandSent();
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Erro: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.terminal, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 12),
          const Text('Enviar Comando'),
        ],
      ),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info do Ativo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.computer, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.asset.assetName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Serial: ${widget.asset.serialNumber}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Seleção de Comando
              const Text(
                'Selecione o comando:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),

              // Grid de Comandos Pré-definidos
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                ),
                itemCount: CommandService.predefinedCommands.length,
                itemBuilder: (context, index) {
                  final entry = CommandService.predefinedCommands.entries
                      .elementAt(index);
                  final commandKey = entry.key;
                  final commandData = entry.value;

                  return _buildCommandCard(commandKey, commandData);
                },
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Comando Personalizado
              _buildCommandCard('cmd_custom', {
                'label': 'Comando Personalizado',
                'icon': 'code',
                'description': 'Execute um comando CMD customizado',
                'color': 'grey',
              }),

              if (_selectedCommandType == 'cmd_custom') ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _customCommandController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Digite o comando CMD',
                    hintText: 'Ex: ipconfig /all',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.terminal),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cuidado: Comandos personalizados podem afetar o sistema',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _sendCommand,
          icon:
              _isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Icon(Icons.send),
          label: Text(_isLoading ? 'Enviando...' : 'Enviar Comando'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCommandCard(
    String commandKey,
    Map<String, dynamic> commandData,
  ) {
    final isSelected = _selectedCommandType == commandKey;
    final colorName = commandData['color'] as String;
    final color = _getColorFromName(colorName);

    return InkWell(
      onTap: () => setState(() => _selectedCommandType = commandKey),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(
                  _getIconFromName(commandData['icon']),
                  color: isSelected ? color : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    commandData['label'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isSelected ? color : Colors.grey[800],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (commandData['requiresElevation'] == true) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Admin',
                  style: TextStyle(fontSize: 10, color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'restart_alt':
        return Icons.restart_alt;
      case 'dns':
        return Icons.dns;
      case 'print':
        return Icons.print;
      case 'settings':
        return Icons.settings;
      case 'print_disabled':
        return Icons.print_disabled;
      case 'delete_sweep':
        return Icons.delete_sweep;
      case 'settings_ethernet':
        return Icons.settings_ethernet;
      case 'code':
        return Icons.code;
      default:
        return Icons.terminal;
    }
  }

  Color _getColorFromName(String colorName) {
    switch (colorName) {
      case 'orange':
        return Colors.orange;
      case 'blue':
        return Colors.blue;
      case 'purple':
        return Colors.purple;
      case 'green':
        return Colors.green;
      case 'teal':
        return Colors.teal;
      case 'red':
        return Colors.red;
      case 'indigo':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}
