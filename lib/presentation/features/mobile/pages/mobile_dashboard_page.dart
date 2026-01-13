import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:painel_windowns/core/di/injection.dart';
import 'package:painel_windowns/data/models/mobile_model.dart';
import 'package:painel_windowns/presentation/bloc/device/device_bloc.dart';
import 'package:painel_windowns/presentation/bloc/device/device_event.dart';
import 'package:painel_windowns/presentation/bloc/device/device_state.dart';
import 'package:painel_windowns/presentation/shared/widgets/navigation/custom_sidebar.dart';
import 'package:painel_windowns/presentation/shared/widgets/tabs/unified_dashboard_tab.dart';
import 'package:painel_windowns/presentation/shared/widgets/tabs/unified_list_tab.dart';
import 'package:painel_windowns/presentation/shared/widgets/tabs/unified_maintenance_tab.dart';
import 'package:painel_windowns/presentation/shared/utils/widget_adapters.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/data/models/asset_module_base_model.dart';

/// Dashboard de dispositivos móveis usando widgets unificados
class MobileDashboardPage extends StatefulWidget {
  const MobileDashboardPage({required this.authService, super.key});
  final AuthService authService;

  @override
  State<MobileDashboardPage> createState() => _MobileDashboardPageState();
}

class _MobileDashboardPageState extends State<MobileDashboardPage> {
  int selectedIndex = 0;
  bool _isSidebarVisible = true;

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = '';
  final int _itemsPerPage = 15;

  List<Device> _displayedDevices = [];

  void _updateDisplayedDevices(List<Device> allDevices) {
    List<Device> filteredList = List.from(allDevices);

    if (_searchQuery.isNotEmpty) {
      filteredList =
          allDevices.where((device) {
            final query = _searchQuery.toLowerCase();
            return (device.deviceName.toLowerCase().contains(query)) ||
                (device.serialNumber.toLowerCase().contains(query)) ||
                (device.location?.toLowerCase().contains(query) ?? false);
          }).toList();
    }

    _totalPages = (filteredList.length / _itemsPerPage).ceil();
    if (_totalPages == 0) _totalPages = 1;
    if (_currentPage > _totalPages) _currentPage = _totalPages;

    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex =
        (startIndex + _itemsPerPage > filteredList.length)
            ? filteredList.length
            : startIndex + _itemsPerPage;

    setState(() {
      _displayedDevices = filteredList.sublist(startIndex, endIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<DeviceBloc>()..add(const LoadDevices()),
      child: BlocBuilder<DeviceBloc, DeviceState>(
        builder: (context, state) {
          // Convert DeviceEntity to Device
          final allDevices =
              state is DeviceLoaded
                  ? state.devices
                      .map(
                        (entity) => Device(
                          id: entity.id,
                          deviceName: entity.deviceName ?? 'Unknown',
                          serialNumber: entity.serialNumber ?? 'N/A',
                          status: entity.status ?? 'offline',
                          lastSeen:
                              entity.lastSeen ?? DateTime.now().toString(),
                          location: entity.location,
                          unit: entity.unit,
                          sector: entity.sector,
                          floor: entity.floor,
                          battery: entity.battery,
                        ),
                      )
                      .toList()
                  : <Device>[];

          // Convert Device to ManagedAsset for unified widgets
          final managedAssets =
              allDevices
                  .map(
                    (device) => _DeviceAsset(
                      id: device.id,
                      assetName: device.deviceName,
                      assetType: 'mobile',
                      serialNumber: device.serialNumber,
                      status: device.status,
                      lastSeen:
                          DateTime.tryParse(device.lastSeen) ?? DateTime.now(),
                      location: device.location,
                      unit: device.unit,
                      sector: device.sector,
                      floor: device.floor,
                      customData: {
                        'battery': device.battery?.toString() ?? 'N/A',
                      },
                    ),
                  )
                  .toList();

          _updateDisplayedDevices(allDevices);

          // Prepare columns and config
          final columns = convertTableColumns([
            TableColumnConfig(dataKey: 'assetName', label: 'Nome'),
            TableColumnConfig(dataKey: 'serialNumber', label: 'Serial'),
            TableColumnConfig(dataKey: 'status', label: 'Status'),
            TableColumnConfig(dataKey: 'location', label: 'Localização'),
            TableColumnConfig(dataKey: 'lastSeen', label: 'Última Conexão'),
          ]);
          final config = createAssetCardConfig('mobile_devices_export');

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
                  if (_isSidebarVisible) _buildSidebar(allDevices),
                  Expanded(
                    child: Column(
                      children: [
                        _buildAppBar(state),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: _buildTabContent(managedAssets, state),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(DeviceState state) {
    final currentUser = widget.authService.currentUser;
    final username = currentUser?['username'] ?? 'Usuário';

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
              icon: Icon(
                _isSidebarVisible ? Icons.menu_open : Icons.menu,
                color: Colors.grey[600],
              ),
              onPressed:
                  () => setState(() => _isSidebarVisible = !_isSidebarVisible),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.phone_android, color: Colors.blue, size: 28),
            const SizedBox(width: 12),
            Text(
              'Dispositivos Móveis',
              style: TextStyle(
                color: Colors.blueGrey[800],
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(username.toString()),
            const SizedBox(width: 15),
            if (state is DeviceLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(List<ManagedAsset> assets, DeviceState state) {
    final columns = convertTableColumns([
      TableColumnConfig(dataKey: 'assetName', label: 'Nome'),
      TableColumnConfig(dataKey: 'serialNumber', label: 'Serial'),
      TableColumnConfig(dataKey: 'status', label: 'Status'),
      TableColumnConfig(dataKey: 'location', label: 'Localização'),
    ]);
    final config = createAssetCardConfig('mobile_export');

    switch (selectedIndex) {
      case 0: // Dashboard
        final stats = generateDashboardStats(assets, 'Mobile');
        return UnifiedDashboardTab<ManagedAsset>(
          items: assets,
          columns: columns,
          config: config,
          stats: stats,
          title: 'Dashboard - Dispositivos Móveis',
          showActions: true,
        );

      case 1: // Lista
        return UnifiedListTab<ManagedAsset>(
          items:
              _displayedDevices
                  .map(
                    (d) => _DeviceAsset(
                      id: d.id,
                      assetName: d.deviceName,
                      assetType: 'mobile',
                      serialNumber: d.serialNumber,
                      status: d.status,
                      lastSeen: DateTime.tryParse(d.lastSeen) ?? DateTime.now(),
                      location: d.location,
                      unit: d.unit,
                      sector: d.sector,
                      floor: d.floor,
                    ),
                  )
                  .toList(),
          columns: columns,
          config: config,
          currentPage: _currentPage,
          totalPages: _totalPages,
          onPageChange: (direction) {
            setState(() {
              _currentPage += direction;
            });
          },
          onSearch: (query) {
            setState(() {
              _searchQuery = query;
              _currentPage = 1;
            });
          },
          title: 'Dispositivos Móveis',
          isLoading: state is DeviceLoading,
        );

      case 2: // Manutenção
        final maintenanceAssets =
            assets
                .where((a) => a.status.toLowerCase() == 'maintenance')
                .toList();
        return UnifiedMaintenanceTab<ManagedAsset>(
          items: maintenanceAssets,
          columns: columns,
          config: config,
          moduleTypeName: 'Dispositivos Móveis',
        );

      default:
        final stats = generateDashboardStats(assets, 'Mobile');
        return UnifiedDashboardTab<ManagedAsset>(
          items: assets,
          columns: columns,
          config: config,
          stats: stats,
          title: 'Dashboard - Dispositivos Móveis',
        );
    }
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
        icon: Icons.phone_android,
        title: 'Dispositivos',
        subtitle: 'Lista Completa',
        index: 1,
      ),
      const SidebarMenuItem(
        icon: Icons.build,
        title: 'Manutenção',
        subtitle: 'Gestão',
        index: 2,
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
      selectedIndex: selectedIndex,
      onItemTap: (index) {
        if (index == 99) {
          Navigator.of(context).pop();
        } else {
          setState(() => selectedIndex = index);
        }
      },
      footerText: '${devices.length} dispositivos',
    );
  }
}

// Helper class to convert Device to ManagedAsset
class _DeviceAsset extends ManagedAsset {
  _DeviceAsset({
    required super.id,
    required super.assetName,
    required super.assetType,
    required super.serialNumber,
    required super.status,
    required super.lastSeen,
    super.location,
    super.unit,
    super.sector,
    super.floor,
    super.customData,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'asset_name': assetName,
      'asset_type': assetType,
      'serial_number': serialNumber,
      'status': status,
      'last_seen': lastSeen.toIso8601String(),
      'location': location,
      'unit': unit,
      'sector': sector,
      'floor': floor,
      'custom_data': customData,
    };
  }
}
