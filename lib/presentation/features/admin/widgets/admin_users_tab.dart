// File: lib/admin/tabs/admin_users_tab.dart (REDESIGNED)
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:painel_windowns/controllers/theme_controller.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/server_config_service.dart';
import 'package:painel_windowns/utils/app_constants.dart';
import 'package:painel_windowns/widgets/dialogs/user_dialog.dart';
import 'package:painel_windowns/widgets/profile_avatar_widget.dart';

class AdminUsersTab extends StatefulWidget {
  final AuthService authService;
  const AdminUsersTab({super.key, required this.authService});

  @override
  _AdminUsersTabState createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  late Future<Map<String, dynamic>> _usersFuture;
  String _searchQuery = '';
  String _filterRole = 'all'; // all, admin, user

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      _usersFuture = widget.authService.getUsers();
    });
  }

  List<Map<String, dynamic>> _filterUsers(List<dynamic> users) {
    return users
        .where((user) {
          final matchesSearch =
              user['username'].toString().toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              (user['email']?.toString().toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ??
                  false);

          final matchesRole =
              _filterRole == 'all' || user['role'] == _filterRole;

          return matchesSearch && matchesRole;
        })
        .cast<Map<String, dynamic>>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeController = ThemeController.to;
      final isDark = themeController.isDarkMode;
      final palette = themeController.currentPalette;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com estatísticas
          _buildStatsCards(isDark, palette),

          const SizedBox(height: 20),

          // Barra de busca e filtros
          _buildSearchAndFilters(isDark, palette),

          const SizedBox(height: 20),

          // Lista de usuários
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: palette['primary']),
                  );
                }

                if (snapshot.hasError) {
                  return _buildErrorState(isDark, palette);
                }

                final result = snapshot.data ?? {};
                final allUsers = result['users'] as List<dynamic>? ?? [];
                final filteredUsers = _filterUsers(allUsers);

                if (filteredUsers.isEmpty && _searchQuery.isEmpty) {
                  return _buildEmptyState(isDark, palette);
                }

                if (filteredUsers.isEmpty) {
                  return _buildNoResultsState(isDark, palette);
                }

                return _buildUsersList(filteredUsers, isDark, palette);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStatsCards(bool isDark, Map<String, Color> palette) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        final users = (snapshot.data?['users'] as List<dynamic>?) ?? [];
        final totalUsers = users.length;
        final adminUsers = users.where((u) => u['role'] == 'admin').length;
        final regularUsers = users.where((u) => u['role'] == 'user').length;

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total de Usuários',
                value: totalUsers.toString(),
                icon: Icons.people,
                color: palette['primary']!,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Administradores',
                value: adminUsers.toString(),
                icon: Icons.admin_panel_settings,
                color: AppColors.danger,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Usuários Regulares',
                value: regularUsers.toString(),
                icon: Icons.person,
                color: AppColors.success,
                isDark: isDark,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.surfaceLightMode,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                    fontSize: 28,
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

  Widget _buildSearchAndFilters(bool isDark, Map<String, Color> palette) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.surfaceLightMode,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          // Campo de busca
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: TextStyle(
                color:
                    isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar usuários...',
                hintStyle: TextStyle(
                  color:
                      isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color:
                      isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                ),
                filled: true,
                fillColor:
                    isDark
                        ? AppColors.background
                        : AppColors.surfaceLightVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Filtro de role
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color:
                  isDark ? AppColors.background : AppColors.surfaceLightVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: _filterRole,
              underline: const SizedBox(),
              dropdownColor:
                  isDark ? AppColors.surface : AppColors.surfaceLightMode,
              style: TextStyle(
                color:
                    isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Todos')),
                DropdownMenuItem(value: 'admin', child: Text('Admins')),
                DropdownMenuItem(value: 'user', child: Text('Usuários')),
              ],
              onChanged: (value) => setState(() => _filterRole = value!),
            ),
          ),

          const SizedBox(width: 16),

          // Botão adicionar
          ElevatedButton.icon(
            onPressed: () => _showCreateUserDialog(isDark, palette),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Novo Usuário'),
            style: ElevatedButton.styleFrom(
              backgroundColor: palette['primary'],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(
    List<Map<String, dynamic>> users,
    bool isDark,
    Map<String, Color> palette,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 1400 ? 3 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.8,
      ),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserCard(user, isDark, palette);
      },
    );
  }

  Widget _buildUserCard(
    Map<String, dynamic> user,
    bool isDark,
    Map<String, Color> palette,
  ) {
    final isCurrentUser = user['_id'] == widget.authService.currentUser?['_id'];
    final isAdmin = user['role'] == 'admin';
    final permissions =
        isAdmin
            ? ['mobile', 'totem', 'admin']
            : (user['permissions'] as List<dynamic>?) ?? [];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.surfaceLightMode,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isCurrentUser
                  ? palette['primary']!
                  : (isDark ? AppColors.border : AppColors.borderLight),
          width: isCurrentUser ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header com avatar e nome
                Row(
                  children: [
                    ProfileAvatarWidget(
                      username: user['username'],
                      size: 50,
                      isOnline: isCurrentUser,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['username'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDark
                                      ? AppColors.textPrimary
                                      : AppColors.textPrimaryLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isAdmin
                                      ? AppColors.danger.withOpacity(0.1)
                                      : palette['primary']!.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isAdmin ? 'ADMIN' : 'USER',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color:
                                    isAdmin
                                        ? AppColors.danger
                                        : palette['primary'],
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Informações
                _buildInfoRow(
                  Icons.email,
                  user['email'] ?? 'Sem email',
                  isDark,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.business,
                  user['sector'] ?? 'Sem setor',
                  isDark,
                ),

                const Spacer(),

                // Permissões
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children:
                      permissions.map((perm) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: palette['accent']!.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: palette['accent']!.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            perm.toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: palette['accent'],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),

          // Menu de ações
          if (!isCurrentUser)
            Positioned(
              top: 8,
              right: 8,
              child: PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color:
                      isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: isDark ? AppColors.surface : AppColors.surfaceLightMode,
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditUserDialog(user, isDark, palette);
                  } else if (value == 'delete') {
                    _confirmDeleteUser(user, isDark, palette);
                  }
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              color: palette['primary'],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            const Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              color: AppColors.danger,
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Text('Excluir'),
                          ],
                        ),
                      ),
                    ],
              ),
            ),

          // Badge "Você"
          if (isCurrentUser)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Você',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color:
              isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color:
                  isDark
                      ? AppColors.textSecondary
                      : AppColors.textSecondaryLight,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark, Map<String, Color> palette) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color:
                isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum usuário encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color:
                  isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crie um novo usuário para começar',
            style: TextStyle(
              fontSize: 14,
              color:
                  isDark
                      ? AppColors.textSecondary
                      : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateUserDialog(isDark, palette),
            icon: const Icon(Icons.add),
            label: const Text('Criar Primeiro Usuário'),
            style: ElevatedButton.styleFrom(
              backgroundColor: palette['primary'],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(bool isDark, Map<String, Color> palette) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color:
                isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum resultado encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color:
                  isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente ajustar os filtros de busca',
            style: TextStyle(
              fontSize: 14,
              color:
                  isDark
                      ? AppColors.textSecondary
                      : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark, Map<String, Color> palette) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: AppColors.danger),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar usuários',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color:
                  isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadUsers,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar Novamente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: palette['primary'],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Dialogs usando UserDialog
  void _showCreateUserDialog(bool isDark, Map<String, Color> palette) {
    UserDialog.showCreateDialog(context, widget.authService, _loadUsers);
  }

  void _showEditUserDialog(
    Map<String, dynamic> user,
    bool isDark,
    Map<String, Color> palette,
  ) {
    UserDialog.showEditDialog(context, widget.authService, user, _loadUsers);
  }

  void _confirmDeleteUser(
    Map<String, dynamic> user,
    bool isDark,
    Map<String, Color> palette,
  ) {
    UserDialog.showDeleteDialog(context, widget.authService, user, _loadUsers);
  }
}

// Extension para compatibilidade
extension AuthServiceExtension on AuthService {
  Future<Map<String, dynamic>> getUsers() async {
    if (!isLoggedIn || !isAdmin) {
      return {'success': false, 'users': []};
    }
    final config = ServerConfigService.instance.loadConfig();
    try {
      final response = await http
          .get(
            Uri.parse(
              'http://${config['ip']}:${config['port']}/api/auth/users',
            ),
            headers: {'Authorization': 'Bearer $currentToken'},
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'users': data['users']};
      } else {
        return {'success': false, 'users': []};
      }
    } catch (e) {
      return {'success': false, 'users': [], 'error': e.toString()};
    }
  }
}
