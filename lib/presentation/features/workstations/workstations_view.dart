import 'package:flutter/material.dart';
import 'package:painel_windowns/data/models/homelab_models.dart';
import 'package:painel_windowns/presentation/widgets/common_widgets.dart';

class WorkstationsView extends StatelessWidget {
  const WorkstationsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final workstations = [
      WorkstationAsset(
        id: 1,
        name: 'Dev Workstation 01',
        type: 'desktop',
        user: 'John Dev',
        os: 'Windows 11 Pro',
        status: 'online',
        ip: '192.168.1.50',
      ),
      WorkstationAsset(
        id: 4,
        name: 'Reception Dashboard',
        type: 'panel',
        user: 'Kiosk',
        os: 'Raspberry Pi OS',
        status: 'online',
        ip: '192.168.1.60',
        currentUrl: 'http://grafana.local',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border.all(color: const Color(0xFF1E293B)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(const Color(0xFF020617)),
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
            DataColumn(label: Text('STATUS')),
            DataColumn(label: Text('USUÁRIO')),
            DataColumn(label: Text('IP')),
          ],
          rows:
              workstations.map((w) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        w.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    DataCell(StatusBadge(status: w.status)),
                    DataCell(
                      Text(
                        w.user,
                        style: const TextStyle(color: Color(0xFF94A3B8)),
                      ),
                    ),
                    DataCell(
                      Text(
                        w.ip,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }
}
