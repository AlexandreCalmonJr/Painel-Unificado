import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:painel_windowns/data/models/homelab_models.dart';
import 'package:painel_windowns/presentation/widgets/common_widgets.dart';

class AIView extends StatefulWidget {
  const AIView({Key? key}) : super(key: key);

  @override
  State<AIView> createState() => _AIViewState();
}

class _AIViewState extends State<AIView> {
  late List<AIModel> _models;
  final GPUStats _gpuStats = GPUStats(
    name: 'NVIDIA GeForce RTX 3090',
    vramTotal: 24576,
    vramUsed: 8450,
    utilization: 32,
    temp: 65,
    power: 280,
  );

  @override
  void initState() {
    super.initState();
    _models = [
      AIModel(
        id: 'llama3',
        name: 'Llama 3 8B',
        type: 'LLM',
        size: '4.7 GB',
        quantization: 'Q4_K_M',
        status: 'loaded',
        lastUsed: '5 min ago',
      ),
      AIModel(
        id: 'mistral',
        name: 'Mistral 7B v0.3',
        type: 'LLM',
        size: '4.1 GB',
        quantization: 'Q4_K_S',
        status: 'downloaded',
        lastUsed: '2 days ago',
      ),
      AIModel(
        id: 'sdxl',
        name: 'Stable Diffusion XL',
        type: 'Image Gen',
        size: '6.5 GB',
        quantization: 'FP16',
        status: 'downloaded',
        lastUsed: '1 week ago',
      ),
      AIModel(
        id: 'whisper',
        name: 'Whisper Large v3',
        type: 'Audio',
        size: '2.9 GB',
        quantization: 'FP32',
        status: 'stopped',
        lastUsed: '-',
      ),
      AIModel(
        id: 'codellama',
        name: 'CodeLlama 70B',
        type: 'LLM',
        size: '38 GB',
        quantization: 'Q3_K_M',
        status: 'downloading',
        lastUsed: '-',
        progress: 45,
      ),
    ];
  }

  void _toggleModel(String id) {
    setState(() {
      final index = _models.indexWhere((m) => m.id == id);
      if (index != -1) {
        final model = _models[index];
        String newStatus = model.status;
        String newLastUsed = model.lastUsed;

        if (model.status == 'loaded') {
          newStatus = 'downloaded';
        } else if (model.status == 'downloaded' || model.status == 'stopped') {
          newStatus = 'loaded';
          newLastUsed = 'Just now';
        }

        _models[index] = AIModel(
          id: model.id,
          name: model.name,
          type: model.type,
          size: model.size,
          quantization: model.quantization,
          status: newStatus,
          lastUsed: newLastUsed,
          progress: model.progress,
        );
      }
    });
  }

  IconData _getModelIcon(String type) {
    switch (type) {
      case 'LLM':
        return LucideIcons.bot;
      case 'Image Gen':
        return LucideIcons.sparkles;
      case 'Audio':
        return LucideIcons.wifi;
      default:
        return LucideIcons.box;
    }
  }

  Color _getModelIconColor(String type) {
    switch (type) {
      case 'LLM':
        return const Color(0xFF818CF8);
      case 'Image Gen':
        return const Color(0xFFEC4899);
      case 'Audio':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loadedModels = _models.where((m) => m.status == 'loaded').length;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Stats Row
          Row(
            children: [
              Expanded(child: _buildGPUCard()),
              const SizedBox(width: 24),
              Expanded(
                child: StatWidget(
                  title: 'Modelos Carregados',
                  value: loadedModels.toString(),
                  subtext: 'Prontos para inferência',
                  icon: LucideIcons.brainCircuit,
                  colorClass: const Color(0xFFEC4899),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: StatWidget(
                  title: 'Tokens / Seg',
                  value: '45.2 t/s',
                  subtext: 'Média (Llama 3)',
                  icon: LucideIcons.zap,
                  colorClass: const Color(0xFFFBBF24),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Models Table
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              border: Border.all(color: const Color(0xFF1E293B)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF1E293B)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                LucideIcons.bot,
                                color: Color(0xFF818CF8),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Modelos de IA Instalados',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Gerencie seus LLMs e difusores locais.',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(LucideIcons.search, size: 16),
                            label: const Text('Buscar Hub'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFF334155)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(LucideIcons.plus, size: 16),
                            label: const Text('Adicionar Modelo'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Table
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      const Color(0xFF020617),
                    ),
                    headingTextStyle: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    dataRowColor: MaterialStateProperty.resolveWith(
                      (states) =>
                          states.contains(MaterialState.hovered)
                              ? const Color(0xFF1E293B).withOpacity(0.5)
                              : null,
                    ),
                    columns: const [
                      DataColumn(label: Text('MODELO')),
                      DataColumn(label: Text('TIPO')),
                      DataColumn(label: Text('TAMANHO / QUANT')),
                      DataColumn(label: Text('STATUS')),
                      DataColumn(label: Text('AÇÕES')),
                    ],
                    rows:
                        _models.map((model) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E293B),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _getModelIcon(model.type),
                                        color: _getModelIconColor(model.type),
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          model.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          'Último uso: ${model.lastUsed}',
                                          style: const TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Text(
                                  model.type,
                                  style: const TextStyle(
                                    color: Color(0xFFCBD5E1),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${model.size} | ${model.quantization}',
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              DataCell(
                                model.status == 'downloading'
                                    ? SizedBox(
                                      width: 100,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Baixando',
                                                style: TextStyle(
                                                  color: Color(0xFFF59E0B),
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                '${model.progress}%',
                                                style: const TextStyle(
                                                  color: Color(0xFFF59E0B),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          LinearProgressIndicator(
                                            value: (model.progress ?? 0) / 100,
                                            backgroundColor: const Color(
                                              0xFF1E293B,
                                            ),
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                  Color
                                                >(Color(0xFFF59E0B)),
                                          ),
                                        ],
                                      ),
                                    )
                                    : StatusBadge(status: model.status),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    if (model.status == 'loaded')
                                      IconButton(
                                        icon: const Icon(
                                          LucideIcons.square,
                                          size: 16,
                                        ),
                                        color: const Color(0xFFEF4444),
                                        tooltip: 'Descarregar da VRAM',
                                        onPressed: () => _toggleModel(model.id),
                                      )
                                    else if (model.status == 'downloaded')
                                      IconButton(
                                        icon: const Icon(
                                          LucideIcons.play,
                                          size: 16,
                                        ),
                                        color: const Color(0xFF10B981),
                                        tooltip: 'Carregar Modelo',
                                        onPressed: () => _toggleModel(model.id),
                                      ),
                                    IconButton(
                                      icon: const Icon(
                                        LucideIcons.sliders,
                                        size: 16,
                                      ),
                                      color: const Color(0xFF94A3B8),
                                      tooltip: 'Configurações',
                                      onPressed: () {},
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        LucideIcons.terminal,
                                        size: 16,
                                      ),
                                      color: const Color(0xFF94A3B8),
                                      tooltip: 'Chat/Teste',
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGPUCard() {
    final vramPercent =
        (_gpuStats.vramUsed / _gpuStats.vramTotal * 100).round();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border.all(color: const Color(0xFF1E293B)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(LucideIcons.cpu, color: Color(0xFFA855F7), size: 20),
              SizedBox(width: 8),
              Text(
                'Acelerador GPU',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _gpuStats.name,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF064E3B),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'ONLINE',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'VRAM Usage',
                    style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12),
                  ),
                  Text(
                    '${_gpuStats.vramUsed}MB / ${_gpuStats.vramTotal}MB',
                    style: const TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: vramPercent / 100,
                backgroundColor: const Color(0xFF020617),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFA855F7),
                ),
                minHeight: 8,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildGPUStat('Load', '${_gpuStats.utilization}%'),
              ),
              Expanded(child: _buildGPUStat('Temp', '${_gpuStats.temp}°C')),
              Expanded(child: _buildGPUStat('Power', '${_gpuStats.power}W')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGPUStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        border: Border.all(color: const Color(0xFF1E293B)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
