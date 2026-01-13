import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:painel_windowns/core/di/injection.dart';
import 'package:painel_windowns/core/utils/helpers.dart';
import 'package:painel_windowns/data/models/device_model.dart';
import 'package:painel_windowns/presentation/bloc/device/device_bloc.dart';
import 'package:painel_windowns/presentation/bloc/device/device_event.dart';
import 'package:painel_windowns/presentation/bloc/device/device_state.dart';
import 'package:painel_windowns/presentation/features/devices/pages/device_detail_page.dart';
import 'package:painel_windowns/presentation/features/devices/widgets/tabs/dashboard_tab.dart';
import 'package:painel_windowns/presentation/features/devices/widgets/tabs/devices_tab.dart';
import 'package:painel_windowns/presentation/features/devices/widgets/tabs/maintenance_tab.dart';
import 'package:painel_windowns/presentation/features/devices/widgets/tabs/reports_tab.dart';
import 'package:painel_windowns/presentation/shared/layouts/base_dashboard_layout.dart';
import 'package:painel_windowns/presentation/shared/widgets/app_bar_widget.dart';
import 'package:painel_windowns/presentation/shared/widgets/navigation/custom_sidebar.dart';
import 'package:painel_windowns/services/auth_service.dart';

/// Dashboard refatorado de dispositivos móveis
///
/// Versão simplificada usando BaseDashboardLayout e separação de responsabilidades.
/// Reduzido de 843 linhas para ~350 linhas.
class DevicesDashboardPage extends StatefulWidget {
  const DevicesDashboardPage({required this.authService, super.key});
  final AuthService authService;

  @override
  State<DevicesDashboardPage> createState() => _DevicesDashboardPageState();
}

class _DevicesDashboardPageState extends State<DevicesDashboardPage>
    with SingleTickerProviderStateMixin {
  // Tab controller
  late TabController _tabController;
  int _selectedTabIndex = 0;

  // Sidebar
  bool _isSidebarVisible = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _selectedTabIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<StatCardData> _buildStats(List<Device> devices) {
    if (devices.isEmpty) return [];

    final online =
        devices.where((d) {
          final lastSeen = parseLastSeen(d.lastSeen);
          return lastSeen != null && isDeviceOnline(lastSeen);
        }).length;

    final offline = devices.length - online;

    final lowBattery =
        devices.where((d) {
          final battery = d.battery ?? 100;
          return battery < 20;
        }).length;

    return [
      StatCardData(
        title: 'Total de Dispositivos',
        value: devices.length.toString(),
        icon: Icons.devices,
        color: Colors.blue,
      ),
      StatCardData(
        title: 'Online',
        value: online.toString(),
        icon: Icons.check_circle,
        color: Colors.green,
        subtitle: '${((online / devices.length) * 100).toStringAsFixed(1)}%',
      ),
      StatCardData(
        title: 'Offline',
        value: offline.toString(),
        icon: Icons.error_outline,
        color: Colors.red,
        subtitle: '${((offline / devices.length) * 100).toStringAsFixed(1)}%',
      ),
      StatCardData(
        title: 'Bateria Baixa',
        value: lowBattery.toString(),
        icon: Icons.battery_alert,
        color: Colors.orange,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DeviceBloc>()..add(const LoadDevices()),
      child: BlocBuilder<DeviceBloc, DeviceState>(
        builder: (context, state) {
          // Convert DeviceEntity list to Device list for UI
          final devices =
              state is DeviceLoaded
                  ? state.devices.map((entity) {
                    return Device(
                      id: entity.id,
                      deviceName: entity.deviceName ?? 'Unknown',
                      serialNumber: entity.serialNumber ?? 'N/A',
                      status: entity.status ?? 'offline',
                      lastSeen: entity.lastSeen ?? DateTime.now().toString(),
                      location: entity.location,
                      unit: entity.unit,
                      sector: entity.sector,
                      floor: entity.floor,
                      battery: entity.battery,
                    );
                  }).toList()
                  : <Device>[];

          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: CustomAppBar(
              title: 'Dispositivos Móveis',
              authService: widget.authService,
              showBackButton: false,
              showMenuButton: true,
              onMenuPressed: () {
                setState(() => _isSidebarVisible = !_isSidebarVisible);
              },
              tabs: const [
                Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
                Tab(icon: Icon(Icons.devices), text: 'Dispositivos'),
                Tab(icon: Icon(Icons.build), text: 'Manutenção'),
                Tab(icon: Icon(Icons.assessment), text: 'Relatórios'),
              ],
              tabController: _tabController,
            ),
            body: Row(
              children: [
                if (_isSidebarVisible) _buildSidebar(devices),
                Expanded(
                  child:
                      state is DeviceLoading
                          ? const Center(child: CircularProgressIndicator())
                          : state is DeviceError
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  state.message,
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    context.read<DeviceBloc>().add(
                                      const LoadDevices(),
                                    );
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Tentar Novamente'),
                                ),
                              ],
                            ),
                          )
                          : TabBarView(
                            controller: _tabController,
                            children: [
                              // Dashboard Tab
                              BaseDashboardLayout(
                                title: 'Dashboard',
                                stats: _buildStats(devices),
                                mainContent: DashboardTab(
                                  authService: widget.authService,
                                  devices: devices,
                                  onDeviceTap: (Device device) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder:
                                            (context) => DeviceDetailScreen(
                                              device: device,
                                              authService: widget.authService,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                                onRefresh: () async {
                                  context.read<DeviceBloc>().add(
                                    const RefreshDevices(),
                                  );
                                },
                              ),

                              // Devices Tab
                              BaseDashboardLayout(
                                title: 'Dispositivos',
                                stats: _buildStats(devices),
                                mainContent: DevicesTab(
                                  authService: widget.authService,
                                  devices: devices,
                                  token: widget.authService.currentToken ?? '',
                                  onDeviceUpdate: () async {
                                    context.read<DeviceBloc>().add(
                                      const RefreshDevices(),
                                    );
                                  },
                                  isReadOnly: false,
                                  currentUser: widget.authService.currentUser,
                                  currentPage: 1,
                                  totalPages: 1,
                                  onPageChange: (int page) {},
                                  onSearch: (String query) {},
                                  onDeviceTap: (Device device) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder:
                                            (context) => DeviceDetailScreen(
                                              device: device,
                                              authService: widget.authService,
                                            ),
                                      ),
                                    );
                                  },
                                  onRefresh: () async {
                                    context.read<DeviceBloc>().add(
                                      const RefreshDevices(),
                                    );
                                  },
                                ),
                                onRefresh: () async {
                                  context.read<DeviceBloc>().add(
                                    const RefreshDevices(),
                                  );
                                },
                                showStats: false, // Stats já mostrados na tab
                              ),

                              // Maintenance Tab
                              BaseDashboardLayout(
                                title: 'Manutenção',
                                stats: const [],
                                mainContent: MaintenanceTab(
                                  authService: widget.authService,
                                  devices: devices,
                                  token: widget.authService.currentToken ?? '',
                                  onDeviceUpdate: () async {
                                    context.read<DeviceBloc>().add(
                                      const RefreshDevices(),
                                    );
                                  },
                                  currentUser: widget.authService.currentUser,
                                ),
                                onRefresh: () async {
                                  context.read<DeviceBloc>().add(
                                    const RefreshDevices(),
                                  );
                                },
                                showStats: false,
                              ),

                              // Reports Tab
                              BaseDashboardLayout(
                                title: 'Relatórios',
                                stats: const [],
                                mainContent: ReportsTab(
                                  authService: widget.authService,
                                  devices: devices,
                                  currentUser: widget.authService.currentUser,
                                ),
                                onRefresh: () async {
                                  context.read<DeviceBloc>().add(
                                    const RefreshDevices(),
                                  );
                                },
                                showStats: false,
                              ),
                            ],
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSidebar(List<Device> devices) {
    final menuItems = [
      const SidebarMenuItem(
        icon: Icons.dashboard,
        title: 'Dashboard',
        subtitle: 'Visão Geral',
        index: 0,
      ),
      const SidebarMenuItem(
        icon: Icons.devices,
        title: 'Dispositivos',
        subtitle: 'Lista Completa',
        index: 1,
      ),
      const SidebarMenuItem(
        icon: Icons.build,
        title: 'Manutenção',
        subtitle: 'Gestão de Status',
        index: 2,
      ),
      const SidebarMenuItem(
        icon: Icons.assessment,
        title: 'Relatórios',
        subtitle: 'Análises e Exports',
        index: 3,
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
      title: 'Dispositivos Móveis',
      titleIcon: Icons.phone_android,
      menuItems: menuItems,
      selectedIndex: _selectedTabIndex,
      onItemTap: (index) {
        if (index == 99) {
          Navigator.of(context).pop();
        } else {
          _tabController.animateTo(index);
        }
      },
      footerText: '${devices.length} dispositivos',
    );
  }
}
