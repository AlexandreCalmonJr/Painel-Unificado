// File: lib/modules/widgets/send_command_dialog.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/data/models/asset_module_base_model.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/command_service.dart';

class SendCommandDialog extends StatefulWidget {

  const SendCommandDialog({
    required this.asset, required this.moduleId, required this.authService, required this.onCommandSent, super.key,
  });
  final ManagedAsset asset;
  final String moduleId;
  final AuthService authService;
  final VoidCallback onCommandSent;

  @override
  State<SendCommandDialog> createState() => _SendCommandDialogState();
}

class _SendCommandDialogState extends State<SendCommandDialog> {
  late final CommandService _commandService;
  String? _selectedCommandType;

  // Controllers para capturar os parâmetros (URL, Caminho, Nome, etc)
  final _param1Controller = TextEditingController();
  final _param2Controller = TextEditingController();

  bool _isLoading = false;
  bool _showInputs = false; // Alterna entre a Grid de ícones e o Formulário

  @override
  void initState() {
    super.initState();
    _commandService = CommandService(widget.authService);
  }

  @override
  void dispose() {
    _param1Controller.dispose();
    _param2Controller.dispose();
    super.dispose();
  }

  // Seleciona o comando e decide se precisa mostrar inputs
  void _selectCommand(String key, Map<String, dynamic> data) {
    setState(() {
      _selectedCommandType = key;
      _param1Controller.clear();
      _param2Controller.clear();

      // Se o comando tem a flag 'hasParams' ou é o customizado, abre o formulário
      if (data['hasParams'] == true || key == 'cmd_custom') {
        _showInputs = true;
      } else {
        // Se for comando simples (ex: reiniciar), mostra confirmação
        _showInputs = true;
      }
    });
  }

  Future<void> _sendCommand() async {
    if (_selectedCommandType == null) return;

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic>? params;
      String? customCmd;

      // Monta o payload de acordo com o tipo selecionado
      if (_selectedCommandType == 'map_lpt2') {
        if (_param1Controller.text.isEmpty) {
          throw Exception('Caminho da impressora obrigatório');
        }
        params = {'path': _param1Controller.text.trim()};
      } else if (_selectedCommandType == 'download_file') {
        if (_param1Controller.text.isEmpty || _param2Controller.text.isEmpty) {
          throw Exception('URL e Destino obrigatórios');
        }
        params = {
          'url': _param1Controller.text.trim(),
          'destination': _param2Controller.text.trim(),
        };
      } else if (_selectedCommandType == 'auto_start_app') {
        if (_param1Controller.text.isEmpty || _param2Controller.text.isEmpty) {
          throw Exception('Nome e Caminho obrigatórios');
        }
        params = {
          'name': _param1Controller.text.trim(),
          'path': _param2Controller.text.trim(),
        };
      } else if (_selectedCommandType == 'cmd_custom') {
        if (_param1Controller.text.isEmpty) {
          throw Exception('Comando obrigatório');
        }
        customCmd = _param1Controller.text.trim();
      }

      // Envia para a API
      final result = await _commandService.sendCommand(
        moduleId: widget.moduleId,
        assetId: widget.asset.id,
        commandType: _selectedCommandType!,
        customCommand: customCmd,
        parameters: params,
      );

      if (mounted) {
        Navigator.pop(context); // Fecha o Dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] as String?? 'Comando enviado'),
            backgroundColor:
                result['success'] == true ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );

        if (result['success'] == true) {
          widget.onCommandSent();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se selecionou um comando, mostra a tela de inputs/confirmação
    if (_showInputs && _selectedCommandType != null) {
      return _buildInputForm();
    }

    // Caso contrário, mostra a grade de opções
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Enviar Comando Remoto'),
      content: SizedBox(
        width: 650,
        height: 450,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 3 Colunas
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.2, // Botões retangulares
          ),
          // Soma 1 para incluir o botão "Customizado" manual
          itemCount: CommandService.predefinedCommands.length + 1,
          itemBuilder: (ctx, i) {
            // Adiciona o botão "Customizado" no final da lista
            if (i == CommandService.predefinedCommands.length) {
              return _buildCommandCard('cmd_custom', {
                'label': 'CMD / PowerShell',
                'icon': 'terminal',
                'color': 'grey',
                'hasParams': true,
              });
            }

            final key = CommandService.predefinedCommands.keys.elementAt(i);
            final val = CommandService.predefinedCommands[key]!;
            return _buildCommandCard(key, val);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  // Constrói o formulário dinâmico baseado no comando
  Widget _buildInputForm() {
    String title = 'Configurar Comando';
    final List<Widget> inputs = [];
    String? iconName;

    // Lógica de UI para cada tipo de comando
    if (_selectedCommandType == 'map_lpt2') {
      title = 'Mapear Impressora LPT2';
      iconName = 'print';
      inputs.add(
        _buildTextField(
          _param1Controller,
          'Caminho de Rede',
          r'Ex: \\192.168.0.10\HP_LaserJet',
        ),
      );
      inputs.add(const SizedBox(height: 8));
      inputs.add(
        _buildInfoText(
          'Isso mapeará o compartilhamento para a porta LPT2 com persistência.',
        ),
      );
    } else if (_selectedCommandType == 'download_file') {
      title = 'Enviar Arquivo para o PC';
      iconName = 'file_download';
      inputs.add(
        _buildTextField(
          _param1Controller,
          'URL do Arquivo (Link Direto)',
          'https://meusite.com/app.exe',
        ),
      );
      inputs.add(const SizedBox(height: 12));
      inputs.add(
        _buildTextField(
          _param2Controller,
          'Salvar em (Caminho Completo)',
          r'C:\Temp\app.exe',
        ),
      );
    } else if (_selectedCommandType == 'auto_start_app') {
      title = 'Iniciar App com Windows';
      iconName = 'play_circle';
      inputs.add(
        _buildTextField(
          _param1Controller,
          'Nome do Aplicativo',
          'MeuSistemaERP',
        ),
      );
      inputs.add(const SizedBox(height: 12));
      inputs.add(
        _buildTextField(
          _param2Controller,
          'Caminho do Executável',
          r'C:\Sistema\app.exe',
        ),
      );
    } else if (_selectedCommandType == 'cmd_custom') {
      title = 'Comando Customizado';
      iconName = 'terminal';
      inputs.add(
        _buildTextField(
          _param1Controller,
          'Comando (CMD/PowerShell)',
          'ipconfig /all',
          maxLines: 4,
        ),
      );
    } else {
      // Comandos sem parâmetros (Reiniciar, Limpar Temp, etc)
      title = 'Confirmar Execução';
      iconName = 'check_circle';
      inputs.add(
        Text(
          'Tem certeza que deseja executar o comando:\n\n"${_selectedCommandType!.replaceAll('_', ' ').toUpperCase()}"?',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          ...[
          Icon(_getIconFromName(iconName), color: Colors.blue),
          const SizedBox(width: 10),
        ],
          Text(title),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: inputs,
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              () => setState(() {
                _showInputs = false;
                _selectedCommandType = null;
              }),
          child: const Text('Voltar'),
        ),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _sendCommand,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          icon:
              _isLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : const Icon(Icons.send, size: 18),
          label: Text(_isLoading ? 'Enviando...' : 'Enviar Comando'),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController c,
    String label,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandCard(String key, Map<String, dynamic> data) {
    final color = _getColorFromName(data['color'] as String);
    final icon = _getIconFromName(data['icon'] as String);

    return InkWell(
      onTap: () => _selectCommand(key, data),
      borderRadius: BorderRadius.circular(12),
      hoverColor: color.withOpacity(0.1),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.05),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              data['label'] as String,
              style: TextStyle(
                color: color.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Helpers de UI
  IconData _getIconFromName(String? name) {
    switch (name) {
      case 'restart_alt':
        return Icons.restart_alt;
      case 'dns':
        return Icons.dns;
      case 'print':
        return Icons.print;
      case 'file_download':
        return Icons.file_download;
      case 'play_circle':
        return Icons.play_circle_filled;
      case 'delete_sweep':
        return Icons.delete_sweep;
      case 'settings':
        return Icons.settings;
      case 'settings_ethernet':
        return Icons.settings_ethernet;
      case 'check_circle':
        return Icons.check_circle_outline;
      default:
        return Icons.terminal;
    }
  }

  Color _getColorFromName(String? name) {
    switch (name) {
      case 'orange':
        return Colors.orange;
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'teal':
        return Colors.teal;
      case 'green':
        return Colors.green;
      case 'indigo':
        return Colors.indigo;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
