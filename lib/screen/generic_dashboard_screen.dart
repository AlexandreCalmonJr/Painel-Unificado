// File: lib/screens/generic_dashboard_screen.dart

import 'dart:async';

import 'package:flutter/material.dart';
// Imports dos Modelos e Serviços
import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/models/bssid_mapping.dart';
// Imports dos Modelos Específicos (Ajuste os caminhos)
import 'package:painel_windowns/models/unit.dart';
import 'package:painel_windowns/modules/tabs/generic_assets_list_tab.dart';
import 'package:painel_windowns/modules/tabs/generic_dashboard_tab.dart';
import 'package:painel_windowns/modules/tabs/generic_maintenance_tab.dart';
import 'package:painel_windowns/modules/tabs/generic_permissions_tab.dart';
import 'package:painel_windowns/screen/asset_comparison_screen.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/module_management_service.dart';




class GenericDashboardScreen extends StatefulWidget {
  final AuthService authService;
  final AssetModuleConfig moduleConfig;

  const GenericDashboardScreen({
    super.key,
    required this.authService,
    required this.moduleConfig,
  });

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

  // ✅ ESTADO PARA GERENCIAR SELEÇÃO
  List<ManagedAsset> _selectedAssets = [];

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
    setState(() => isLoading = true);
    await _loadUnits();
    await _loadBssidMappings();
    await _loadAssets(isInitialLoad: true);
    setState(() => isLoading = false);

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

  Future<void> _loadUnits() async {
    try {
      final fetchedUnits = await _moduleService.fetchUnits();
      if (mounted) {
        setState(() {
          _units = fetchedUnits;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Erro fatal ao carregar unidades: $e', isError: true);
      }
    }
  }

  Future<void> _loadAssets({bool isInitialLoad = false}) async {
    if (!mounted) return;
    if (isInitialLoad) setState(() => isLoading = true);

    try {
      final List<ManagedAsset> parsedAssets =
          await _moduleService.listModuleAssetsTyped(
        moduleId: widget.moduleConfig.id,
        moduleType: widget.moduleConfig.type,
        units: _units,
        bssidMappings: _bssidMappings,
      );

      if (mounted) {
        setState(() {
          _allAssets = parsedAssets;
          _updateDisplayedAssets();
          // Limpa seleção ao recarregar
          _selectedAssets.clear();
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

  Future<void> _loadBssidMappings() async {
    try {
      final fetchedBssids = await _moduleService.fetchBssidMappings();
      if (mounted) {
        setState(() {
          _bssidMappings = fetchedBssids;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('Erro ao carregar BSSIDs: $e', isError: true);
      }
    }
  }

  void _updateDisplayedAssets() {
    List<ManagedAsset> filteredList = List.from(_allAssets);
    if (_searchQuery.isNotEmpty) {
      filteredList = _allAssets.where((asset) {
        final query = _searchQuery.toLowerCase();
        return (asset.assetName.toLowerCase().contains(query)) ||
            (asset.serialNumber.toLowerCase().contains(query)) ||
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

  // ✅ FUNÇÃO DE CALLBACK PARA ATUALIZAR A SELEÇÃO
  void _onSelectionChanged(List<ManagedAsset> selected) {
    setState(() {
      _selectedAssets = selected;
    });
  }

  // ✅ FUNÇÃO PARA NAVEGAR PARA A TELA DE COMPARAÇÃO
  void _navigateToComparisonScreen() {
    if (_selectedAssets.length < 2) {
      _showSnackbar('Selecione pelo menos 2 ativos para comparar.',
          isError: true);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssetComparisonScreen(
          selectedAssets: _selectedAssets,
          moduleConfig: widget.moduleConfig,
        ),
      ),
    );
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

  // --- Dialogs de Edição/Exclusão ---
  Future<void> _showEditAssetDialog(ManagedAsset asset) async {
    _showSnackbar('Função "Editar" para ${asset.assetName} não implementada.',
        isError: true);
    _loadAssets(isInitialLoad: true);
  }

  Future<void> _showDeleteAssetDialog(ManagedAsset asset) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: Text(
              'Tem certeza que deseja excluir o ativo "${asset.assetName}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _moduleService.deleteAsset(
            moduleId: widget.moduleConfig.id, assetId: asset.id);
        _showSnackbar('Ativo excluído com sucesso');
        _loadAssets(isInitialLoad: true); // Recarrega a lista
      } catch (e) {
        _showSnackbar('Erro ao excluir: $e', isError: true);
      }
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

  // --- BUILD ---
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
                  _buildAppBar(), // ✅ APPBAR ATUALIZADO
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _buildTabContent(), // ✅ TABCONTENT ATUALIZADO
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
                Icon(_getModuleIcon(), color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.moduleConfig.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                  icon: _getModuleIcon(),
                  title: widget.moduleConfig.name,
                  subtitle: 'Listar Todos',
                  index: 1,
                  selected: selectedIndex == 1,
                  onTap: (index) => setState(() => selectedIndex = index),
                ),
                _buildMenuItem(
                  icon: Icons.build_outlined,
                  title: 'Manutenção',
                  subtitle: 'Gerenciar Ativos',
                  index: 2,
                  selected: selectedIndex == 2,
                  onTap: (index) => setState(() => selectedIndex = index),
                ),
                if (isAdmin)
                  _buildMenuItem(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Permissões',
                    subtitle: 'Gerenciar Usuários',
                    index: 3,
                    selected: selectedIndex == 3,
                    onTap: (index) => setState(() => selectedIndex = index),
                  ),
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
        trailing:
            selected ? const Icon(Icons.chevron_right, color: Colors.blue) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          // Limpa a seleção ao trocar de aba
          if (index != 1) {
            setState(() => _selectedAssets.clear());
          }
          onTap(index);
        },
      ),
    );
  }

  Widget _buildAppBar() {
    final currentUser = widget.authService.currentUser;
    final username = currentUser?['username'] ?? 'Usuário';

    // ✅ LÓGICA DO BOTÃO DE COMPARAÇÃO
    final bool showCompareButton =
        selectedIndex == 1 && _selectedAssets.length >= 2;

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        username,
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

                // ✅ BOTÃO DE COMPARAÇÃO CONDICIONAL
                if (showCompareButton)
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: ElevatedButton.icon(
                      onPressed: _navigateToComparisonScreen,
                      icon: const Icon(Icons.compare_arrows, size: 18),
                      label: Text('Comparar (${_selectedAssets.length})'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),

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
    final columns = widget.moduleConfig.tableColumns;

    switch (selectedIndex) {
      // Aba 0: Painel (Visão Geral)
      case 0:
        return GenericDashboardTab(
            allAssets: _allAssets,
            onRefresh: () => _loadAssets(isInitialLoad: true),
            getModuleIcon: _getModuleIcon,
            moduleType: widget.moduleConfig.type.displayName,
            columns: columns,
            authService: widget.authService,
            moduleConfig: widget.moduleConfig);

      // Aba 1: Lista de Ativos (Nome dinâmico)
      case 1:
        return GenericAssetsListTab(
            displayedAssets: _displayedAssets,
            isLoading: isLoading,
            currentPage: _currentPage,
            totalPages: _totalPages,
            onPageChange: _changePage,
            onSearch: _performSearch,
            onRefresh: () => _loadAssets(isInitialLoad: true),
            onAssetUpdate: (asset) => _showEditAssetDialog(asset),
            onAssetDelete: (asset) => _showDeleteAssetDialog(asset),
            columns: columns,
            authService: widget.authService,
            moduleConfig: widget.moduleConfig,
            // ✅ PASSANDO A LISTA E A FUNÇÃO PARA A TAB
            selectedAssets: _selectedAssets,
            onSelectionChanged: _onSelectionChanged,
        );

      // Aba 2: Manutenção (Nova)
      case 2:
        return GenericMaintenanceTab(
          allAssets: _allAssets,
          moduleConfig: widget.moduleConfig,
          moduleService: _moduleService,
          onRefresh: () => _loadAssets(isInitialLoad: true),
          showSnackbar: _showSnackbar,
          onEditAsset: (asset) => _showEditAssetDialog(asset),
          onDeleteAsset: (asset) => _showDeleteAssetDialog(asset),
          columns: columns,
          authService: widget.authService,
        );

      // Aba 3: Permissões (Nova)
      case 3:
        return GenericPermissionsTab(
          moduleId: widget.moduleConfig.id,
          moduleName: widget.moduleConfig.name,
          authService: widget.authService,
          moduleService: _moduleService,
        );

      default:
        return GenericDashboardTab(
            allAssets: _allAssets,
            onRefresh: () => _loadAssets(isInitialLoad: true),
            getModuleIcon: _getModuleIcon,
            moduleType: widget.moduleConfig.type.displayName,
            columns: columns,
            authService: widget.authService,
            moduleConfig: widget.moduleConfig);
    }
  }
}