// File: lib/admin/admin_dashboard_screen.dart (ATUALIZADO)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:painel_windowns/admin/tabs/admin_apk_manager_tab.dart';
import 'package:painel_windowns/admin/tabs/admin_locations_tab.dart';
import 'package:painel_windowns/admin/tabs/admin_modules_tab.dart';

import 'package:painel_windowns/admin/tabs/admin_users_tab.dart';
import 'package:painel_windowns/controllers/theme_controller.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/utils/app_constants.dart';
import 'package:painel_windowns/widgets/app_bar_widget.dart';
import 'package:painel_windowns/widgets/common/custom_sidebar.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key, required this.authService});
  final AuthService authService;

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int selectedIndex = 0;
  bool _isSidebarVisible = true;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeController = ThemeController.to;
      final isDark = themeController.isDarkMode;

      return Container(
        decoration: BoxDecoration(
          gradient:
              isDark
                  ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.background, AppColors.surface],
                  )
                  : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.backgroundLight,
                      AppColors.surfaceLightVariant,
                    ],
                  ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: CustomAppBar(
            title: 'Painel Administrativo',
            authService: widget.authService,
            showBackButton: true,
            showMenuButton: true,
            onMenuPressed: () {
              setState(() => _isSidebarVisible = !_isSidebarVisible);
            },
          ),
          body: Row(
            children: [
              if (_isSidebarVisible) _buildSidebar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildTabContent(),
                ),
              ),
            ],
          ),
        ),
      );
    });
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
