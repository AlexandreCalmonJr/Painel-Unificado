// File: lib/presentation/features/homelab/widgets/dashboard_home_content.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/data/models/asset_module_base_model.dart';
import 'package:painel_windowns/presentation/bloc/theme/theme_cubit.dart';
import 'package:painel_windowns/presentation/bloc/theme/theme_state.dart';
import 'package:painel_windowns/presentation/shared/widgets/homelab/activity_feed_item.dart';
import 'package:painel_windowns/presentation/shared/widgets/homelab/animated_stat_card.dart';
import 'package:painel_windowns/presentation/shared/widgets/homelab/system_health_widget.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/homelab_service.dart';
import 'package:painel_windowns/services/module_management_service.dart';

/// Widget de conteúdo do Dashboard principal
/// Extraído de HomeScreen para ser usado dentro do HomelabApp
class DashboardHomeContent extends StatefulWidget {
  const DashboardHomeContent({required this.authService, super.key});
  final AuthService authService;

  @override
  State<DashboardHomeContent> createState() => _DashboardHomeContentState();
}

class _DashboardHomeContentState extends State<DashboardHomeContent> {
  late final ModuleManagementService _moduleService;
  late final HomelabService _homelabService;

  List<AssetModuleConfig> _availableModules = [];
  bool _isLoadingModules = false;

  // Homelab stats
  HomelabStats _stats = HomelabStats.empty();
  List<ActivityEvent> _recentActivity = [];
  SystemHealth? _systemHealth;
  bool _isLoadingStats = false;

  @override
  void initState() {
    super.initState();
    _moduleService = ModuleManagementService(authService: widget.authService);
    _homelabService = HomelabService(authService: widget.authService);
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadAvailableModules(), _loadHomelabStats()]);
  }

  Future<void> _loadAvailableModules() async {
    setState(() => _isLoadingModules = true);
    try {
      final modules = await _moduleService.listModules();
      if (mounted) {
        setState(() {
          _availableModules = modules.where((m) => m.isActive).toList();
          _isLoadingModules = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingModules = false);
      }
    }
  }

  Future<void> _loadHomelabStats() async {
    setState(() => _isLoadingStats = true);
    try {
      final results = await Future.wait([
        _homelabService.getSystemStats(),
        _homelabService.getRecentActivity(limit: 5),
      ]);

      if (mounted) {
        setState(() {
          _stats = results[0] as HomelabStats;
          _recentActivity = results[1] as List<ActivityEvent>;
          _systemHealth = _homelabService.getSystemHealth();
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  bool _hasPermission(String module) {
    final permissions = widget.authService.permissions;
    if (widget.authService.isAdmin) return true;
    return permissions?.contains(module) ?? false;
  }

  IconData _getModuleIcon(AssetModuleType type) {
    switch (type) {
      case AssetModuleType.mobile:
        return LucideIcons.smartphone;
      case AssetModuleType.totem:
        return LucideIcons.monitor;
      case AssetModuleType.desktop:
        return LucideIcons.monitor;
      case AssetModuleType.notebook:
        return LucideIcons.laptop;
      case AssetModuleType.panel:
        return LucideIcons.tv;
      case AssetModuleType.printer:
        return LucideIcons.printer;
      case AssetModuleType.scanner:
        return LucideIcons.scan;
      default:
        return LucideIcons.box;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDarkMode;
        final palette = themeState.currentPalette;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Section
              _buildHeroSection(isDark, palette),
              const SizedBox(height: 32),

              // Stats Cards
              if (_isLoadingStats)
                const Center(child: CircularProgressIndicator())
              else
                _buildStatsCards(),
              const SizedBox(height: 32),

              // Module Shortcuts
              _buildModuleShortcuts(isDark, palette),
              const SizedBox(height: 32),

              // Quick Actions + System Health
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildQuickActions(isDark)),
                  const SizedBox(width: 24),
                  Expanded(
                    child:
                        _systemHealth != null
                            ? SystemHealthWidget(health: _systemHealth!)
                            : const SizedBox(),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Activity Feed
              _buildActivityFeed(isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroSection(bool isDark, Map<String, Color> palette) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette['primary']!.withOpacity(0.1),
            palette['primary']!.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette['primary']!.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: palette['primary']!.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(LucideIcons.home, size: 48, color: palette['primary']),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo ao seu Homelab',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Monitore e gerencie todos os seus dispositivos em tempo real',
                  style: TextStyle(
                    fontSize: 16,
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

  Widget _buildStatsCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 24,
      mainAxisSpacing: 24,
      childAspectRatio: 1.5,
      children: [
        AnimatedStatCard(
          title: 'Total de Dispositivos',
          value: _stats.totalDevices,
          icon: LucideIcons.smartphone,
          color: AppColors.primary,
          subtitle: 'Ativos no sistema',
          onTap: () => Navigator.pushNamed(context, '/dashboard'),
        ),
        AnimatedStatCard(
          title: 'Dispositivos Online',
          value: _stats.onlineDevices,
          icon: LucideIcons.checkCircle,
          color: AppColors.success,
          subtitle:
              '${_stats.onlinePercentage.toStringAsFixed(0)}% disponíveis',
          trend: _stats.onlinePercentage - 85,
        ),
        AnimatedStatCard(
          title: 'Alertas Ativos',
          value: _stats.alerts,
          icon: LucideIcons.alertTriangle,
          color:
              _stats.alerts > 0 ? AppColors.warning : AppColors.textSecondary,
          subtitle: _stats.alerts > 0 ? 'Requer atenção' : 'Tudo funcionando',
          onTap: _stats.alerts > 0 ? () {} : null,
        ),
      ],
    );
  }

  Widget _buildModuleShortcuts(bool isDark, Map<String, Color> palette) {
    final List<Widget> moduleWidgets = [];

    // Add fixed modules based on permissions
    if (_hasPermission('mobile')) {
      moduleWidgets.add(
        _buildModuleButton(
          icon: LucideIcons.smartphone,
          label: 'Mobile',
          color: AppColors.primary,
          onTap: () => Navigator.pushNamed(context, '/dashboard'),
          isDark: isDark,
        ),
      );
    }

    if (_hasPermission('totem')) {
      moduleWidgets.add(
        _buildModuleButton(
          icon: LucideIcons.monitor,
          label: 'Totem',
          color: AppColors.info,
          onTap: () => Navigator.pushNamed(context, '/totem_dashboard'),
          isDark: isDark,
        ),
      );
    }

    // Add dynamic modules
    for (final module in _availableModules) {
      if (module.type == AssetModuleType.mobile ||
          module.type == AssetModuleType.totem) {
        continue;
      }

      moduleWidgets.add(
        _buildModuleButton(
          icon: _getModuleIcon(module.type),
          label: module.name,
          color: palette['primary']!,
          onTap: () {},
          isDark: isDark,
        ),
      );
    }

    // Add admin panel
    if (widget.authService.isAdmin) {
      moduleWidgets.add(
        _buildModuleButton(
          icon: LucideIcons.shieldCheck,
          label: 'Admin',
          color: AppColors.danger,
          onTap: () => Navigator.pushNamed(context, '/admin_dashboard'),
          isDark: isDark,
        ),
      );
    }

    if (moduleWidgets.isEmpty) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.grid, color: palette['primary'], size: 24),
              const SizedBox(width: 12),
              const Text(
                'Módulos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(spacing: 16, runSpacing: 16, children: moduleWidgets),
        ],
      ),
    );
  }

  Widget _buildModuleButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.zap, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Ações Rápidas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildQuickActionChip(
                icon: LucideIcons.refreshCw,
                label: 'Atualizar',
                onTap: _loadData,
                isDark: isDark,
              ),
              _buildQuickActionChip(
                icon: LucideIcons.bell,
                label: 'Alertas',
                onTap: () {},
                isDark: isDark,
              ),
              _buildQuickActionChip(
                icon: LucideIcons.settings,
                label: 'Configurações',
                onTap: () {},
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityFeed(bool isDark) {
    if (_recentActivity.isEmpty) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.activity,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Atividades Recentes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.arrowRight, size: 16),
                label: const Text('Ver tudo'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentActivity.length,
            itemBuilder: (context, index) {
              return ActivityFeedItem(
                event: _recentActivity[index],
                isLast: index == _recentActivity.length - 1,
              );
            },
          ),
        ],
      ),
    );
  }
}
