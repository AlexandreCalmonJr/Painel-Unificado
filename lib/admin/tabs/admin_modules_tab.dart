// File: lib/admin/tabs/admin_modules_tab.dart (REDESIGNED)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:painel_windowns/config/theme_config.dart';
import 'package:painel_windowns/controllers/theme_controller.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/utils/app_constants.dart';

class AdminModulesTab extends StatefulWidget {
  final AuthService authService;
  const AdminModulesTab({super.key, required this.authService});

  @override
  State<AdminModulesTab> createState() => _AdminModulesTabState();
}

class _AdminModulesTabState extends State<AdminModulesTab> {
  // Dados de exemplo
  final List<Map<String, dynamic>> _modules = [
    {
      'name': 'Módulo Mobile',
      'id': 'mobile',
      'description': 'Gestão de dispositivos móveis',
      'icon': Icons.phone_android,
      'users': 45,
      'status': 'active',
      'version': '2.1.0',
    },
    {
      'name': 'Módulo Totem',
      'id': 'totem',
      'description': 'Gestão de totens e quiosques',
      'icon': Icons.tablet_mac,
      'users': 23,
      'status': 'active',
      'version': '1.8.5',
    },
    {
      'name': 'Módulo Admin',
      'id': 'admin',
      'description': 'Painel administrativo',
      'icon': Icons.admin_panel_settings,
      'users': 8,
      'status': 'active',
      'version': '3.0.1',
    },
    {
      'name': 'Módulo Relatórios',
      'id': 'reports',
      'description': 'Geração de relatórios',
      'icon': Icons.assessment,
      'users': 12,
      'status': 'inactive',
      'version': '1.2.0',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeController = ThemeController.to;
      final isDark = themeController.isDarkMode;
      final palette = themeController.currentPalette;

      final activeModules =
          _modules.where((m) => m['status'] == 'active').length;
      final totalUsers = _modules.fold(
        0,
        (sum, m) => sum + (m['users'] as int),
      );

      return Column(
        children: [
          // Header com estatísticas
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total de Módulos',
                  _modules.length.toString(),
                  Icons.apps,
                  palette['primary']!,
                  isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Módulos Ativos',
                  activeModules.toString(),
                  Icons.check_circle,
                  AppColors.success,
                  isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Usuários Totais',
                  totalUsers.toString(),
                  Icons.people,
                  palette['accent']!,
                  isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Lista de módulos
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    MediaQuery.of(context).size.width > 1400 ? 3 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
              ),
              itemCount: _modules.length,
              itemBuilder: (context, index) {
                final module = _modules[index];
                return _buildModuleCard(module, isDark, palette);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.surfaceLightMode,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isDark
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(
    Map<String, dynamic> module,
    bool isDark,
    Map<String, Color> palette,
  ) {
    final isActive = module['status'] == 'active';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.surfaceLightMode,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [palette['primary']!, palette['accent']!],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(module['icon'], color: Colors.white, size: 28),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:
                      isActive
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color:
                            isActive
                                ? AppColors.success
                                : AppColors.textSecondary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isActive ? 'Ativo' : 'Inativo',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color:
                            isActive
                                ? AppColors.success
                                : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            module['name'],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color:
                  isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            module['description'],
            style: TextStyle(
              fontSize: 13,
              color:
                  isDark
                      ? AppColors.textSecondary
                      : AppColors.textSecondaryLight,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const Spacer(),

          Divider(color: isDark ? AppColors.border : AppColors.borderLight),

          const SizedBox(height: 12),

          Row(
            children: [
              Icon(
                Icons.people_outline,
                size: 16,
                color:
                    isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 6),
              Text(
                '${module['users']} usuários',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: palette['accent']!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'v${module['version']}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: palette['accent'],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.settings, size: 16),
                  label: const Text('Configurar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: palette['primary'],
                    side: BorderSide(color: palette['primary']!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  isActive ? Icons.pause_circle : Icons.play_circle,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor:
                      isActive
                          ? AppColors.warning.withOpacity(0.1)
                          : AppColors.success.withOpacity(0.1),
                  foregroundColor:
                      isActive ? AppColors.warning : AppColors.success,
                ),
                tooltip: isActive ? 'Desativar' : 'Ativar',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
