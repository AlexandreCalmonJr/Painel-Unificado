import 'dart:async';

import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:painel_windowns/core/utils/helpers.dart';
import 'package:painel_windowns/core/utils/test_tab.dart';

import 'package:painel_windowns/data/models/bssid_mapping.dart';
import 'package:painel_windowns/data/models/device_model.dart';
import 'package:painel_windowns/data/models/unit_model.dart';
import 'package:painel_windowns/presentation/features/auth/pages/login_page.dart';
import 'package:painel_windowns/presentation/features/devices/pages/device_detail_page.dart';
import 'package:painel_windowns/presentation/features/devices/widgets/tabs/dashboard_tab.dart';
import 'package:painel_windowns/presentation/features/devices/widgets/tabs/devices_tab.dart';
import 'package:painel_windowns/presentation/features/devices/widgets/tabs/maintenance_tab.dart';
import 'package:painel_windowns/presentation/shared/widgets/navigation/custom_sidebar.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/device_service.dart';

class MDMDashboard extends StatefulWidget {
  const MDMDashboard({required this.authService, super.key});
  final AuthService authService;

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
      // ✅ CORREÇÃO: Usando o DeviceService centralizado
      final fetchedUnits = await _deviceService.fetchUnits(token);
      if (mounted) {
        setState(() => units = fetchedUnits);
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
          _allFetchedDevices = fetchedDevices as List<Device>;
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
      filteredList =
          _allFetchedDevices.where((device) {
            final query = _searchQuery.toLowerCase();
            return (device.deviceName?.toLowerCase().contains(query) ??
                    false) ||
                (device.serialNumber?.toLowerCase().contains(query) ?? false) ||
                (device.imei?.toLowerCase().contains(query) ?? false);
          }).toList();
    }

    _totalPages = (filteredList.length / _devicesPerPage).ceil();
    if (_totalPages == 0) _totalPages = 1;
    if (_currentPage > _totalPages) _currentPage = _totalPages;

    final startIndex = (_currentPage - 1) * _devicesPerPage;
    final endIndex =
        (startIndex + _devicesPerPage > filteredList.length)
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
    final oldDevicesMap = {for (final d in oldDevices) d.serialNumber: d};
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
        'VER DETALHES',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
      ),
      onActionPressed: () {
        if (device != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => DeviceDetailScreen(
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
    return Scaffold(
      backgroundColor: Colors.grey[50], // Clean background
      body: Row(
        children: [
          if (_isSidebarVisible) _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _buildTabContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final currentUser = widget.authService.currentUser;
    final role = currentUser?['role'] ?? 'user';
    final isAdmin = role == 'admin';

    final menuItems = [
      const SidebarMenuItem(
        icon: Icons.dashboard_outlined,
        title: 'Painel',
        subtitle: 'Visão Geral',
        index: 0,
      ),
      const SidebarMenuItem(
        icon: Icons.devices_outlined,
        title: 'Dispositivos',
        subtitle: 'Gerenciar',
        index: 1,
      ),
      const SidebarMenuItem(
        icon: Icons.bar_chart_outlined,
        title: 'Relatórios',
        subtitle: 'Análises',
        index: 5,
        isAdminOnly: true,
      ),
      const SidebarMenuItem(
        icon: Icons.build_outlined,
        title: 'Manutenção',
        subtitle: 'Suporte',
        index: 9,
        isAdminOnly: true,
      ),
      const SidebarMenuItem(
        icon: Icons.bug_report_outlined,
        title: 'Testar Alertas',
        subtitle: 'Debug',
        index: 10,
        isAdminOnly: true,
        showDividerBefore: true,
      ),
      const SidebarMenuItem(
        icon: Icons.arrow_back,
        title: 'Voltar',
        subtitle: 'Menu Principal',
        index: 99,
        showDividerBefore: true,
      ),
    ];

    return CustomSidebar(
      title: 'Controle MDM',
      titleIcon: Icons.phonelink_setup,
      menuItems: menuItems,
      selectedIndex: selectedIndex,
      onItemTap: (index) {
        if (index == 99) {
          Navigator.of(context).pop();
        } else {
          setState(() => selectedIndex = index);
        }
      },
      isAdmin: isAdmin,
      footerText: 'Desenvolvedor Alexandre Calmon Jr - TI Bahia',
    );
  }

  Widget _buildAppBar() {
    final currentUser = widget.authService.currentUser;
    final username = currentUser?['username'] ?? 'Usuário';
    final role = currentUser?['role'] ?? 'user';
    final sector = currentUser?['sector'] ?? 'N/A';

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isSidebarVisible ? Icons.menu_open : Icons.menu,
              color: Colors.grey[700],
            ),
            onPressed:
                () => setState(() => _isSidebarVisible = !_isSidebarVisible),
            tooltip: 'Alternar Menu',
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Painel de Controle',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Visão Geral do Sistema',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor:
                          role == 'admin' ? Colors.red[50] : Colors.blue[50],
                      child: Icon(
                        role == 'admin'
                            ? Icons.admin_panel_settings
                            : Icons.person,
                        size: 16,
                        color:
                            role == 'admin'
                                ? Colors.red[700]
                                : Colors.blue[700],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          '${role.toUpperCase()} • $sector',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(Icons.refresh, color: Colors.grey[600]),
                onPressed: () => _loadDevices(isInitialLoad: true),
                tooltip: 'Atualizar Dados',
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                offset: const Offset(0, 40),
                icon: CircleAvatar(
                  backgroundColor:
                      role == 'admin' ? Colors.red[700] : Colors.blue[700],
                  child: Text(
                    username.isNotEmpty
                        ? username[0].toUpperCase()
                        : 'U',
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
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'change_password',
                        child: Row(
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 20,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 12),
                            const Text('Alterar Senha'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout,
                              size: 20,
                              color: Colors.red[600],
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Sair',
                              style: TextStyle(color: Colors.red[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    final currentUser = widget.authService.currentUser;
    final role = currentUser?['role'] ?? 'user';
    final isAdmin = role == 'admin';
    Future<void> onDataRefresh() => _loadDevices(isInitialLoad: true);
    final token = widget.authService.currentToken ?? '';

    if (!isAdmin && [2, 3, 4, 5, 6, 8, 9, 10].contains(selectedIndex)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => selectedIndex = 0);
          _showSnackbar(
            'Acesso negado. Você não tem permissão.',
            isError: true,
          );
        }
      });
      return DashboardTab(
        devices: _allFetchedDevices,
        errorMessage: errorMessage,
        authService: widget.authService,
        onDeviceTap: (Device device) {},
      );
    }

    switch (selectedIndex) {
      case 0:
        return DashboardTab(
          devices: _allFetchedDevices,
          errorMessage: errorMessage,
          currentUser: currentUser,
          authService: widget.authService,
          onDeviceTap: (Device device) {},
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
          onDeviceTap: (Device device) {},
          onRefresh: () async {},
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
          onDeviceTap: (Device device) {},
        );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
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
                              onPressed:
                                  () => setState(
                                    () =>
                                        obscureCurrentPassword =
                                            !obscureCurrentPassword,
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
                              onPressed:
                                  () => setState(
                                    () =>
                                        obscureNewPassword =
                                            !obscureNewPassword,
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
                              onPressed:
                                  () => setState(
                                    () =>
                                        obscureConfirmPassword =
                                            !obscureConfirmPassword,
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
                      onPressed:
                          isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed:
                          isLoading
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
                                final result = await widget.authService
                                    .changePassword(
                                      currentPasswordController.text,
                                      newPasswordController.text,
                                    );
                                setState(() => isLoading = false);
                                if (result['success'] as bool) {
                                  Navigator.of(context).pop();
                                  _showSnackbar('Senha alterada com sucesso');
                                } else {
                                  _showSnackbar(
                                    result['message'] as String,
                                    isError: true,
                                  );
                                }
                              },
                      child:
                          isLoading
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text('Alterar'),
                    ),
                  ],
                ),
          ),
    );
  }
}
