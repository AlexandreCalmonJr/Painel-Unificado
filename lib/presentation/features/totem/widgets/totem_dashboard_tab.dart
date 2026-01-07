import 'package:flutter/material.dart';
import 'package:painel_windowns/devices/widgets/stat_card.dart';
import 'package:painel_windowns/models/totem.dart';
import 'package:painel_windowns/totem/widgets/managed_devices_card.dart';

class TotemDashboardTab extends StatelessWidget {
  final List<Totem> totems;
  final VoidCallback onRefresh;
  final dynamic authService;
  final dynamic currentUser;

  const TotemDashboardTab({
    super.key,
    required this.totems,
    required this.onRefresh,
    required this.authService,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    int onlineCount =
        totems.where((d) => d.status.toLowerCase() == 'online').length;
    int offlineCount =
        totems.where((d) => d.status.toLowerCase() == 'offline').length;
    int errorCount =
        totems.where((d) => d.status.toLowerCase() == 'com erro').length;

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          const Text(
            'Visão Geral dos Totens',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              StatCard(
                title: 'Total de Totens',
                value: totems.length.toString(),
                icon: Icons.desktop_windows,
                color: Colors.blue,
              ),
              StatCard(
                title: 'Online',
                value: onlineCount.toString(),
                icon: Icons.wifi,
                color: Colors.green,
              ),
              StatCard(
                title: 'Offline',
                value: offlineCount.toString(),
                icon: Icons.wifi_off,
                color: Colors.red,
              ),
              StatCard(
                title: 'Com Erro',
                value: errorCount.toString(),
                icon: Icons.warning,
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 30),
          ManagedTotemsCard(
            title: 'Totens Gerenciados (${totems.length})',
            totems: totems,
            authService: authService,
            onTotemUpdate:
                onRefresh, // Adicione o callback se tiver, ou remova esta linha
          ),
        ],
      ),
    );
  }
}
