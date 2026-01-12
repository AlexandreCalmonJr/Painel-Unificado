// File: lib/screen/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/core/utils/theme_gradients.dart';
import 'package:painel_windowns/presentation/features/auth/bloc/theme_controller.dart';
import 'package:painel_windowns/presentation/shared/widgets/profile_avatar_widget.dart';
import 'package:painel_windowns/presentation/shared/widgets/theme_selector_widget.dart';
import 'package:painel_windowns/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.authService});
  final AuthService authService;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeController = ThemeController.to;
      final isDark = themeController.isDarkMode;
      final palette = themeController.currentPalette;

      return Scaffold(
        backgroundColor:
            isDark ? AppColors.background : AppColors.backgroundLight,
        body: Container(
          decoration: BoxDecoration(
            gradient: ThemeGradients.getLoginBackgroundGradient(
              themeController.colorScheme,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(isDark, palette),

                // Tabs
                _buildTabBar(isDark, palette),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProfileTab(isDark, palette),
                      _buildPreferencesTab(isDark, palette),
                      _buildActivityTab(isDark, palette),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeader(bool isDark, Map<String, Color> palette) {
    final user = widget.authService.currentUser;
    final username = user?['username'] ?? 'Usuário';
    final role = user?['role'] ?? 'user';
    final isAdmin = widget.authService.isAdmin;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header com título centralizado
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back,
                  color:
                      isDark
                          ? AppColors.textPrimary
                          : AppColors.textPrimaryLight,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: (isDark
                          ? AppColors.surface
                          : AppColors.surfaceLightMode)
                      .withOpacity(0.5),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Meu Perfil',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color:
                          isDark
                              ? AppColors.textPrimary
                              : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48), // Balancear o botão voltar
            ],
          ),

          const SizedBox(height: 32),

          // Avatar e informações básicas
          ProfileAvatarWidget(
            username: username as String,
            size: 100,
            isOnline: true,
          ),

          const SizedBox(height: 16),

          Text(
            username,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color:
                  isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
            ),
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color:
                  isAdmin
                      ? AppColors.danger.withOpacity(0.2)
                      : palette['primary']!.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isAdmin ? AppColors.danger : palette['primary']!,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAdmin ? Icons.admin_panel_settings : Icons.person,
                  size: 16,
                  color: isAdmin ? AppColors.danger : palette['primary'],
                ),
                const SizedBox(width: 6),
                Text(
                  (role as String).toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isAdmin ? AppColors.danger : palette['primary'],
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark, Map<String, Color> palette) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.surface : AppColors.surfaceLightMode)
            .withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.borderLight,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: ThemeGradients.getPrimaryButtonGradient(
            ThemeController.to.colorScheme,
          ),
        ),
        labelColor: Colors.white,
        unselectedLabelColor:
            isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(icon: Icon(Icons.person, size: 20), text: 'Perfil'),
          Tab(icon: Icon(Icons.settings, size: 20), text: 'Preferências'),
          Tab(icon: Icon(Icons.history, size: 20), text: 'Atividade'),
        ],
      ),
    );
  }

  Widget _buildProfileTab(bool isDark, Map<String, Color> palette) {
    final user = widget.authService.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInfoCard(
                isDark: isDark,
                palette: palette,
                title: 'Informações Pessoais',
                icon: Icons.info_outline,
                children: [
                  _buildInfoRow(
                    'Usuário',
                    user?['username'] as String ?? 'N/A',
                    Icons.person,
                  ),
                  _buildInfoRow(
                    'Email',
                    user?['email'] as String ?? 'N/A',
                    Icons.email,
                  ),
                  _buildInfoRow(
                    'Função',
                    user?['role'] as String ?? 'N/A',
                    Icons.work,
                  ),
                  _buildInfoRow(
                    'Criado em',
                    user?['created_at'] as String ?? 'N/A',
                    Icons.calendar_today,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _buildInfoCard(
                isDark: isDark,
                palette: palette,
                title: 'Permissões',
                icon: Icons.security,
                children: [_buildPermissionsList()],
              ),

              const SizedBox(height: 16),

              _buildActionButtons(isDark, palette),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferencesTab(bool isDark, Map<String, Color> palette) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aparência',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      isDark
                          ? AppColors.textPrimary
                          : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 16),

              const ThemeSelectorWidget(),

              const SizedBox(height: 24),

              Text(
                'Notificações',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      isDark
                          ? AppColors.textPrimary
                          : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 16),

              _buildNotificationSettings(isDark, palette),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTab(bool isDark, Map<String, Color> palette) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Atividades Recentes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      isDark
                          ? AppColors.textPrimary
                          : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 16),

              _buildActivityList(isDark, palette),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required bool isDark,
    required Map<String, Color> palette,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.surfaceLightMode,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: palette['primary']!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: palette['primary'], size: 22),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      isDark
                          ? AppColors.textPrimary
                          : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    final isDark = ThemeController.to.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color:
                isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isDark
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
      ),
    );
  }

  Widget _buildPermissionsList() {
    final permissions = widget.authService.permissions ?? [];
    final isDark = ThemeController.to.isDarkMode;
    final palette = ThemeController.to.currentPalette;

    if (widget.authService.isAdmin) {
      return _buildPermissionChip(
        'Administrador (Acesso Total)',
        true,
        isDark,
        palette,
      );
    }

    if (permissions.isEmpty) {
      return Text(
        'Nenhuma permissão específica',
        style: TextStyle(
          fontSize: 14,
          color:
              isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          permissions.map((permission) {
            return _buildPermissionChip(permission, false, isDark, palette);
          }).toList(),
    );
  }

  Widget _buildPermissionChip(
    String permission,
    bool isAdmin,
    bool isDark,
    Map<String, Color> palette,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            isAdmin
                ? AppColors.danger.withOpacity(0.1)
                : palette['primary']!.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAdmin ? AppColors.danger : palette['primary']!,
        ),
      ),
      child: Text(
        permission,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isAdmin ? AppColors.danger : palette['primary'],
        ),
      ),
    );
  }

  Widget _buildActionButtons(bool isDark, Map<String, Color> palette) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Implementar edição de perfil
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidade em desenvolvimento'),
                ),
              );
            },
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Editar Perfil'),
            style: ElevatedButton.styleFrom(
              backgroundColor: palette['primary'],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: Implementar mudança de senha
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidade em desenvolvimento'),
                ),
              );
            },
            icon: const Icon(Icons.lock, size: 18),
            label: const Text('Alterar Senha'),
            style: OutlinedButton.styleFrom(
              foregroundColor: palette['primary'],
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: palette['primary']!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSettings(bool isDark, Map<String, Color> palette) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.surfaceLightMode,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSwitchRow(
            'Notificações de Sistema',
            true,
            Icons.notifications,
            (value) {},
            isDark,
            palette,
          ),
          const Divider(height: 32),
          _buildSwitchRow(
            'Alertas de Dispositivos',
            true,
            Icons.phone_android,
            (value) {},
            isDark,
            palette,
          ),
          const Divider(height: 32),
          _buildSwitchRow(
            'Relatórios por Email',
            false,
            Icons.email,
            (value) {},
            isDark,
            palette,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(
    String title,
    bool value,
    IconData icon,
    Function(bool) onChanged,
    bool isDark,
    Map<String, Color> palette,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color:
              isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
          size: 22,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color:
                  isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: palette['primary'],
        ),
      ],
    );
  }

  Widget _buildActivityList(bool isDark, Map<String, Color> palette) {
    // Dados de exemplo - substituir por dados reais
    final activities = [
      {'action': 'Login realizado', 'time': 'Há 2 horas', 'icon': Icons.login},
      {
        'action': 'Dispositivo atualizado',
        'time': 'Há 5 horas',
        'icon': Icons.phone_android,
      },
      {'action': 'Módulo acessado', 'time': 'Ontem', 'icon': Icons.apps},
      {
        'action': 'Configuração alterada',
        'time': 'Há 2 dias',
        'icon': Icons.settings,
      },
    ];

    return Column(
      children:
          activities.map((activity) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : AppColors.surfaceLightMode,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.border : AppColors.borderLight,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : Colors.grey).withOpacity(
                      0.1,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: palette['primary']!.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      activity['icon'] as IconData,
                      color: palette['primary'],
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['action'] as String,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark
                                    ? AppColors.textPrimary
                                    : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          activity['time'] as String,
                          style: TextStyle(
                            fontSize: 13,
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
          }).toList(),
    );
  }
}
