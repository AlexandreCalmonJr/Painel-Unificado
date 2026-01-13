// File: lib/screens/module_dashboard_screen.dart (CORRIGIDO)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:painel_windowns/data/models/asset_module_base_model.dart';
import 'package:painel_windowns/data/models/bssid_mapping.dart';
import 'package:painel_windowns/data/models/unit_model.dart';
import 'package:painel_windowns/presentation/features/modules/pages/asset_detail_screen.dart';
import 'package:painel_windowns/presentation/screens/asset_detail_screen.dart';
import 'package:painel_windowns/presentation/shared/utils/widget_adapters.dart';
import 'package:painel_windowns/presentation/shared/widgets/navigation/custom_sidebar.dart';
import 'package:painel_windowns/presentation/shared/widgets/tabs/unified_dashboard_tab.dart';
import 'package:painel_windowns/presentation/shared/widgets/tabs/unified_list_tab.dart';
import 'package:painel_windowns/presentation/shared/widgets/tabs/unified_maintenance_tab.dart';
import 'package:painel_windowns/presentation/shared/widgets/tabs/unified_permissions_tab.dart' hide ModuleManagementService;
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/module_management_service.dart';

class GenericDashboardScreen extends StatefulWidget {
  const GenericDashboardScreen({
    required this.authService,
    required this.moduleConfig,
    super.key,
  });
  final AuthService authService;
  final AssetModuleConfig moduleConfig;

  @override
  State<GenericDashboardScreen> createState() => _GenericDashboardScreenState();
}

class _GenericDashboardScreenState extends State<GenericDashboardScreen> {
  int selectedIndex = 0;
  bool _isSidebarVisible = true;

  List<ManagedAsset> _allAssets = [];
  List<ManagedAsset> _displayedAssets = [];
  List<Unit> _units = [];
  List<BssidMapping> _bssidMappings = [];

  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = '';
  final int _itemsPerPage = 15;

  bool isLoading = false;
  String? errorMessage;

  late final ModuleManagementService _moduleService;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _moduleService = ModuleManagementService(authService: widget.authService);
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    await _loadUnits();
    await _loadBssidMappings();
    await _loadAssets(isInitialLoad: true);
    if (mounted) {
      setState(() => isLoading = false);
    }

    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadAssets(isInitialLoad: false);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  /// Carrega a lista de unidades
  Future<void> _loadUnits() async {
    try {
      final dynamic fetched = await _moduleService.fetchUnits();
      final List<Unit> fetchedUnits = (fetched is List) ? fetched.cast<Unit>() : <Unit>[];
      if (mounted) {
        setState(() {
          _units = fetchedUnits;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Erro ao carregar unidades: $e', isError: true);
      }
    }
  }

  Future<void> _loadBssidMappings() async {
    try {
      final fetchedBssids = await _moduleService.fetchBssidMappings();
      final List<BssidMapping> parsedBssids =
          (fetchedBssids is List) ? fetchedBssids.cast<BssidMapping>() : <BssidMapping>[];
      if (mounted) {
        setState(() {
          _bssidMappings = parsedBssids;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Erro ao carregar BSSIDs: $e', isError: true);
      }
    }
  }

  /// Carrega os ativos do módulo
  Future<void> _loadAssets({bool isInitialLoad = false}) async {
    if (!mounted) return;
    if (isInitialLoad) setState(() => isLoading = true);

    try {
      final dynamic result = await _moduleService.listModuleAssetsTyped(
        moduleId: widget.moduleConfig.id,
        moduleType: widget.moduleConfig.type,
        units: _units,
        bssidMappings: _bssidMappings,
      );
      final List<ManagedAsset> parsedAssets =
          (result is List) ? (result as List).cast<ManagedAsset>() : <ManagedAsset>[];

      if (mounted) {
        setState(() {
          _allAssets = parsedAssets;
          _updateDisplayedAssets();
          errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Falha ao carregar ativos: ${e.toString()}';
        });
        _showSnackbar(errorMessage!, isError: true);
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _updateDisplayedAssets() {
    List<ManagedAsset> filteredList = List.from(_allAssets);
    if (_searchQuery.isNotEmpty) {
      filteredList = _allAssets.where((asset) {
        final query = _searchQuery.toLowerCase();
        return (asset.assetName.toLowerCase()).contains(query) ||
            (asset.serialNumber.toLowerCase()).contains(query) ||
            (asset.location?.toLowerCase().contains(query) ?? false) ||
            (asset.sector?.toLowerCase().contains(query) ?? false) ||
            (asset.floor?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
    _totalPages = (filteredList.length / _itemsPerPage).ceil();
    if (_totalPages == 0) _totalPages = 1;
    if (_currentPage > _totalPages) _currentPage = _totalPages;
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage > filteredList.length)
        ? filteredList.length
        : startIndex + _itemsPerPage;
    setState(() {
      _displayedAssets = filteredList.sublist(startIndex, endIndex);
    });
  }

  void _changePage(int direction) {
    final newPage = _currentPage + direction;
    if (newPage > 0 && newPage <= _totalPages) {
      setState(() {
        _currentPage = newPage;
        _updateDisplayedAssets();
      });
    }
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 1;
      _updateDisplayedAssets();
    });
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // CORREÇÃO: Método para navegar e tratar retorno
  Future<void> _navigateToAssetDetail(ManagedAsset asset) async {
    final shouldReload = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AssetDetailScreen(
          asset: asset,
          authService: widget.authService,
          moduleConfig: widget.moduleConfig,
        ),
      ),
    );

    // Se retornou true, recarregar os dados
    if (shouldReload == true && mounted) {
      await _loadAssets(isInitialLoad: true);
      _showSnackbar('Dados atualizados com sucesso!');
    }
  }

  IconData _getModuleIcon() {
    switch (widget.moduleConfig.type.iconName) {
      case 'phone_android':
        return Icons.phone_android;
      case 'desktop_windows':
        return Icons.desktop_windows;
      case 'computer':
        return Icons.computer;
      case 'laptop':
        return Icons.laptop;
      case 'tv':
        return Icons.tv;
      case 'print':
        return Icons.print;
      case 'qr_code_scanner':
        return Icons.qr_code_scanner;
      default:
        return Icons.category;
    }
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
    final bool isAdmin = widget.authService.isAdmin;

    final menuItems = [
      const SidebarMenuItem(
        icon: Icons.dashboard,
        title: 'Painel',
        subtitle: 'Visão Geral',
        index: 0,
      ),
      SidebarMenuItem(
        icon: _getModuleIcon(),
        title: widget.moduleConfig.name,
        subtitle: 'Listar Todos',
        index: 1,
      ),
      const SidebarMenuItem(
        icon: Icons.build_outlined,
        title: 'Manutenção',
        subtitle: 'Gerenciar Ativos',
        index: 2,
      ),
      const SidebarMenuItem(
        icon: Icons.admin_panel_settings_outlined,
        title: 'Permissões',
        subtitle: 'Gerenciar Usuários',
        index: 3,
        isAdminOnly: true,
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
      title: widget.moduleConfig.name,
      titleIcon: _getModuleIcon(),
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
    );
  }

  Widget _buildAppBar() {
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
              onPressed: () =>
                  setState(() => _isSidebarVisible = !_isSidebarVisible),
              tooltip: 'Esconder/Mostrar Menu',
            ),
            const SizedBox(width: 12),
            Icon(_getModuleIcon(), color: Colors.blue, size: 28),
            const SizedBox(width: 12),
            Text(
              widget.moduleConfig.name,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.blue[600]),
                      const SizedBox(width: 6),
                      Text(
                        username as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
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
                  onPressed: () => _loadAssets(isInitialLoad: true),
                  tooltip: 'Atualizar Agora',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    final columns = convertTableColumns(widget.moduleConfig.tableColumns);
    final config = createAssetCardConfig('${widget.moduleConfig.name}_export');

    switch (selectedIndex) {
      case 0:
        final stats = generateDashboardStats(
          _allAssets,
          widget.moduleConfig.type.displayName,
        );
        return UnifiedDashboardTab<ManagedAsset>(
          items: _allAssets,
          columns: columns,
          config: config,
          stats: stats,
          title: 'Painel - ${widget.moduleConfig.name}',
          showActions: true,
          onAssetTap: _navigateToAssetDetail, // CORREÇÃO: Adicionar callback
        );

      case 1:
        return UnifiedListTab<ManagedAsset>(
          items: _displayedAssets,
          columns: columns,
          config: config,
          currentPage: _currentPage,
          totalPages: _totalPages,
          onPageChange: _changePage,
          onSearch: _performSearch,
          title: widget.moduleConfig.name,
          searchHint: 'Buscar por nome, serial, localização...',
          searchLabel: 'Buscar ${widget.moduleConfig.name}',
          showActions: true,
          isLoading: isLoading,
          onAssetTap: _navigateToAssetDetail, // CORREÇÃO: Adicionar callback
        );

      case 2:
        final maintenanceAssets = _allAssets
            .where((a) => a.status.toLowerCase() == 'maintenance')
            .toList();
        return UnifiedMaintenanceTab<ManagedAsset>(
          items: maintenanceAssets,
          columns: columns,
          config: config,
          moduleTypeName: widget.moduleConfig.name,
          showActions: true,
          onAssetTap: _navigateToAssetDetail, // CORREÇÃO: Adicionar callback
        );

      case 3:
        return UnifiedPermissionsTab(
          moduleId: widget.moduleConfig.id,
          moduleName: widget.moduleConfig.name,
          authService: widget.authService,
          moduleService: _moduleService as dynamic,
        );

      default:
        final stats = generateDashboardStats(
          _allAssets,
          widget.moduleConfig.type.displayName,
        );
        return UnifiedDashboardTab<ManagedAsset>(
          items: _allAssets,
          columns: columns,
          config: config,
          stats: stats,
          title: 'Painel - ${widget.moduleConfig.name}',
          showActions: true,
          onAssetTap: _navigateToAssetDetail, // CORREÇÃO: Adicionar callback
        );
    }
  }
}