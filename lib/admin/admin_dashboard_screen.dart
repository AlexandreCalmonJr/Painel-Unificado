import 'package:flutter/material.dart';
import 'package:painel_windowns/admin/tabs/admin_locations_tab.dart';
import 'package:painel_windowns/admin/tabs/admin_users_tab.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/widgets/menu_item.dart';


class AdminDashboardScreen extends StatefulWidget {
  final AuthService authService;
  const AdminDashboardScreen({super.key, required this.authService});

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int selectedIndex = 0;
  bool _isSidebarVisible = true;

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
            child: const Text('Administrativo',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView(
              children: [
                MenuItem(
                  icon: Icons.people,
                  title: 'Utilizadores',
                  subtitle: 'Gerir acessos',
                  index: 0,
                  selectedIndex: selectedIndex,
                  onTap: (index) => setState(() => selectedIndex = index),
                ),
                MenuItem(
                  icon: Icons.location_on,
                  title: 'Localizações',
                  subtitle: 'Mapeamento de IP',
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
                  selectedIndex: -1, // Para nunca ficar selecionado
                  onTap: (_) => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    final currentUser = widget.authService.currentUser;
    final username = currentUser?['username'] ?? 'Usuário';

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
              offset: const Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(_isSidebarVisible ? Icons.menu_open : Icons.menu,
                color: Colors.grey[600]),
            onPressed: () =>
                setState(() => _isSidebarVisible = !_isSidebarVisible),
            tooltip: 'Esconder/Mostrar Menu',
          ),
          const SizedBox(width: 10),
          Text('Gestão do Sistema',
              style: TextStyle(
                  color: Colors.blueGrey[800],
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const Spacer(),
          Text('Bem-vindo, $username'),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedIndex) {
      case 0:
        return AdminUsersTab(authService: widget.authService);
      case 1:
        return AdminLocationsTab(authService: widget.authService);
      default:
        return AdminUsersTab(authService: widget.authService);
    }
  }
}