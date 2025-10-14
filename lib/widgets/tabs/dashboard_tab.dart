// Unified dashboard_tab.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/models/device.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/widgets/managed_devices_card.dart';
import 'package:painel_windowns/widgets/stat_card.dart';

class DashboardTab extends StatefulWidget {
  final List<Device> devices;
  final String? errorMessage;
  final Map<String, dynamic>? currentUser;
  final AuthService authService;

  const DashboardTab({
    required this.authService,
    super.key,
    required this.devices,
    this.errorMessage,
    this.currentUser,
  });

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  String _deviceFilter = 'Todos';

  // Função de contagem CORRIGIDA
  Map<String, int> _getDeviceStats() {
    int online = 0;
    int offline = 0;
    int maintenance = 0;
    int unmonitored = 0;

    for (final device in widget.devices) {
      switch (device.displayStatus) {
        case DeviceStatusType.online:
          online++;
          break;
        case DeviceStatusType.offline:
          offline++;
          break;
        case DeviceStatusType.maintenance:
        case DeviceStatusType.collectedByIT: // Agrupando no mesmo card
          maintenance++;
          break;
        case DeviceStatusType.unmonitored:
          unmonitored++;
          break;
      }
    }

    return {
      'total': widget.devices.length,
      'online': online,
      'offline': offline,
      'maintenance': maintenance,
      'unmonitored': unmonitored,
    };
  }

  // Função de filtragem CORRIGIDA
  List<Device> _getFilteredDevices() {
    if (_deviceFilter == 'Todos') {
      return widget.devices;
    }

    return widget.devices.where((device) {
      switch (_deviceFilter) {
        case 'Online':
          return device.displayStatus == DeviceStatusType.online;
        case 'Offline':
          return device.displayStatus == DeviceStatusType.offline;
        case 'Manutenção':
          return device.displayStatus == DeviceStatusType.maintenance ||
                 device.displayStatus == DeviceStatusType.collectedByIT;
        case 'Sem Monitorar':
          return device.displayStatus == DeviceStatusType.unmonitored;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final stats = _getDeviceStats();
    final filteredDevices = _getFilteredDevices();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Painel',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                if (widget.currentUser != null && widget.currentUser!['role'] == 'user')
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Visibilidade por prefixos: ${widget.currentUser!['sector']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
            // O Dropdown de filtro permanece o mesmo
            DropdownButton<String>(
              value: _deviceFilter,
              items: const [
                DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                DropdownMenuItem(value: 'Online', child: Text('Online')),
                DropdownMenuItem(value: 'Offline', child: Text('Offline')),
                DropdownMenuItem(value: 'Manutenção', child: Text('Em Manutenção')),
                DropdownMenuItem(value: 'Sem Monitorar', child: Text('Sem Monitorar')),
              ],
              onChanged: (value) {
                setState(() {
                  _deviceFilter = value!;
                });
              },
            ),
          ],
        ),
        if (widget.errorMessage != null)
          // Widget de erro (sem alteração)
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              border: Border.all(color: Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.errorMessage!,
                    style: TextStyle(color: Colors.red[800]),
                  ),
                ),
              ],
            ),
          ),
        if (widget.devices.isEmpty && widget.errorMessage == null)
          // Widget de "Nenhum dispositivo" (sem alteração)
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.blue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Nenhum dispositivo encontrado para os prefixos configurados.',
                    style: TextStyle(color: Colors.blue[800]),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 20),
        // StatCards (sem alteração de widget, apenas os valores que eles recebem)
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Total de Dispositivos',
                value: '${stats['total']}',
                icon: Icons.smartphone,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: StatCard(
                title: 'Online',
                value: '${stats['online']}',
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: StatCard(
                title: 'Offline',
                value: '${stats['offline']}',
                icon: Icons.warning,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: StatCard(
                title: 'Em Manutenção',
                value: '${stats['maintenance']}',
                icon: Icons.build,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: StatCard(
                title: 'Sem Monitorar',
                value: '${stats['unmonitored']}',
                icon: Icons.visibility_off,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        // Tabela de dispositivos (sem alteração de widget)
        Expanded(
          child: ManagedDevicesCard(
            title: 'Dispositivos Gerenciados (${filteredDevices.length})',
            devices: filteredDevices,
            authService: widget.authService,
            showActions: false,
            currentUser: widget.currentUser,
          ),
        ),
      ],
    );
  }
}