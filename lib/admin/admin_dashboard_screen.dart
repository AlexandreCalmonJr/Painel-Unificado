// File: lib/admin/admin_dashboard_screen.dart (ATUALIZADO)
import 'package:flutter/material.dart';
import 'package:painel_windowns/admin/tabs/admin_apk_manager_tab.dart';
import 'package:painel_windowns/admin/tabs/admin_locations_tab.dart';
import 'package:painel_windowns/admin/tabs/admin_modules_tab.dart';
import 'package:painel_windowns/admin/tabs/admin_users_tab.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/widgets/common/custom_sidebar.dart';

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
    final menuItems = [
      const SidebarMenuItem(
        icon: Icons.people,
        title: 'Utilizadores',
        subtitle: 'Gerir acessos',
        index: 0,
      ),
      const SidebarMenuItem(
        icon: Icons.location_on,
        title: 'Localização',
        subtitle: 'Mapeamento de IP',
        index: 1,
      ),
      const SidebarMenuItem(
        icon: Icons.apps,
        title: 'Módulos',
        subtitle: 'Gestão de Ativos',
        index: 2,
      ),
      const SidebarMenuItem(
        icon: Icons.android,
        title: 'Gestor de APKs',
        subtitle: 'Instalar/Remover APKs',
        index: 3,
        showDividerBefore: true,
      ),
      SidebarMenuItem(
        icon: Icons.arrow_back,
        title: 'Voltar',
        subtitle: 'Menu Principal',
        index: 99,
        showDividerBefore: false,
      ),
    ];

    return CustomSidebar(
      title: 'Administrativo',
      titleIcon: Icons.admin_panel_settings,
      menuItems: menuItems,
      selectedIndex: selectedIndex,
      onItemTap: (index) {
        if (index == 99) {
          Navigator.of(context).pop();
        } else {
          setState(() => selectedIndex = index);
        }
      },
      isAdmin: true,
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
              onPressed:
                  () => setState(() => _isSidebarVisible = !_isSidebarVisible),
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
      case 3:
        return AdminApkManagerTab(authService: widget.authService);
      default:
        return AdminUsersTab(authService: widget.authService);
    }
  }
}
