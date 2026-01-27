import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:painel_windowns/core/di/injection.dart';
import 'package:painel_windowns/data/models/asset_module_base_model.dart';
import 'package:painel_windowns/data/models/totem_model.dart';
import 'package:painel_windowns/presentation/bloc/totem/totem_bloc.dart';
import 'package:painel_windowns/presentation/bloc/totem/totem_event.dart';
import 'package:painel_windowns/presentation/bloc/totem/totem_state.dart';
import 'package:painel_windowns/presentation/features/auth/pages/login_page.dart';
import 'package:painel_windowns/presentation/shared/utils/widget_adapters.dart';
import 'package:painel_windowns/presentation/shared/widgets/controls/unified_command_controls.dart'
    hide SendCommandDialog;
import 'package:painel_windowns/presentation/shared/widgets/dialogs/send_command_dialog.dart';
import 'package:painel_windowns/presentation/shared/widgets/menus/base_command_menu.dart';
import 'package:painel_windowns/presentation/shared/widgets/navigation/custom_sidebar.dart';
import 'package:painel_windowns/presentation/shared/widgets/tabs/unified_dashboard_tab.dart';
import 'package:painel_windowns/presentation/shared/widgets/tabs/unified_list_tab.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/device_service.dart';

class TotemDashboardScreen extends StatefulWidget {
  const TotemDashboardScreen({required this.authService, super.key});
  final AuthService authService;

  @override
  // ignore: library_private_types_in_public_api
  _TotemDashboardScreenState createState() => _TotemDashboardScreenState();
}

class _TotemDashboardScreenState extends State<TotemDashboardScreen> {
  int selectedIndex = 0;
  bool _isSidebarVisible = true;

  // Pagination and search state
  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = '';
  final int _itemsPerPage = 15;

  // Selection state for generic list tab
  List<Totem> _selectedTotems = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _logout() async {
    await widget.authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (context) => LoginScreen(authService: widget.authService),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  List<Totem> _updateDisplayedTotems(List<Totem> allTotems) {
    List<Totem> filteredList = List.from(allTotems);

    if (_searchQuery.isNotEmpty) {
      filteredList =
          allTotems.where((totem) {
            final query = _searchQuery.toLowerCase();
            return (totem.hostname.toLowerCase()).contains(query) ||
                (totem.serialNumber.toLowerCase()).contains(query) ||
                (totem.ip.toLowerCase()).contains(query) ||
                (totem.unit?.toLowerCase().contains(query) ?? false) ||
                (totem.location?.toLowerCase().contains(query) ?? false);
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

    return filteredList.sublist(startIndex, endIndex);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TotemBloc>()..add(const LoadTotems()),
      child: BlocBuilder<TotemBloc, TotemState>(
        builder: (context, state) {
          // Converter TotemEntity para Totem (model)
          final allTotems =
              state is TotemLoaded
                  ? state.totems
                      .map((entity) => Totem.fromEntity(entity))
                      .toList()
                  : <Totem>[];

          // Aplicar pagina��o e busca
          final displayedTotems = _updateDisplayedTotems(allTotems);

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
                  if (_isSidebarVisible) _buildSidebar(allTotems),
                  Expanded(
                    child: Column(
                      children: [
                        _buildAppBar(state, context),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: _buildTabContent(
                              displayedTotems,
                              allTotems,
                              state,
                              context,
                            ),
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

  Widget _buildSidebar(List<Totem> allTotems) {
    final menuItems = [
      const SidebarMenuItem(
        icon: Icons.dashboard,
        title: 'Painel',
        subtitle: 'Vis�o Geral',
        index: 0,
      ),
      const SidebarMenuItem(
        icon: Icons.desktop_windows,
        title: 'Totens',
        subtitle: 'Listar Dispositivos',
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
      title: 'M�dulo Totem',
      titleIcon: Icons.desktop_windows,
      menuItems: menuItems,
      selectedIndex: selectedIndex,
      onItemTap: (index) {
        if (index == 99) {
          Navigator.of(context).pop();
        } else {
          setState(() => selectedIndex = index);
        }
      },
      isAdmin: false,
      footerText: '${allTotems.length} totens',
    );
  }

  Widget _buildAppBar(TotemState state, BuildContext context) {
    final currentUser = widget.authService.currentUser;
    final username = currentUser?['username'] ?? 'Usu�rio';
    final role = currentUser?['role'] ?? 'user';

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
              onPressed:
                  () => setState(() => _isSidebarVisible = !_isSidebarVisible),
              tooltip: 'Esconder/Mostrar Menu',
            ),
            const SizedBox(width: 12),
            const Icon(Icons.desktop_windows, color: Colors.blue, size: 28),
            const SizedBox(width: 12),
            Text(
              'Monitoramento de Totens',
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
                      Icon(
                        role == 'admin'
                            ? Icons.admin_panel_settings
                            : Icons.person,
                        size: 16,
                        color:
                            role == 'admin'
                                ? Colors.red[600]
                                : Colors.blue[600],
                      ),
                      const SizedBox(width: 6),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            role.toString().toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        state is TotemLoading
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child:
                      state is TotemLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const SizedBox.shrink(),
                ),
                const SizedBox(width: 15),

                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.location_on, color: Colors.purple[700]),
                  ),
                  onPressed: () {
                    context.read<TotemBloc>().add(const LoadTotems());
                  },
                  tooltip: 'For�ar Atualiza��o de Localiza��es (Recarregar)',
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.refresh, color: Colors.green[700]),
                  ),
                  onPressed: () {
                    context.read<TotemBloc>().add(const RefreshTotems());
                  },
                  tooltip: 'Atualizar Agora',
                ),
                const SizedBox(width: 10),
                PopupMenuButton<String>(
                  icon: CircleAvatar(
                    backgroundColor:
                        role == 'admin' ? Colors.red[600] : Colors.blue[600],
                    child: Text(
                      username.toString().isNotEmpty
                          ? username.toString()[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  tooltip: 'Menu do usu�rio',
                  onSelected: (value) {
                    if (value == 'logout') {
                      _showLogoutDialog();
                    }
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(
                                Icons.logout,
                                size: 18,
                                color: Colors.red[600],
                              ),
                              const SizedBox(width: 8),
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
      ),
    );
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

  Widget _buildTabContent(
    List<Totem> displayedTotems,
    List<Totem> allTotems,
    TotemState state,
    BuildContext context,
  ) {
    switch (selectedIndex) {
      case 0:
        return _buildDashboardWithTable(allTotems);
      case 1:

        // Convert table columns and create config
        final columns = convertTableColumns([
          TableColumnConfig(dataKey: 'hostname', label: 'Hostname'),
          TableColumnConfig(dataKey: 'status', label: 'Status'),
          TableColumnConfig(dataKey: 'serialNumber', label: 'Serial'),
          TableColumnConfig(dataKey: 'location', label: 'Localização'),
        ]);
        final config = createAssetCardConfig('totens_export');

        return UnifiedListTab<ManagedAsset>(
          items: displayedTotems.cast<ManagedAsset>(),
          columns: columns,
          config: config,
          currentPage: _currentPage,
          totalPages: _totalPages,
          onPageChange: (direction) {
            setState(() {
              final newPage = _currentPage + direction;
              if (newPage > 0 && newPage <= _totalPages) {
                _currentPage = newPage;
              }
            });
          },
          onSearch: (query) {
            setState(() {
              _searchQuery = query;
              _currentPage = 1;
            });
          },
          title: 'Totens',
          searchHint: 'Buscar por hostname, IP, localização...',
          searchLabel: 'Buscar Totens',
          onAssetTap: (ManagedAsset asset) async {},
          isLoading: state is TotemLoading,
          showActions: true,
          actions: (asset) => _buildActions(asset),
        );
      default:
        return _buildDashboardWithTable(allTotems);
    }
  }

  Widget _buildDashboardWithTable(List<Totem> allTotems) {
    final onlineCount =
        allTotems.where((t) => t.status.toLowerCase() == 'online').length;
    final offlineCount =
        allTotems.where((t) => t.status.toLowerCase() == 'offline').length;
    final errorCount =
        allTotems.where((t) => t.status.toLowerCase() == 'com erro').length;

    // Convert to ManagedAsset for unified widgets
    final managedAssets = allTotems.cast<ManagedAsset>();

    // Create dashboard stats
    final stats = [
      DashboardStat(
        title: 'Total de Totens',
        value: allTotems.length.toString(),
        icon: Icons.desktop_windows,
        color: Colors.blue,
      ),
      DashboardStat(
        title: 'Online',
        value: onlineCount.toString(),
        icon: Icons.wifi,
        color: Colors.green,
      ),
      DashboardStat(
        title: 'Offline',
        value: offlineCount.toString(),
        icon: Icons.wifi_off,
        color: Colors.red,
      ),
      DashboardStat(
        title: 'Com Erro',
        value: errorCount.toString(),
        icon: Icons.warning,
        color: Colors.orange,
      ),
    ];

    final columns = convertTableColumns([
      TableColumnConfig(dataKey: 'hostname', label: 'Hostname'),
      TableColumnConfig(dataKey: 'status', label: 'Status'),
      TableColumnConfig(dataKey: 'serialNumber', label: 'Serial'),
      TableColumnConfig(dataKey: 'location', label: 'Localização'),
    ]);
    final config = createAssetCardConfig('totens_export');

    return UnifiedDashboardTab<ManagedAsset>(
      items: managedAssets,
      columns: columns,
      config: config,
      stats: stats,
      title: 'Visão Geral dos Totens',
      showActions: false,
      actions: (asset) => _buildActions(asset),
      onAssetTap: (ManagedAsset asset) async {},
    );
  }

  Widget _buildActions(ManagedAsset asset) {
    return UnifiedCommandControls<ManagedAsset>(
      item: asset,
      authService: widget.authService,
      token: widget.authService.currentToken,
      customActions: [
        CommandAction<ManagedAsset>(
          label: 'Enviar Comando',
          icon: Icons.terminal,
          onTap: (context, item) async {
            await showDialog<void>(
              context: context,
              builder:
                  (context) => SendCommandDialog(
                    asset: item,
                    moduleId: '',
                    authService: widget.authService,
                    onCommandSent: () {},
                  ),
            );
          },
          color: Colors.blue,
        ),
        CommandAction<ManagedAsset>(
          label: 'Excluir Totem',
          icon: Icons.delete_forever,
          onTap: (context, item) async {
            await _deleteTotem(context, item);
          },
          requiresConfirmation: true,
          confirmTitle: 'Excluir Totem?',
          confirmMessage:
              'Tem certeza que deseja excluir este totem? A ação é irreversível.',
          isDestructive: true,
          color: Colors.red,
        ),
      ],
      onCommandExecuted:
          () => context.read<TotemBloc>().add(const LoadTotems()),
    );
  }

  Future<void> _deleteTotem(BuildContext context, ManagedAsset asset) async {
    try {
      final service = getIt<DeviceService>();
      await service.deleteTotem(asset.serialNumber);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Totem excluído com sucesso')),
        );
        context.read<TotemBloc>().add(const LoadTotems());
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
