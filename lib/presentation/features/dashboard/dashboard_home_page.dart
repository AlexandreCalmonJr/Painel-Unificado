import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:painel_windowns/data/models/homelab_models.dart';
import 'package:painel_windowns/presentation/widgets/common_widgets.dart';

class DashboardHomePage extends StatelessWidget {

  const DashboardHomePage({required this.devices, super.key});
  final List<dynamic> devices;

  @override
  Widget build(BuildContext context) {
    final systemStats = SystemStats(
      cpu: 45,
      ram: 72,
      storage: 68,
      temp: 58,
      networkUp: '450 Mbps',
      networkDown: '980 Mbps',
      uptime: '14d 03h 22m',
      containers: 24,
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          // Stats Row
          Row(
            children: [
              Expanded(
                child: StatWidget(
                  title: 'Uso de CPU',
                  value: '${systemStats.cpu}%',
                  percent: systemStats.cpu.toDouble(),
                  subtext: 'Intel Core i7',
                  icon: LucideIcons.cpu,
                  colorClass: const Color(0xFF818CF8),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: StatWidget(
                  title: 'RAM',
                  value: '${systemStats.ram}%',
                  percent: systemStats.ram.toDouble(),
                  subtext: '32GB Disp.',
                  icon: LucideIcons.activity,
                  colorClass: const Color(0xFFA855F7),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: StatWidget(
                  title: 'Storage',
                  value: '${systemStats.storage}%',
                  percent: systemStats.storage.toDouble(),
                  subtext: '12TB Livre',
                  icon: LucideIcons.hardDrive,
                  colorClass: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: StatWidget(
                  title: 'Rede',
                  value: systemStats.networkUp,
                  subtext: 'Up',
                  icon: LucideIcons.wifi,
                  colorClass: const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Devices Table
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
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF1E293B)),
                    ),
                  ),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Status (Live)',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
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
                      DataColumn(label: Text('NOME')),
                      DataColumn(label: Text('IP')),
                      DataColumn(label: Text('STATUS')),
                    ],
                    rows:
                        devices.map((d) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  (d['name'] ?? d.name ?? '').toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              DataCell(
                                Text(
                                  (d['ip'] ?? d.ip ?? '').toString(),
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              DataCell(
                                StatusBadge(
                                  status:
                                      (d['status'] ?? d.status ?? 'offline')
                                          .toString(),
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
}
