// File: lib/home_screen.dart (ATUALIZADO)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/core/di/injection.dart';
import 'package:painel_windowns/data/models/asset_module_base_model.dart';
import 'package:painel_windowns/presentation/bloc/theme/theme_cubit.dart';
import 'package:painel_windowns/presentation/bloc/theme/theme_state.dart';
import 'package:painel_windowns/presentation/features/auth/pages/profile_page.dart';
import 'package:painel_windowns/presentation/shared/widgets/navigation/unified_menu_item.dart';
import 'package:painel_windowns/presentation/shared/widgets/profile_avatar_widget.dart';
import 'package:painel_windowns/presentation/shared/widgets/theme_selector_widget.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/module_management_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.authService, super.key});
  final AuthService authService;

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<AssetModuleConfig> _availableModules = [];
  bool _isLoadingModules = false;
  late final ModuleManagementService _moduleService;

  @override
  void initState() {
    super.initState();

    _moduleService = getIt<ModuleManagementService>();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    _slideController.forward();

    _loadAvailableModules();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableModules() async {
    setState(() => _isLoadingModules = true);
    try {
      final modules = await _moduleService.listModules();
      if (mounted) {
        setState(() {
          // Filtra apenas módulos ativos
          _availableModules = modules.where((m) => m.isActive).toList();
          _isLoadingModules = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingModules = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar módulos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _logout(BuildContext context) async {
    await widget.authService.logout();
    if (mounted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    }
  }

  bool _hasPermission(String module) {
    final permissions = widget.authService.permissions;
    if (widget.authService.isAdmin) return true;
    return permissions?.contains(module) ?? false;
  }

  IconData _getModuleIcon(String iconName) {
    switch (iconName) {
      case 'phone_android':
        return Icons.phone_android;
      case 'desktop_windows':
        return Icons.desktop_windows;
      case 'computer':
        return Icons.computer;
      case 'laptop':
        return Icons.laptop;
      case 'tv':
        return Icons.tv;
      case 'print':
        return Icons.print;
      case 'qr_code_scanner':
        return Icons.qr_code_scanner;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDarkMode;
        final palette = themeState.currentPalette;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient:
                  isDark
                      ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.background, AppColors.surface],
                      )
                      : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.backgroundLight,
                          AppColors.surfaceLightVariant,
                        ],
                      ),
            ),
            child: Stack(
              children: [
                // Header com botões (Top Right)
                Positioned(
                  top: 24,
                  right: 24,
                  child: Row(
                    children: [
                      // Botão de Tema
                      const ThemeSelectorButton(),
                      const SizedBox(width: 12),

                      // Botão de Perfil
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder:
                                  (context) => ProfileScreen(
                                    authService: widget.authService,
                                  ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: (isDark
                                    ? AppColors.surface
                                    : AppColors.surfaceLightMode)
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: palette['primary']!.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              ProfileAvatarWidget(
                                username:
                                    (widget.authService.currentUser?['username']
                                        as String?) ??
                                    'User',
                                size: 32,
                                isOnline: true,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                (widget.authService.currentUser?['username']
                                        as String?) ??
                                    'Usuário',
                                style: TextStyle(
                                  color:
                                      isDark
                                          ? AppColors.textPrimary
                                          : AppColors.textPrimaryLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Botão de Logout
                      IconButton(
                        onPressed: () => _logout(context),
                        icon: const Icon(Icons.logout),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.danger.withOpacity(0.2),
                          foregroundColor: AppColors.danger,
                          padding: const EdgeInsets.all(12),
                        ),
                        tooltip: 'Sair',
                      ),
                    ],
                  ),
                ),

                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 1000),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Header Section
                              Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color:
                                      isDark
                                          ? AppColors.surface
                                          : AppColors.surfaceLightMode,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color:
                                        isDark
                                            ? AppColors.border.withOpacity(0.1)
                                            : AppColors.borderLight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    // Logo / Title
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: palette['primary']!.withOpacity(
                                          0.1,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.grid_view_rounded,
                                        size: 48,
                                        color: palette['primary'],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'Central de Módulos',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isDark
                                                ? AppColors.textPrimary
                                                : AppColors.textPrimaryLight,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Selecione um módulo para gerenciar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color:
                                            isDark
                                                ? AppColors.textSecondary
                                                : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                    const SizedBox(height: 32),

                                    // User Info Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isDark
                                                ? AppColors.background
                                                : AppColors.surfaceLightVariant,
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(
                                          color:
                                              isDark
                                                  ? AppColors.border
                                                      .withOpacity(0.5)
                                                  : AppColors.borderLight,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundColor:
                                                widget.authService.isAdmin
                                                    ? AppColors.danger
                                                        .withOpacity(0.2)
                                                    : palette['primary']!
                                                        .withOpacity(0.2),
                                            child: Icon(
                                              widget.authService.isAdmin
                                                  ? Icons.admin_panel_settings
                                                  : Icons.person,
                                              size: 18,
                                              color:
                                                  widget.authService.isAdmin
                                                      ? AppColors.danger
                                                      : palette['primary'],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                (widget
                                                            .authService
                                                            .currentUser?['username']
                                                        as String?) ??
                                                    'Usuário',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      isDark
                                                          ? AppColors
                                                              .textPrimary
                                                          : AppColors
                                                              .textPrimaryLight,
                                                ),
                                              ),
                                              if (widget
                                                      .authService
                                                      .currentUser?['role'] !=
                                                  null)
                                                Text(
                                                  widget
                                                      .authService
                                                      .currentUser!['role']
                                                      .toString()
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color:
                                                        widget
                                                                .authService
                                                                .isAdmin
                                                            ? AppColors.danger
                                                            : palette['primary'],
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: AppColors.success,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Modules Grid
                              if (_isLoadingModules)
                                Center(
                                  child: CircularProgressIndicator(
                                    color: palette['primary'],
                                  ),
                                )
                              else
                                _buildModulesGrid(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModulesGrid() {
    final List<Widget> moduleCards = [];

    // Adiciona módulos fixos baseados em permissões
    if (_hasPermission('mobile')) {
      moduleCards.add(
        UnifiedMenuItem(
          icon: Icons.phone_android,
          title: 'Módulo Mobile',
          subtitle: 'Gestão de Dispositivos',
          style: MenuItemStyle.hub,
          onTap: () => Navigator.pushNamed(context, '/dashboard'),
        ),
      );
    }

    if (_hasPermission('totem')) {
      moduleCards.add(
        UnifiedMenuItem(
          icon: Icons.desktop_windows,
          title: 'Módulo Totem',
          subtitle: 'Monitoramento de Totens',
          style: MenuItemStyle.hub,
          onTap: () => Navigator.pushNamed(context, '/totem_dashboard'),
        ),
      );
    }

    // Adiciona módulos dinâmicos
    for (final module in _availableModules) {
      if (module.type == AssetModuleType.mobile ||
          module.type == AssetModuleType.totem) {
        continue;
      }

      moduleCards.add(
        UnifiedMenuItem(
          icon: _getModuleIcon(module.type.iconName),
          title: module.name,
          subtitle:
              module.description.isNotEmpty
                  ? module.description
                  : module.type.displayName,
          style: MenuItemStyle.hub,
          onTap: () => (module),
        ),
      );
    }

    // Adiciona painel admin
    if (widget.authService.isAdmin) {
      moduleCards.add(
        UnifiedMenuItem(
          icon: Icons.admin_panel_settings,
          title: 'Painel de Controle',
          subtitle: 'Gerenciamento do Sistema',
          style: MenuItemStyle.hub,
          onTap: () => Navigator.pushNamed(context, '/admin_dashboard'),
        ),
      );
    }

    if (moduleCards.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum módulo disponível',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 : 2,
      crossAxisSpacing: 24.0,
      mainAxisSpacing: 24.0,
      childAspectRatio: 1.4,
      children: moduleCards,
    );
  }
}
