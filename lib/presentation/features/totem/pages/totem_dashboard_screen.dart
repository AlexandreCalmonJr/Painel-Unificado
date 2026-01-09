import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:painel_windowns/core/di/injection.dart';
import 'package:painel_windowns/data/models/totem_model.dart';
import 'package:painel_windowns/presentation/bloc/totem/totem_bloc.dart';
import 'package:painel_windowns/presentation/bloc/totem/totem_event.dart';
import 'package:painel_windowns/presentation/bloc/totem/totem_state.dart';
import 'package:painel_windowns/presentation/features/auth/pages/login_page.dart';
import 'package:painel_windowns/presentation/features/totem/widgets/totems_list_tab.dart';
import 'package:painel_windowns/presentation/shared/widgets/cards/stat_card.dart';
import 'package:painel_windowns/presentation/shared/widgets/navigation/custom_sidebar.dart';
import 'package:painel_windowns/services/auth_service.dart';

class TotemDashboardScreen extends StatefulWidget {
  final AuthService authService;
  const TotemDashboardScreen({super.key, required this.authService});

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
            return (totem.hostname.toLowerCase().contains(query)) ||
                (totem.serialNumber.toLowerCase().contains(query)) ||
                (totem.ip.toLowerCase().contains(query)) ||
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

          // Aplicar paginação e busca
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
        subtitle: 'Visão Geral',
        index: 0,
      ),
      const SidebarMenuItem(
        icon: Icons.desktop_windows,
        title: 'Totens',
        subtitle: 'Listar Dispositivos',
        index: 1,
      ),
      SidebarMenuItem(
        icon: Icons.arrow_back,
        title: 'Voltar',
        subtitle: 'Menu Principal',
        index: 99,
        showDividerBefore: true,
      ),
    ];

    return CustomSidebar(
      title: 'Módulo Totem',
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
    final username = currentUser?['username'] ?? 'Usuário';
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
            Icon(Icons.desktop_windows, color: Colors.blue, size: 28),
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
                            username,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            role.toUpperCase(),
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
                  tooltip: 'Forçar Atualização de Localizações (Recarregar)',
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
                      username.isNotEmpty ? username[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  tooltip: 'Menu do usuário',
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
        return TotemsListTab(
          totems: displayedTotems,
          isLoading: state is TotemLoading,
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
          onRefresh: () => context.read<TotemBloc>().add(const RefreshTotems()),
          authService: widget.authService,
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

    return RefreshIndicator(
      onRefresh: () async {
        context.read<TotemBloc>().add(const RefreshTotems());
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visão Geral dos Totens',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[800],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Total de Totens',
                  value: allTotems.length.toString(),
                  icon: Icons.desktop_windows,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: StatCard(
                  title: 'Online',
                  value: onlineCount.toString(),
                  icon: Icons.wifi,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: StatCard(
                  title: 'Offline',
                  value: offlineCount.toString(),
                  icon: Icons.wifi_off,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: StatCard(
                  title: 'Com Erro',
                  value: errorCount.toString(),
                  icon: Icons.warning,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ManagedTotemsCard(
              title: 'Totens Gerenciados (${allTotems.length})',
              totems: allTotems,
              authService: widget.authService,
              onTotemUpdate:
                  () => context.read<TotemBloc>().add(const RefreshTotems()),
            ),
          ),
        ],
      ),
    );
  }
}
