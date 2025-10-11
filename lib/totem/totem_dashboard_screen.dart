import 'dart:async';

import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:painel_windowns/login_screen.dart';
import 'package:painel_windowns/models/totem.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/monitoring_service.dart';
import 'package:painel_windowns/totem/tabs/totems_list_tab.dart';
import 'package:painel_windowns/totem/widgets/managed_devices_card.dart';
import 'package:painel_windowns/widgets/menu_item.dart';
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
  
  // Instância do MonitoringService
  late final MonitoringService _monitoringService;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Cria a instância do serviço passando o authService
    _monitoringService = MonitoringService(authService: widget.authService);
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadTotems(isInitialLoad: true);
    // Auto-refresh a cada 15 segundos
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
      // Usa o MonitoringService para buscar os totens
      final fetchedTotems = await _monitoringService.getTotems();
      
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
        
        // Mostra um snackbar com o erro
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 200,
      color: const Color(0xFF2D3748),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: const Text(
              'Módulo Totem',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                MenuItem(
                  icon: Icons.dashboard,
                  title: 'Painel',
                  subtitle: 'Visão Geral',
                  index: 0,
                  selectedIndex: selectedIndex,
                  onTap: (index) => setState(() => selectedIndex = index),
                ),
                MenuItem(
                  icon: Icons.desktop_windows,
                  title: 'Totens',
                  subtitle: 'Listar Dispositivos',
                  index: 1,
                  selectedIndex: selectedIndex,
                  onTap: (index) => setState(() => selectedIndex = index),
                ),
                const Divider(color: Colors.white24, indent: 16, endIndent: 16),
                MenuItem(
                  icon: Icons.arrow_back,
                  title: 'Voltar',
                  subtitle: 'Menu Principal',
                  index: 99,
                  selectedIndex: selectedIndex,
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

  Widget _buildAppBar() {
    final currentUser = widget.authService.currentUser;
    final username = currentUser?['username'] ?? 'Usuário';
    final role = currentUser?['role'] ?? 'user';

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
                _isSidebarVisible ? Icons.menu_open : Icons.menu,
                color: Colors.grey[600]),
            onPressed: () =>
                setState(() => _isSidebarVisible = !_isSidebarVisible),
            tooltip: 'Esconder/Mostrar Menu',
          ),
          const SizedBox(width: 10),
          Text(
            'Monitoramento de Totens',
            style: TextStyle(
              color: Colors.blueGrey[800],
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
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
                Text(
                  username,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          if (isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          const SizedBox(width: 15),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.grey[600]),
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
                    color: Colors.white, fontWeight: FontWeight.bold),
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
          const Text('Visão Geral dos Totens',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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