// File: lib/admin/admin_dashboard_screen.dart (ATUALIZADO)
import 'package:flutter/material.dart';
import 'package:painel_windowns/admin/tabs/admin_locations_tab.dart';
import 'package:painel_windowns/admin/tabs/admin_modules_tab.dart';
import 'package:painel_windowns/admin/tabs/admin_users_tab.dart';
import 'package:painel_windowns/services/auth_service.dart';

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
                Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                const Text(
                  'Administrativo',
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
                  icon: Icons.people,
                  title: 'Utilizadores',
                  subtitle: 'Gerir acessos',
                  index: 0,
                  selected: selectedIndex == 0,
                  onTap: (index) => setState(() => selectedIndex = index),
                ),
                _buildMenuItem(
                  icon: Icons.location_on,
                  title: 'Localização',
                  subtitle: 'Mapeamento de IP',
                  index: 1,
                  selected: selectedIndex == 1,
                  onTap: (index) => setState(() => selectedIndex = index),
                ),
                // NOVO: Item de menu para Módulos
                _buildMenuItem(
                  icon: Icons.apps,
                  title: 'Módulos',
                  subtitle: 'Gestão de Ativos',
                  index: 2,
                  selected: selectedIndex == 2,
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
        trailing: selected ? const Icon(Icons.chevron_right, color: Colors.blue) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () => onTap(index),
      ),
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
              onPressed: () => setState(() => _isSidebarVisible = !_isSidebarVisible),
              tooltip: 'Esconder/Mostrar Menu',
            ),
            const SizedBox(width: 12),
            Icon(Icons.dashboard, color: Colors.blue, size: 28),
            const SizedBox(width: 12),
            Text(
              'Gestão do Sistema',
              style: TextStyle(
                color: Colors.blueGrey[800],
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: Icon(Icons.person, color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Bem-vindo,',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      username,
                      style: TextStyle(
                        color: Colors.blueGrey[800],
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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

  Widget _buildTabContent() {
    switch (selectedIndex) {
      case 0:
        return AdminUsersTab(authService: widget.authService);
      case 1:
        return AdminLocationsTab(authService: widget.authService);
      case 2:
        return AdminModulesTab(authService: widget.authService);
      default:
        return AdminUsersTab(authService: widget.authService);
    }
  }
}