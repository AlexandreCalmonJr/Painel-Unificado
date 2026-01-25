import 'package:flutter/material.dart';

import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/data/models/asset_module_base_model.dart';
import 'package:painel_windowns/data/models/module.dart';
import 'package:painel_windowns/presentation/shared/utils/widget_adapters.dart';
import 'package:painel_windowns/presentation/shared/widgets/navigation/custom_sidebar.dart';
import 'package:painel_windowns/presentation/shared/widgets/navigation/unified_custom_app_bar.dart';
import 'package:painel_windowns/presentation/shared/widgets/states/empty_state.dart';
import 'package:painel_windowns/presentation/shared/widgets/states/loading_overlay.dart';
import 'package:painel_windowns/presentation/shared/widgets/tabs/unified_dashboard_tab.dart';
import 'package:painel_windowns/presentation/shared/widgets/tabs/unified_list_tab.dart';
import 'package:painel_windowns/presentation/shared/widgets/controls/unified_command_controls.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/module_management_service.dart';

class ModuleDetailsPage extends StatefulWidget {
  const ModuleDetailsPage({
    required this.module,
    required this.authService,
    super.key,
  });

  final Module module;
  final AuthService authService;

  @override
  State<ModuleDetailsPage> createState() => _ModuleDetailsPageState();
}

class _ModuleDetailsPageState extends State<ModuleDetailsPage> {
  late ModuleManagementService _moduleService;
  List<ManagedAsset> _assets = [];
  bool _isLoading = true;
  String? _error;

  int _selectedIndex = 0;
  bool _isSidebarVisible = true;

  // Pagination & Search
  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = '';
  final int _itemsPerPage = 15;
  List<ManagedAsset> _displayedAssets = [];

  @override
  void initState() {
    super.initState();
    _moduleService = ModuleManagementService(authService: widget.authService);
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final units = await _moduleService.fetchUnits();
      final bssids = await _moduleService.fetchBssidMappings();

      final assets = await _moduleService.listModuleAssetsTyped(
        moduleId: widget.module.id,
        moduleType: widget.module.type,
        units: units,
        bssidMappings: bssids,
      );

      if (mounted) {
        setState(() {
          _assets = assets;
          _isLoading = false;
          _updateDisplayedAssets();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _updateDisplayedAssets() {
    List<ManagedAsset> filteredList = List.from(_assets);

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredList =
          _assets.where((asset) {
            return asset.assetName.toLowerCase().contains(query) ||
                asset.serialNumber.toLowerCase().contains(query) ||
                (asset.location?.toLowerCase().contains(query) ?? false);
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
      _displayedAssets = filteredList.sublist(startIndex, endIndex);
    });
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
                  UnifiedCustomAppBar(
                    title: widget.module.name,
                    icon: widget.module.icon,
                    authService: widget.authService,
                    isSidebarVisible: _isSidebarVisible,
                    onMenuPressed:
                        () => setState(
                          () => _isSidebarVisible = !_isSidebarVisible,
                        ),
                    iconColor: AppColors.primary, // Or use generic blue/purple
                    actions: [
                      if (_isLoading)
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
                      const SizedBox(width: 10),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.refresh, color: Colors.green[700]),
                        ),
                        onPressed: _loadAssets,
                        tooltip: 'Atualizar',
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _buildContent(),
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
    final menuItems = [
      const SidebarMenuItem(
        icon: Icons.dashboard,
        title: 'Visão Geral',
        subtitle: 'Dashboard',
        index: 0,
      ),
      const SidebarMenuItem(
        icon: Icons.list,
        title: 'Lista de Ativos',
        subtitle: 'Gerenciar',
        index: 1,
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
      title: widget.module.name,
      titleIcon: widget.module.icon,
      menuItems: menuItems,
      selectedIndex: _selectedIndex,
      onItemTap: (index) {
        if (index == 99) {
          Navigator.of(context).pop();
        } else {
          setState(() => _selectedIndex = index);
        }
      },
      footerText: '${_assets.length} itens',
    );
  }

  Widget _buildContent() {
    if (_isLoading && _assets.isEmpty) {
      return const LoadingIndicator(message: 'Carregando ativos do módulo...');
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
            const SizedBox(height: 16),
            Text('Erro ao carregar dados: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAssets,
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_assets.isEmpty) {
      return EmptyStateVariants.noData(
        title: 'Nenhum ativo encontrado',
        subtitle: 'Este módulo ainda não possui ativos vinculados.',
      );
    }

    final List<TableColumnConfig> columnConfigs =
        widget.module.tableColumns.isNotEmpty
            ? widget.module.tableColumns
                .map((c) => TableColumnConfig.fromJson(c))
                .toList()
            : <TableColumnConfig>[
              TableColumnConfig(dataKey: 'assetName', label: 'Nome'),
              TableColumnConfig(dataKey: 'serialNumber', label: 'Serial'),
              TableColumnConfig(dataKey: 'status', label: 'Status'),
              TableColumnConfig(dataKey: 'location', label: 'Localização'),
            ];

    final columns = convertTableColumns(columnConfigs);

    // Use a generic export key or derived from module type
    final config = createAssetCardConfig(
      '${widget.module.type.name}_export'.toLowerCase(),
    );

    switch (_selectedIndex) {
      case 0: // Dashboard
        final stats = generateDashboardStats(
          _assets,
          widget.module.type.displayName,
        );
        return UnifiedDashboardTab<ManagedAsset>(
          items: _assets,
          columns: columns,
          config: config,
          stats: stats,
          title: 'Visão Geral - ${widget.module.name}',
          showActions: true,
          actions: (asset) => _buildActions(asset),
          onAssetTap:
              (asset) async {}, // Details usually read-only or via dialog
        );

      case 1: // List
        return UnifiedListTab<ManagedAsset>(
          items: _displayedAssets,
          columns: columns,
          config: config,
          currentPage: _currentPage,
          totalPages: _totalPages,
          onPageChange: (direction) {
            setState(() {
              _currentPage += direction;
              _updateDisplayedAssets(); // Re-slice
            });
          },
          onSearch: (query) {
            setState(() {
              _searchQuery = query;
              _currentPage = 1;
              _updateDisplayedAssets();
            });
          },
          title: 'Lista de Ativos',
          isLoading: _isLoading,
          showActions: true,
          actions: (asset) => _buildActions(asset),
          onAssetTap: (asset) async {},
        );

      default:
        return Container();
    }
  }

  Widget _buildActions(ManagedAsset asset) {
    return UnifiedCommandControls<ManagedAsset>(
      item: asset,
      authService: widget.authService,
      token: widget.authService.currentToken,
      config: CommandConfig<ManagedAsset>(
        moduleId: widget.module.id,
        getAssetId: (item) => item.id,
        getSerialNumber:
            (item) =>
                item.serialNumber, // Assuming serial is used as ID for some commands
        getStatus: (item) => item.status,
      ),
      onCommandExecuted: _loadAssets, // Reload list after command
    );
  }
}
