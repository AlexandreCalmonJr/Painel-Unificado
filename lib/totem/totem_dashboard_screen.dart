import 'dart:async';

import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:painel_windowns/login_screen.dart';
import 'package:painel_windowns/models/totem.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/totem/tabs/totems_list_tab.dart';
import 'package:painel_windowns/totem/widgets/managed_devices_card.dart';
import 'package:painel_windowns/widgets/stat_card.dart';

class TotemDashboardScreen extends StatefulWidget {
  final AuthService authService;
  const TotemDashboardScreen({super.key, required this.authService});

  @override
  _TotemDashboardScreenState createState() => _TotemDashboardScreenState();
}

class _TotemDashboardScreenState extends State<TotemDashboardScreen> {
  int selectedIndex = 0;
  bool _isSidebarVisible = true;
  List<Totem> _previousTotems = [];

  List<Totem> _allFetchedTotems = [];
  List<Totem> _displayedTotems = [];
  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = '';
  final int _itemsPerPage = 15;

  bool isLoading = false;
  String? errorMessage;

  late final MonitoringService _monitoringService;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _monitoringService = MonitoringService(authService: widget.authService);
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadTotems(isInitialLoad: true);
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) _loadTotems();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTotems({bool isInitialLoad = false}) async {
    if (!mounted) return;

    setState(() => isLoading = true);
    try {
      final fetchedTotems = await _monitoringService.getTotems(
        refreshMappings: isInitialLoad,
      );

      if (mounted) {
        if (!isInitialLoad) {
          _previousTotems = List.from(_allFetchedTotems);
        }

        setState(() {
          _allFetchedTotems = fetchedTotems;

          if (!isInitialLoad) {
            _checkForAlerts(_previousTotems, _allFetchedTotems);
          }

          _updateDisplayedTotems();
          errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Falha ao carregar totens: ${e.toString()}';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Tentar Novamente',
              textColor: Colors.white,
              onPressed: () => _loadTotems(isInitialLoad: true),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _logout() async {
    await widget.authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => LoginScreen(authService: widget.authService)),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _updateDisplayedTotems() {
    List<Totem> filteredList = List.from(_allFetchedTotems);

    if (_searchQuery.isNotEmpty) {
      filteredList = _allFetchedTotems.where((totem) {
        final query = _searchQuery.toLowerCase();
        return (totem.hostname.toLowerCase().contains(query)) ||
            (totem.serialNumber.toLowerCase().contains(query)) ||
            (totem.ip.toLowerCase().contains(query)) ||
            (totem.location.toLowerCase().contains(query));
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
      _displayedTotems = filteredList.sublist(startIndex, endIndex);
    });
  }

  void _changePage(int direction) {
    final newPage = _currentPage + direction;
    if (newPage > 0 && newPage <= _totalPages) {
      setState(() {
        _currentPage = newPage;
        _updateDisplayedTotems();
      });
    }
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 1;
      _updateDisplayedTotems();
    });
  }

  void _checkForAlerts(List<Totem> oldTotems, List<Totem> newTotems) {
    if (oldTotems.isEmpty) return;
    final oldTotemsMap = {for (var t in oldTotems) t.serialNumber: t};

    for (final newTotem in newTotems) {
      final oldTotem = oldTotemsMap[newTotem.serialNumber];
      if (oldTotem == null) continue;

      final oldStatus = oldTotem.status.toLowerCase();
      final newStatus = newTotem.status.toLowerCase();

      if (oldStatus != newStatus) {
        _showRealTimeAlert(
          title: 'Mudança de Status: ${newTotem.hostname}',
          description: Text(
              'O totem em "${newTotem.location}" ficou ${newStatus == 'online' ? 'Online' : 'Offline'}.'),
          icon: newStatus == 'online' ? Icons.wifi : Icons.wifi_off,
          color: newStatus == 'online' ? Colors.blueAccent : Colors.orange,
        );
      }
    }
  }

  void _showRealTimeAlert({
    required String title,
    required Widget description,
    required IconData icon,
    required Color color,
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
                Icon(Icons.desktop_windows, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                const Text(
                  'Módulo Totem',
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
                  icon: Icons.desktop_windows,
                  title: 'Totens',
                  subtitle: 'Listar Dispositivos',
                  index: 1,
                  selected: selectedIndex == 1,
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
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Desenvolvido por Alexandre Calmon',
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
                            role.toUpperCase(),
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
                      color: Colors.purple.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.location_on, color: Colors.purple[700]),
                  ),
                  onPressed: () {
                    _monitoringService.invalidateMappingsCache();
                    _loadTotems(isInitialLoad: true);
                  },
                  tooltip: 'Atualizar Mapeamentos de Localização',
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
                  onPressed: () => _loadTotems(isInitialLoad: true),
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
                  itemBuilder: (context) => [
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

  Widget _buildTabContent() {
    switch (selectedIndex) {
      case 0:
        return _buildDashboardWithTable();
      case 1:
        return TotemsListTab(
          totems: _displayedTotems,
          isLoading: isLoading,
          currentPage: _currentPage,
          totalPages: _totalPages,
          onPageChange: _changePage,
          onSearch: _performSearch,
          onRefresh: () => _loadTotems(isInitialLoad: true),
          authService: widget.authService,
        );
      default:
        return _buildDashboardWithTable();
    }
  }

  Widget _buildDashboardWithTable() {
    int onlineCount = _allFetchedTotems
        .where((t) => t.status.toLowerCase() == 'online')
        .length;
    int offlineCount = _allFetchedTotems
        .where((t) => t.status.toLowerCase() == 'offline')
        .length;
    int errorCount = _allFetchedTotems
        .where((t) => t.status.toLowerCase() == 'com erro')
        .length;

    return RefreshIndicator(
      onRefresh: () => _loadTotems(isInitialLoad: true),
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
                  value: _allFetchedTotems.length.toString(),
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
              title: 'Totens Gerenciados (${_allFetchedTotems.length})',
              totems: _allFetchedTotems,
              authService: widget.authService,
              onTotemUpdate: () => _loadTotems(isInitialLoad: true),
            ),
          ),
        ],
      ),
    );
  }
}

class MonitoringService {
  final AuthService authService;

  MonitoringService({required this.authService});

  void monitorTotems() {
    String Final(
      
      String input,
    ) {

      return input;
    }

  }
  
  void invalidateMappingsCache() {}
  
  Future getTotems({required bool refreshMappings}) async {}
  
}