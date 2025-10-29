import 'dart:async';
import 'dart:convert';

import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:painel_windowns/devices/device_detail_screen.dart';
import 'package:painel_windowns/devices/utils/helpers.dart';
import 'package:painel_windowns/devices/utils/test_tab.dart';
import 'package:painel_windowns/devices/widgets/tabs/alerts_tab.dart';
import 'package:painel_windowns/devices/widgets/tabs/dashboard_tab.dart';
import 'package:painel_windowns/devices/widgets/tabs/devices_tab.dart';
import 'package:painel_windowns/devices/widgets/tabs/maintenance_tab.dart';
import 'package:painel_windowns/devices/widgets/tabs/reports_tab.dart';
import 'package:painel_windowns/devices/widgets/tabs/security_tab.dart';
import 'package:painel_windowns/devices/widgets/tabs/server_tab.dart';
import 'package:painel_windowns/devices/widgets/tabs/units_tab.dart';
import 'package:painel_windowns/devices/widgets/tabs/users_tab.dart';
import 'package:painel_windowns/models/bssid_mapping.dart';
import 'package:painel_windowns/models/device.dart';
import 'package:painel_windowns/models/unit.dart';
import 'package:painel_windowns/screen/login_screen.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/device_service.dart';
import 'package:painel_windowns/services/server_config_service.dart';

class MDMDashboard extends StatefulWidget {
  final AuthService authService;
  const MDMDashboard({super.key, required this.authService});

  @override
  _MDMDashboardState createState() => _MDMDashboardState();
}

class _MDMDashboardState extends State<MDMDashboard> {
  int selectedIndex = 0;
  bool _isSidebarVisible = true;
  List<Device> _previousDevices = [];

  List<Device> _allFetchedDevices = [];
  List<Device> _displayedDevices = [];
  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = '';
  final int _devicesPerPage = 15;

  List<Unit> units = [];
  List<BssidMapping> bssidMappings = [];
  bool isLoading = false;
  String? errorMessage;
  final DeviceService _deviceService = DeviceService();

  Timer? _refreshTimer;

  String serverIp = '';
  String serverPort = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadUnits();
    await _loadBssidMappings();
    await _loadDevices(isInitialLoad: true);
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) _loadDevices();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _loadUnits() async {
    final token = widget.authService.currentToken;
    if (token == null) return;
    try {
      final config = ServerConfigService.instance.loadConfig();
      final response = await http.get(
        Uri.parse("http://${config['ip']}:${config['port']}/api/units"),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (mounted && response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true && data['units'] is List) {
          final List<dynamic> unitsList = data['units'];
          setState(
            () => units = unitsList.map((json) => Unit.fromJson(json)).toList(),
          );
        } else {
          throw Exception(
            data['message'] ??
                'Formato de resposta inválido ao carregar unidades',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Erro ao carregar unidades: $e', isError: true);
      }
    }
  }

  Future<void> _loadBssidMappings() async {
    final token = widget.authService.currentToken;
    if (token == null) return;
    try {
      final mappings = await _deviceService.fetchBssidMappings(token);
      if (mounted) {
        setState(() => bssidMappings = mappings);
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Erro ao carregar mapeamentos BSSID: $e', isError: true);
      }
    }
  }

  Future<void> _loadDevices({bool isInitialLoad = false}) async {
    final token = widget.authService.currentToken;
    if (!mounted || token == null) return;

    setState(() => isLoading = true);
    try {
      final fetchedDevices = await _deviceService.fetchDevices(token, units);
      if (mounted) {
        if (!isInitialLoad) _previousDevices = List.from(_allFetchedDevices);
        setState(() {
          _allFetchedDevices = fetchedDevices;
          if (!isInitialLoad) {
            _checkForAlerts(_previousDevices, _allFetchedDevices);
          }
          _updateDisplayedDevices();
          errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _logout() async {
    await widget.authService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoginScreen(authService: widget.authService),
        ),
      );
    }
  }

  void _updateDisplayedDevices() {
    List<Device> filteredList = List.from(_allFetchedDevices);
    if (_searchQuery.isNotEmpty) {
      filteredList = _allFetchedDevices.where((device) {
        final query = _searchQuery.toLowerCase();
        return (device.deviceName?.toLowerCase().contains(query) ?? false) ||
            (device.serialNumber?.toLowerCase().contains(query) ?? false) ||
            (device.imei?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    _totalPages = (filteredList.length / _devicesPerPage).ceil();
    if (_totalPages == 0) _totalPages = 1;
    if (_currentPage > _totalPages) _currentPage = _totalPages;

    final startIndex = (_currentPage - 1) * _devicesPerPage;
    final endIndex = (startIndex + _devicesPerPage > filteredList.length)
        ? filteredList.length
        : startIndex + _devicesPerPage;

    setState(() {
      _displayedDevices = filteredList.sublist(startIndex, endIndex);
    });
  }

  void _changePage(int direction) {
    final newPage = _currentPage + direction;
    if (newPage > 0 && newPage <= _totalPages) {
      setState(() {
        _currentPage = newPage;
        _updateDisplayedDevices();
      });
    }
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 1;
      _updateDisplayedDevices();
    });
  }

  void _checkForAlerts(List<Device> oldDevices, List<Device> newDevices) {
    if (oldDevices.isEmpty) return;
    final oldDevicesMap = {for (var d in oldDevices) d.serialNumber: d};
    for (final newDevice in newDevices) {
      final oldDevice = oldDevicesMap[newDevice.serialNumber ?? ''];
      if (oldDevice == null) continue;

      final oldOnline = isDeviceOnline(parseLastSeen(oldDevice.lastSeen));
      final newOnline = isDeviceOnline(parseLastSeen(newDevice.lastSeen));
      if (oldOnline != newOnline) {
        final lastSeenTime = parseLastSeen(newDevice.lastSeen);
        _showRealTimeAlert(
          title: 'Mudança de Status: ${newDevice.deviceName}',
          description: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('O dispositivo ficou ${newOnline ? "Online" : "Offline"}.'),
              if (!newOnline && lastSeenTime != null)
                Text(
                  'Última vez visto: ${formatDateTime(lastSeenTime)}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
            ],
          ),
          icon: newOnline ? Icons.wifi : Icons.wifi_off,
          color: newOnline ? Colors.blueAccent : Colors.orange,
          device: newDevice,
        );
      }

      final oldBattery = oldDevice.battery ?? 100;
      final newBattery = newDevice.battery ?? 100;
      if (newBattery < 20 && oldBattery >= 20) {
        _showRealTimeAlert(
          title: 'Bateria Baixa: ${newDevice.deviceName}',
          description: Text(
            'O nível da bateria atingiu ${newBattery.toInt()}%.',
          ),
          icon: Icons.battery_alert,
          color: Colors.red,
          device: newDevice,
        );
      }

      final oldLocation =
          '${oldDevice.sector ?? "N/A"} / ${oldDevice.floor ?? "N/A"}';
      final newLocation =
          '${newDevice.sector ?? "N/A"} / ${newDevice.floor ?? "N/A"}';
      if (newDevice.sector != null && oldLocation != newLocation) {
        _showRealTimeAlert(
          title: 'Mudança de Localização: ${newDevice.deviceName}',
          description: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('De: $oldLocation', style: const TextStyle(fontSize: 12)),
              Text(
                'Para: $newLocation',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          icon: Icons.location_on,
          color: Colors.purple,
          device: newDevice,
        );
      }
    }
  }

  void _showRealTimeAlert({
    required String title,
    required Widget description,
    required IconData icon,
    required Color color,
    Device? device,
  }) {
    if (!mounted) return;
    ElegantNotification(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      description: description,
      icon: Icon(icon, color: color),
      progressIndicatorColor: color,
      animation: AnimationType.fromTop,
      displayCloseButton: true,
      toastDuration: const Duration(seconds: 8),
      position: Alignment.topCenter,
      action: const Text(
        "VER DETALHES",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
      ),
      onActionPressed: () {
        if (device != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeviceDetailScreen(
                device: device,
                authService: widget.authService,
              ),
            ),
          );
        }
      },
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple.shade50, Colors.blue.shade50],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
          children: [
            if (_isSidebarVisible) _buildSidebar(),
            Expanded(
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _buildTabContent(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    final currentUser = widget.authService.currentUser;
    final role = currentUser?['role'] ?? 'user';
    final isAdmin = role == 'admin';

    return Container(
      width: 250,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF2D3748), const Color(0xFF1A202C)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white24)),
            ),
            child: Row(
              children: [
                Icon(Icons.phonelink, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                const Text(
                  'Controle MDM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  icon: Icons.dashboard,
                  title: 'Painel',
                  subtitle: 'Visão Geral',
                  index: 0,
                  selected: selectedIndex == 0,
                  onTap: (index) => setState(() => selectedIndex = index),
                ),
                _buildMenuItem(
                  icon: Icons.devices,
                  title: 'Dispositivos',
                  subtitle: 'Gerenciar',
                  index: 1,
                  selected: selectedIndex == 1,
                  onTap: (index) => setState(() => selectedIndex = index),
                ),
                if (isAdmin) ...[
                  _buildMenuItem(
                    icon: Icons.storage,
                    title: 'Servidor',
                    subtitle: 'Configuração',
                    index: 2,
                    selected: selectedIndex == 2,
                    onTap: (index) => setState(() => selectedIndex = index),
                  ),
                  _buildMenuItem(
                    icon: Icons.security,
                    title: 'Segurança',
                    subtitle: 'Gerenciar',
                    index: 3,
                    selected: selectedIndex == 3,
                    onTap: (index) => setState(() => selectedIndex = index),
                  ),
                  _buildMenuItem(
                    icon: Icons.people,
                    title: 'Usuários',
                    subtitle: 'Gerenciar',
                    index: 4,
                    selected: selectedIndex == 4,
                    onTap: (index) => setState(() => selectedIndex = index),
                  ),
                  _buildMenuItem(
                    icon: Icons.bar_chart,
                    title: 'Relatórios',
                    subtitle: 'Análises',
                    index: 5,
                    selected: selectedIndex == 5,
                    onTap: (index) => setState(() => selectedIndex = index),
                  ),
                  _buildMenuItem(
                    icon: Icons.warning,
                    title: 'Alertas',
                    subtitle: 'Notificações',
                    index: 6,
                    selected: selectedIndex == 6,
                    onTap: (index) => setState(() => selectedIndex = index),
                  ),
                  _buildMenuItem(
                    icon: Icons.business,
                    title: 'Unidades',
                    subtitle: 'Gerenciar',
                    index: 8,
                    selected: selectedIndex == 8,
                    onTap: (index) => setState(() => selectedIndex = index),
                  ),
                  _buildMenuItem(
                    icon: Icons.build,
                    title: 'Manutenção',
                    subtitle: 'Suporte',
                    index: 9,
                    selected: selectedIndex == 9,
                    onTap: (index) => setState(() => selectedIndex = index),
                  ),
                  const Divider(color: Colors.white24, indent: 16, endIndent: 16),
                  _buildMenuItem(
                    icon: Icons.bug_report_outlined,
                    title: 'Testar Alertas',
                    subtitle: 'Debug',
                    index: 10,
                    selected: selectedIndex == 10,
                    onTap: (index) => setState(() => selectedIndex = index),
                  ),
                ],
                const Divider(color: Colors.white24, indent: 16, endIndent: 16),
                _buildMenuItem(
                  icon: Icons.arrow_back,
                  title: 'Voltar',
                  subtitle: 'Menu Principal',
                  index: 99,
                  selected: false,
                  onTap: (_) => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Desenvolvedor Alexandre Calmon Jr - TI Bahia',
              style: TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required int index,
    required bool selected,
    required Function(int) onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: selected ? Colors.blue.withOpacity(0.2) : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: selected ? Colors.blue : Colors.white70),
        title: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.blue : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: selected ? Colors.blue : Colors.white70,
            fontSize: 12,
          ),
        ),
        trailing: selected ? const Icon(Icons.chevron_right, color: Colors.blue) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () => onTap(index),
      ),
    );
  }

  Widget _buildAppBar() {
    final currentUser = widget.authService.currentUser;
    final username = currentUser?['username'] ?? 'Usuário';
    final role = currentUser?['role'] ?? 'user';
    final sector = currentUser?['sector'] ?? 'N/A';

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isSidebarVisible ? Icons.menu_open : Icons.menu,
                  color: Colors.grey[600],
                ),
              ),
              onPressed: () => setState(() => _isSidebarVisible = !_isSidebarVisible),
              tooltip: 'Esconder/Mostrar Menu',
            ),
            const SizedBox(width: 12),
            Icon(Icons.dashboard, color: Colors.blue, size: 28),
            const SizedBox(width: 12),
            Text(
              'Painel de Controle MDM',
              style: TextStyle(
                color: Colors.blueGrey[800],
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        role == 'admin' ? Icons.admin_panel_settings : Icons.person,
                        size: 16,
                        color: role == 'admin' ? Colors.red[600] : Colors.blue[600],
                      ),
                      const SizedBox(width: 6),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            '${role.toUpperCase()} • $sector',
                            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                if (isLoading)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                const SizedBox(width: 15),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.refresh, color: Colors.green[700]),
                  ),
                  onPressed: () => _loadDevices(isInitialLoad: true),
                  tooltip: 'Atualizar Agora',
                ),
                const SizedBox(width: 10),
                PopupMenuButton<String>(
                  icon: CircleAvatar(
                    backgroundColor: role == 'admin' ? Colors.red[600] : Colors.blue[600],
                    child: Text(
                      username.isNotEmpty ? username[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  tooltip: 'Menu do usuário',
                  onSelected: (value) {
                    switch (value) {
                      case 'logout':
                        _showLogoutDialog();
                        break;
                      case 'change_password':
                        _showChangePasswordDialog();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'change_password',
                      child: Row(
                        children: [
                          Icon(Icons.lock, size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          const Text('Alterar Senha'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 18, color: Colors.red[600]),
                          const SizedBox(width: 8),
                          Text('Sair', style: TextStyle(color: Colors.red[600])),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    final currentUser = widget.authService.currentUser;
    final role = currentUser?['role'] ?? 'user';
    final isAdmin = role == 'admin';
    onDataRefresh() => _loadDevices(isInitialLoad: true);
    final token = widget.authService.currentToken ?? '';

    if (!isAdmin && [2, 3, 4, 5, 6, 8, 9, 10].contains(selectedIndex)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => selectedIndex = 0);
          _showSnackbar(
            "Acesso negado. Você não tem permissão.",
            isError: true,
          );
        }
      });
      return DashboardTab(
        devices: _allFetchedDevices,
        errorMessage: errorMessage,
        authService: widget.authService,
      );
    }

    switch (selectedIndex) {
      case 0:
        return DashboardTab(
          devices: _allFetchedDevices,
          errorMessage: errorMessage,
          currentUser: currentUser,
          authService: widget.authService,
        );
      case 1:
        return DevicesTab(
          devices: _displayedDevices,
          token: token,
          onDeviceUpdate: onDataRefresh,
          isReadOnly: !isAdmin,
          currentPage: _currentPage,
          totalPages: _totalPages,
          onPageChange: _changePage,
          onSearch: _performSearch,
          currentUser: widget.authService.currentUser,
          authService: widget.authService,
        );
      case 2:
        return ServerTab(serverIp: serverIp, serverPort: serverPort);
      case 3:
        return const SecurityTab();
      case 4:
        return UsersTab(authService: widget.authService);
      case 5:
        return ReportsTab(
          devices: _allFetchedDevices,
          currentUser: currentUser,
          authService: widget.authService,
        );
      case 6:
        return AlertsTab(devices: _allFetchedDevices);
      case 8:
        return UnitsTab(
          units: units,
          bssidMappings: bssidMappings,
          token: token,
          onDataUpdate: () {
            _loadUnits();
            _loadBssidMappings();
            _loadDevices();
          },
          authService: widget.authService,
        );
      case 9:
        return MaintenanceTab(
          devices: _allFetchedDevices,
          token: token,
          onDeviceUpdate: onDataRefresh,
          currentUser: widget.authService.currentUser,
          authService: widget.authService,
        );
      case 10:
        return TestTab(
          onTestAlert: ({
            required String title,
            required Widget description,
            required IconData icon,
            required Color color,
            required Device device,
          }) {
            _showRealTimeAlert(
              title: title,
              description: description,
              icon: icon,
              color: color,
              device: device,
            );
          },
        );
      default:
        return DashboardTab(
          devices: _allFetchedDevices,
          errorMessage: errorMessage,
          authService: widget.authService,
        );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Logout'),
        content: const Text('Tem certeza que deseja sair do sistema?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Alterar Senha'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrentPassword,
                  decoration: InputDecoration(
                    labelText: 'Senha Atual',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureCurrentPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () => setState(
                        () => obscureCurrentPassword = !obscureCurrentPassword,
                      ),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: 'Nova Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNewPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () => setState(
                        () => obscureNewPassword = !obscureNewPassword,
                      ),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Nova Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () => setState(
                        () => obscureConfirmPassword = !obscureConfirmPassword,
                      ),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (newPasswordController.text !=
                          confirmPasswordController.text) {
                        _showSnackbar(
                          'As senhas não coincidem',
                          isError: true,
                        );
                        return;
                      }
                      if (newPasswordController.text.length < 6) {
                        _showSnackbar(
                          'A nova senha deve ter no mínimo 6 caracteres',
                          isError: true,
                        );
                        return;
                      }
                      setState(() => isLoading = true);
                      final result = await widget.authService.changePassword(
                        currentPasswordController.text,
                        newPasswordController.text,
                      );
                      setState(() => isLoading = false);
                      if (result['success']) {
                        Navigator.of(context).pop();
                        _showSnackbar('Senha alterada com sucesso');
                      } else {
                        _showSnackbar(
                          result['message'],
                          isError: true,
                        );
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Alterar'),
            ),
          ],
        ),
      ),
    );
  }
}