import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:painel_windowns/data/models/homelab_models.dart';

class ContainersView extends StatelessWidget {
  const ContainersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final containers = [
      ContainerData(
        id: 1,
        name: 'pihole-dns',
        image: 'pihole/pihole:latest',
        status: 'running',
        port: '53:53',
        cpu: '0.5%',
        mem: '45MB',
        uptime: '2d 4h',
      ),
      ContainerData(
        id: 2,
        name: 'nginx-proxy',
        image: 'jc21/nginx-proxy-manager',
        status: 'running',
        port: '80:80',
        cpu: '1.2%',
        mem: '120MB',
        uptime: '5d 12h',
      ),
      ContainerData(
        id: 3,
        name: 'portainer',
        image: 'portainer/portainer-ce',
        status: 'running',
        port: '9000:9000',
        cpu: '0.1%',
        mem: '25MB',
        uptime: '14d',
      ),
      ContainerData(
        id: 4,
        name: 'ollama-service',
        image: 'ollama/ollama:latest',
        status: 'running',
        port: '11434:11434',
        cpu: '2.5%',
        mem: '4.2GB',
        uptime: '3d',
      ),
    ];

    return Container(
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
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
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
                          LucideIcons.box,
                          color: Color(0xFF3B82F6),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Docker Containers',
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
                      'Gerencie seus containers Docker.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(LucideIcons.refreshCw, size: 16),
                      label: const Text('Atualizar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF334155)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(LucideIcons.plus, size: 16),
                      label: const Text('Novo Container'),
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
          Expanded(
            child: SingleChildScrollView(
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
                  DataColumn(label: Text('NOME')),
                  DataColumn(label: Text('IMAGEM')),
                  DataColumn(label: Text('STATUS')),
                  DataColumn(label: Text('PORTA')),
                  DataColumn(label: Text('CPU')),
                  DataColumn(label: Text('MEMÓRIA')),
                  DataColumn(label: Text('UPTIME')),
                  DataColumn(label: Text('AÇÕES')),
                ],
                rows:
                    containers.map((container) {
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
                                  child: const Icon(
                                    LucideIcons.box,
                                    color: Color(0xFF3B82F6),
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  container.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(
                              container.image,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6).withOpacity(0.1),
                                border: Border.all(
                                  color: const Color(
                                    0xFF3B82F6,
                                  ).withOpacity(0.2),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF3B82F6),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    container.status.toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xFF3B82F6),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              container.port,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              container.cpu,
                              style: const TextStyle(
                                color: Color(0xFFCBD5E1),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              container.mem,
                              style: const TextStyle(
                                color: Color(0xFFCBD5E1),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              container.uptime,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    LucideIcons.square,
                                    size: 14,
                                  ),
                                  color: const Color(0xFFEF4444),
                                  tooltip: 'Parar',
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(
                                    LucideIcons.terminal,
                                    size: 14,
                                  ),
                                  color: const Color(0xFF94A3B8),
                                  tooltip: 'Logs',
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(
                                    LucideIcons.settings,
                                    size: 14,
                                  ),
                                  color: const Color(0xFF94A3B8),
                                  tooltip: 'Configurações',
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
          ),
        ],
      ),
    );
  }
}
