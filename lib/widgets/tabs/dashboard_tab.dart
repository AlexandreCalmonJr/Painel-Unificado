// Unified dashboard_tab.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/models/device.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/utils/helpers.dart';
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

  @override
  void initState() {
    super.initState();
    _logFilteringInfo();
  }

  @override
  void didUpdateWidget(covariant DashboardTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.devices.length != widget.devices.length) {
      _logFilteringInfo();
    }
  }

  void _logFilteringInfo() {
    final role = widget.currentUser?['role'] ?? 'desconhecido';
    final sector = widget.currentUser?['sector'] ?? 'N/A';
    debugPrint('=== DASHBOARD INFO ===');
    debugPrint('Usuário: ${widget.currentUser?['username']}');
    debugPrint('Role: $role');
    debugPrint('Setor/Prefixos: $sector');
    debugPrint('Dispositivos recebidos da API: ${widget.devices.length}');
    debugPrint('======================');
  }

  Map<String, int> _getDeviceStats() {
    int online = 0;
    int offline = 0;
    int maintenance = 0;
    int unmonitored = 0;

    // Os dispositivos já vêm filtrados do servidor por prefixo
    for (final device in widget.devices) {
      final inMaintenance = device.maintenanceStatus ?? false;
      final lastSeenTime = parseLastSeen(device.lastSeen);
      
      // Verifica se o dispositivo nunca foi visto ou está sem monitoramento
      if (device.lastSeen == null || 
          device.lastSeen == 'N/A' || 
          device.lastSeen!.isEmpty ||
          lastSeenTime == null) {
        unmonitored++;
      } else if (inMaintenance) {
        maintenance++;
      } else if (isDeviceOnline(lastSeenTime)) {
        online++;
      } else {
        offline++;
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

  List<Device> _getFilteredDevices() {
    // Os dispositivos já vêm filtrados do servidor por prefixo
    // Aqui apenas aplicamos o filtro de status local
    return widget.devices.where((device) {
      final lastSeenTime = parseLastSeen(device.lastSeen);
      final inMaintenance = device.maintenanceStatus ?? false;
      
      // Verifica se é "Sem Monitorar"
      final unmonitored = device.lastSeen == null || 
                          device.lastSeen == 'N/A' || 
                          device.lastSeen!.isEmpty ||
                          lastSeenTime == null;

      switch (_deviceFilter) {
        case 'Online':
          return !unmonitored && !inMaintenance && isDeviceOnline(lastSeenTime!);
        case 'Offline':
          return !unmonitored && !inMaintenance && !isDeviceOnline(lastSeenTime!);
        case 'Manutenção':
          return inMaintenance;
        case 'Sem Monitorar':
          return unmonitored;
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
                      'Prefixos: ${widget.currentUser!['sector']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
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