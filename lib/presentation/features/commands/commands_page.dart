import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:painel_windowns/data/models/homelab_models.dart';

class CommandsPage extends StatefulWidget {
  const CommandsPage({super.key});

  @override
  State<CommandsPage> createState() => _CommandsPageState();
}

class _CommandsPageState extends State<CommandsPage> {
  final List<CommandTarget> _allTargets = [];
  final List<int> _selectedTargets = [];
  final List<CommandLog> _commandLog = [];
  final _customCmdController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeTargets();
    _addLog('Console de comandos inicializado.', 'System');
  }

  void _initializeTargets() {
    // Simulação de alvos disponíveis
    _allTargets.addAll([
      CommandTarget(
        id: 1,
        name: 'Proxmox Node 01',
        group: 'Servers',
        ip: '192.168.1.10',
        status: 'online',
      ),
      CommandTarget(
        id: 2,
        name: 'TrueNAS Core',
        group: 'Servers',
        ip: '192.168.1.20',
        status: 'online',
      ),
      CommandTarget(
        id: 5,
        name: 'Ubuntu Docker',
        group: 'Servers',
        ip: '192.168.1.15',
        status: 'online',
      ),
      CommandTarget(
        id: 10,
        name: 'Dev Workstation 01',
        group: 'Workstations',
        ip: '192.168.1.50',
        status: 'online',
      ),
      CommandTarget(
        id: 11,
        name: 'Admin iPhone 15',
        group: 'Mobile',
        ip: 'Dynamic',
        status: 'compliant',
      ),
    ]);
  }

  @override
  void dispose() {
    _customCmdController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addLog(String msg, String source) {
    setState(() {
      _commandLog.add(
        CommandLog(
          id: DateTime.now().millisecondsSinceEpoch,
          time: TimeOfDay.now().format(context),
          source: source,
          msg: msg,
        ),
      );
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleTarget(int id) {
    setState(() {
      if (_selectedTargets.contains(id)) {
        _selectedTargets.remove(id);
      } else {
        _selectedTargets.add(id);
      }
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedTargets.length == _allTargets.length) {
        _selectedTargets.clear();
      } else {
        _selectedTargets.clear();
        _selectedTargets.addAll(_allTargets.map((t) => t.id));
      }
    });
  }

  void _executeCommand(String cmdName, {bool isDangerous = false}) {
    if (_selectedTargets.isEmpty) {
      _addLog('ERRO: Nenhum alvo selecionado.', 'Error');
      return;
    }

    if (isDangerous) {
      // ignore: inference_failure_on_function_invocation
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              backgroundColor: const Color(0xFF0F172A),
              title: const Text(
                'Confirmar Comando',
                style: TextStyle(color: Colors.white),
              ),
              content: Text(
                'ATENÇÃO: Executar "$cmdName" em ${_selectedTargets.length} dispositivos?',
                style: const TextStyle(color: Color(0xFF94A3B8)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _runCommand(cmdName);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                  ),
                  child: const Text('Executar'),
                ),
              ],
            ),
      );
    } else {
      _runCommand(cmdName);
    }
  }

  void _runCommand(String cmdName) {
    _addLog(
      'A enviar comando: [$cmdName] para ${_selectedTargets.length} hosts...',
      'Master',
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      for (final id in _selectedTargets) {
        final device = _allTargets.firstWhere((t) => t.id == id);
        final success =
            DateTime.now().millisecond % 10 != 0; // 90% success rate
        _addLog(
          success
              ? 'Comando executado com sucesso. Exit code 0'
              : 'Falha na execução.',
          device.name,
        );
      }
    });
  }

  void _handleCustomSubmit() {
    if (_customCmdController.text.trim().isEmpty) return;
    _executeCommand(_customCmdController.text);
    _customCmdController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Panel - Target Selection & Quick Actions
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Target Selection
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    border: Border.all(color: const Color(0xFF1E293B)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFF020617),
                          border: Border(
                            bottom: BorderSide(color: Color(0xFF1E293B)),
                          ),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  LucideIcons.checkSquare,
                                  color: Color(0xFF818CF8),
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Selecionar Alvos',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: _selectAll,
                              child: Text(
                                _selectedTargets.length == _allTargets.length
                                    ? 'Desmarcar Todos'
                                    : 'Selecionar Todos',
                                style: const TextStyle(
                                  color: Color(0xFF818CF8),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 240),
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(8),
                          itemCount: _allTargets.length,
                          itemBuilder: (context, index) {
                            final device = _allTargets[index];
                            final isSelected = _selectedTargets.contains(
                              device.id,
                            );
                            return InkWell(
                              onTap: () => _toggleTarget(device.id),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? const Color(
                                            0xFF4F46E5,
                                          ).withOpacity(0.2)
                                          : null,
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? const Color(
                                              0xFF4F46E5,
                                            ).withOpacity(0.3)
                                            : Colors.transparent,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? const Color(0xFF4F46E5)
                                                : null,
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? const Color(0xFF4F46E5)
                                                  : const Color(0xFF475569),
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child:
                                          isSelected
                                              ? const Icon(
                                                LucideIcons.check,
                                                size: 12,
                                                color: Colors.white,
                                              )
                                              : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            device.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            '${device.group} • ${device.ip}',
                                            style: const TextStyle(
                                              color: Color(0xFF64748B),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color:
                                            device.status == 'online' ||
                                                    device.status == 'compliant'
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFFEF4444),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Quick Actions
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    border: Border.all(color: const Color(0xFF1E293B)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            LucideIcons.terminal,
                            color: Color(0xFF10B981),
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Ações Rápidas',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildQuickActionButton(
                            'Atualizar Sistema',
                            LucideIcons.download,
                            () => _executeCommand(
                              'apt-get update && apt-get upgrade -y',
                            ),
                          ),
                          _buildQuickActionButton(
                            'Limpar Docker',
                            LucideIcons.trash2,
                            () => _executeCommand('docker system prune -f'),
                          ),
                          _buildQuickActionButton(
                            'Reiniciar Host',
                            LucideIcons.refreshCw,
                            () => _executeCommand('reboot', isDangerous: true),
                            isWarning: true,
                          ),
                          _buildQuickActionButton(
                            'Wipe Data',
                            LucideIcons.eraser,
                            () =>
                                _executeCommand('format /y', isDangerous: true),
                            isDanger: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Custom Shell
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    border: Border.all(color: const Color(0xFF1E293B)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            LucideIcons.hash,
                            color: Color(0xFF64748B),
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Shell Remoto',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customCmdController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'monospace',
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                hintText: 'sudo systemctl status...',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF475569),
                                ),
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(left: 12, right: 8),
                                  child: Text(
                                    '>',
                                    style: TextStyle(
                                      color: Color(0xFF6366F1),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 0,
                                  minHeight: 0,
                                ),
                                filled: true,
                                fillColor: const Color(0xFF020617),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF334155),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF334155),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              onSubmitted: (_) => _handleCustomSubmit(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _handleCustomSubmit,
                            icon: const Icon(LucideIcons.send),
                            color: Colors.white,
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Right Panel - Terminal Output
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(color: const Color(0xFF1E293B)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F172A),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF1E293B)),
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TERMINAL OUTPUT',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF334155),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF334155),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF334155),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _commandLog.length,
                    itemBuilder: (context, index) {
                      final log = _commandLog[index];
                      Color sourceColor;
                      if (log.source == 'System') {
                        sourceColor = const Color(0xFF818CF8);
                      } else if (log.source == 'Master') {
                        sourceColor = const Color(0xFF10B981);
                      } else if (log.source == 'Error') {
                        sourceColor = const Color(0xFFEF4444);
                      } else {
                        sourceColor = const Color(0xFF60A5FA);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '[${log.time}]',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${log.source}:',
                              style: TextStyle(
                                color: sourceColor,
                                fontFamily: 'monospace',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                log.msg,
                                style: const TextStyle(
                                  color: Color(0xFFCBD5E1),
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed, {
    bool isWarning = false,
    bool isDanger = false,
  }) {
    return SizedBox(
      width: 180,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 14),
        label: Text(label, style: const TextStyle(fontSize: 13)),
        style: OutlinedButton.styleFrom(
          foregroundColor:
              isDanger
                  ? const Color(0xFFEF4444)
                  : isWarning
                  ? const Color(0xFFF59E0B)
                  : const Color(0xFF94A3B8),
          side: BorderSide(
            color:
                isDanger
                    ? const Color(0xFF7F1D1D).withOpacity(0.3)
                    : isWarning
                    ? const Color(0xFF78350F).withOpacity(0.3)
                    : Colors.transparent,
          ),
          backgroundColor: const Color(0xFF1E293B),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
      ),
    );
  }
}
