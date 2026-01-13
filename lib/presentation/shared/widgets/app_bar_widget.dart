// File: lib/widgets/app_bar_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/presentation/features/auth/bloc/theme_controller.dart';
import 'package:painel_windowns/presentation/features/auth/pages/profile_page.dart';
import 'package:painel_windowns/presentation/shared/widgets/profile_avatar_widget.dart';
import 'package:painel_windowns/presentation/shared/widgets/theme_selector_widget.dart';
import 'package:painel_windowns/services/auth_service.dart';

/// AppBar reutilizável para todas as telas
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    required this.title, // ignore: always_put_required_named_parameters_first
    required this.authService,
    super.key,
    this.showBackButton = false,
    this.showProfileButton = true,
    this.showThemeButton = true,
    this.showMenuButton = false,
    this.onMenuPressed,
    this.actions,
    this.tabs,
    this.tabController,
  });
  final String title;
  final AuthService authService;
  final bool showBackButton;
  final bool showProfileButton;
  final bool showThemeButton;
  final bool showMenuButton;
  final VoidCallback? onMenuPressed;
  final List<Widget>? actions;
  final List<Tab>? tabs;
  final TabController? tabController;

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeController = ThemeController.to;
      final isDark = themeController.isDarkMode;
      final palette = themeController.currentPalette;

      return Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : AppColors.surfaceLightMode,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
              // Menu/Back button
              if (showMenuButton && onMenuPressed != null)
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: palette['primary']!.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.menu, color: palette['primary']),
                  ),
                  onPressed: onMenuPressed,
                  tooltip: 'Menu',
                )
              else if (showBackButton)
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: palette['primary']!.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back, color: palette['primary']),
                  ),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Voltar',
                ),

              const SizedBox(width: 12),

              // Ícone e título
              Icon(Icons.dashboard, color: palette['primary'], size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color:
                        isDark
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryLight,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Actions customizadas
              if (actions != null) ...actions!,

              // Botão de tema
              if (showThemeButton) ...[
                const SizedBox(width: 8),
                const ThemeSelectorButton(),
              ],

              // Botão de perfil
              if (showProfileButton) ...[
                const SizedBox(width: 8),
                _buildProfileButton(context, isDark, palette),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildProfileButton(
    BuildContext context,
    bool isDark,
    Map<String, Color> palette,
  ) {
    final user = authService.currentUser;
    final String username = (user?['username'] as String?) ?? 'Usuário';

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? AppColors.surface : AppColors.surfaceLightMode,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileAvatarWidget(username: username, size: 36, isOnline: true),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                username,
                style: TextStyle(
                  color:
                      isDark
                          ? AppColors.textPrimary
                          : AppColors.textPrimaryLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (authService.isAdmin)
                const Text(
                  'ADMIN',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_drop_down,
            color:
                isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
          ),
        ],
      ),
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person, color: palette['primary'], size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Meu Perfil',
                    style: TextStyle(
                      color:
                          isDark
                              ? AppColors.textPrimary
                              : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, color: palette['primary'], size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Configurações',
                    style: TextStyle(
                      color:
                          isDark
                              ? AppColors.textPrimary
                              : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  const Icon(Icons.logout, color: AppColors.danger, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Sair',
                    style: TextStyle(
                      color:
                          isDark
                              ? AppColors.textPrimary
                              : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
      onSelected: (value) {
        switch (value) {
          case 'profile':
            Navigator.push(
              context,
              // ignore: inference_failure_on_instance_creation
              MaterialPageRoute(
                builder: (context) => ProfileScreen(authService: authService),
              ),
            );
            break;
          case 'settings':
            ThemeSelectorWidget.showDialog(context);
            break;
          case 'logout':
            _handleLogout(context);
            break;
        }
      },
    );
  }

  void _handleLogout(BuildContext context) {
    // ignore: inference_failure_on_function_invocation
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor:
                ThemeController.to.isDarkMode
                    ? AppColors.surface
                    : AppColors.surfaceLightMode,
            title: Text(
              'Confirmar Saída',
              style: TextStyle(
                color:
                    ThemeController.to.isDarkMode
                        ? AppColors.textPrimary
                        : AppColors.textPrimaryLight,
              ),
            ),
            content: Text(
              'Tem certeza que deseja sair?',
              style: TextStyle(
                color:
                    ThemeController.to.isDarkMode
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await authService.logout();
                  if (context.mounted) {
                    await Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/login', (route) => false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sair'),
              ),
            ],
          ),
    );
  }
}
