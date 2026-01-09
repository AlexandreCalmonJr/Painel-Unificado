// File: lib/widgets/dialogs/user_dialog.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/presentation/features/auth/bloc/theme_controller.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';

class UserDialog {
  /// Mostra dialog para criar novo usuário
  static void showCreateDialog(
    BuildContext context,
    AuthService authService,
    VoidCallback onSuccess,
  ) {
    final themeController = ThemeController.to;
    final isDark = themeController.isDarkMode;
    final palette = themeController.currentPalette;

    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final emailController = TextEditingController();
    final sectorController = TextEditingController();

    String selectedRole = 'user';
    List<String> selectedPermissions = [];
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setStateDialog) => AlertDialog(
                  backgroundColor:
                      isDark ? AppColors.surface : AppColors.surfaceLightMode,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: palette['primary']!.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.person_add,
                          color: palette['primary'],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Criar Novo Usuário',
                        style: TextStyle(
                          color:
                              isDark
                                  ? AppColors.textPrimary
                                  : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: SizedBox(
                      width: 500,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Username
                          _buildTextField(
                            controller: usernameController,
                            label: 'Nome de Usuário',
                            icon: Icons.person,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 16),

                          // Email
                          _buildTextField(
                            controller: emailController,
                            label: 'Email',
                            icon: Icons.email,
                            isDark: isDark,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          // Password
                          _buildTextField(
                            controller: passwordController,
                            label: 'Senha',
                            icon: Icons.lock,
                            isDark: isDark,
                            obscureText: obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color:
                                    isDark
                                        ? AppColors.textSecondary
                                        : AppColors.textSecondaryLight,
                              ),
                              onPressed: () {
                                setStateDialog(
                                  () => obscurePassword = !obscurePassword,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Role
                          _buildDropdown(
                            value: selectedRole,
                            label: 'Função',
                            icon: Icons.badge,
                            isDark: isDark,
                            items: const [
                              DropdownMenuItem(
                                value: 'user',
                                child: Text('Usuário'),
                              ),
                              DropdownMenuItem(
                                value: 'admin',
                                child: Text('Administrador'),
                              ),
                            ],
                            onChanged: (value) {
                              setStateDialog(() {
                                selectedRole = value!;
                                if (value == 'admin') {
                                  selectedPermissions = [
                                    'mobile',
                                    'totem',
                                    'admin',
                                  ];
                                } else {
                                  selectedPermissions = [];
                                }
                              });
                            },
                          ),

                          if (selectedRole == 'user') ...[
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: sectorController,
                              label: 'Setor',
                              icon: Icons.business,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16),
                            _buildPermissionsSection(
                              selectedPermissions,
                              isDark,
                              palette,
                              (permissions) {
                                setStateDialog(
                                  () => selectedPermissions = permissions,
                                );
                              },
                            ),
                          ] else
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.info.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.info.withOpacity(0.3),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: AppColors.info,
                                      size: 20,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Administradores têm acesso a todos os módulos',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.info,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color:
                              isDark
                                  ? AppColors.textSecondary
                                  : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (usernameController.text.isEmpty ||
                            passwordController.text.isEmpty ||
                            emailController.text.isEmpty ||
                            (selectedRole == 'user' &&
                                sectorController.text.isEmpty)) {
                          _showSnackbar(
                            context,
                            'Preencha todos os campos obrigatórios',
                            isError: true,
                          );
                          return;
                        }

                        final result = await authService.createUser({
                          'username': usernameController.text,
                          'email': emailController.text,
                          'password': passwordController.text,
                          'role': selectedRole,
                          'sector': sectorController.text,
                          'permissions': selectedPermissions,
                        });

                        if (result['success'] == true) {
                          Navigator.pop(context);
                          onSuccess();
                          _showSnackbar(context, 'Usuário criado com sucesso!');
                        } else {
                          _showSnackbar(
                            context,
                            result['message']?.toString() ??
                                'Erro ao criar usuário',
                            isError: true,
                          );
                        }
                      },
                      icon: const Icon(Icons.check, size: 20),
                      label: const Text('Criar Usuário'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette['primary'],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  /// Mostra dialog para editar usuário
  static void showEditDialog(
    BuildContext context,
    AuthService authService,
    Map<String, dynamic> user,
    VoidCallback onSuccess,
  ) {
    final themeController = ThemeController.to;
    final isDark = themeController.isDarkMode;
    final palette = themeController.currentPalette;

    final usernameController = TextEditingController(
      text: user['username']?.toString() ?? '',
    );
    final emailController = TextEditingController(
      text: user['email']?.toString() ?? '',
    );
    final sectorController = TextEditingController(
      text: user['sector']?.toString() ?? '',
    );

    String selectedRole = user['role']?.toString() ?? 'user';
    List<String> selectedPermissions =
        (user['permissions'] as List?)?.map((e) => e.toString()).toList() ?? [];

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setStateDialog) => AlertDialog(
                  backgroundColor:
                      isDark ? AppColors.surface : AppColors.surfaceLightMode,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: palette['primary']!.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.edit, color: palette['primary']),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Editar Usuário',
                        style: TextStyle(
                          color:
                              isDark
                                  ? AppColors.textPrimary
                                  : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: SizedBox(
                      width: 500,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            controller: usernameController,
                            label: 'Nome de Usuário',
                            icon: Icons.person,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: emailController,
                            label: 'Email',
                            icon: Icons.email,
                            isDark: isDark,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          _buildDropdown(
                            value: selectedRole,
                            label: 'Função',
                            icon: Icons.badge,
                            isDark: isDark,
                            items: const [
                              DropdownMenuItem(
                                value: 'user',
                                child: Text('Usuário'),
                              ),
                              DropdownMenuItem(
                                value: 'admin',
                                child: Text('Administrador'),
                              ),
                            ],
                            onChanged: (value) {
                              setStateDialog(() {
                                selectedRole = value!;
                                if (value == 'admin') {
                                  selectedPermissions = [
                                    'mobile',
                                    'totem',
                                    'admin',
                                  ];
                                } else {
                                  selectedPermissions =
                                      selectedPermissions
                                          .where((p) => p != 'admin')
                                          .toList();
                                }
                              });
                            },
                          ),
                          if (selectedRole == 'user') ...[
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: sectorController,
                              label: 'Setor',
                              icon: Icons.business,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16),
                            _buildPermissionsSection(
                              selectedPermissions,
                              isDark,
                              palette,
                              (permissions) {
                                setStateDialog(
                                  () => selectedPermissions = permissions,
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color:
                              isDark
                                  ? AppColors.textSecondary
                                  : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (usernameController.text.isEmpty ||
                            emailController.text.isEmpty ||
                            (selectedRole == 'user' &&
                                sectorController.text.isEmpty)) {
                          _showSnackbar(
                            context,
                            'Preencha todos os campos obrigatórios',
                            isError: true,
                          );
                          return;
                        }

                        final result = await authService
                            .updateUser(user['_id'], {
                              'username': usernameController.text,
                              'email': emailController.text,
                              'role': selectedRole,
                              'sector': sectorController.text,
                              'permissions': selectedPermissions,
                            });

                        if (result['success'] == true) {
                          Navigator.pop(context);
                          onSuccess();
                          _showSnackbar(
                            context,
                            'Usuário atualizado com sucesso!',
                          );
                        } else {
                          _showSnackbar(
                            context,
                            result['message']?.toString() ??
                                'Erro ao atualizar usuário',
                            isError: true,
                          );
                        }
                      },
                      icon: const Icon(Icons.check, size: 20),
                      label: const Text('Salvar Alterações'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette['primary'],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  /// Mostra dialog de confirmação para excluir usuário
  static void showDeleteDialog(
    BuildContext context,
    AuthService authService,
    Map<String, dynamic> user,
    VoidCallback onSuccess,
  ) {
    final themeController = ThemeController.to;
    final isDark = themeController.isDarkMode;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor:
                isDark ? AppColors.surface : AppColors.surfaceLightMode,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.warning, color: AppColors.danger),
                ),
                const SizedBox(width: 12),
                Text(
                  'Confirmar Exclusão',
                  style: TextStyle(
                    color:
                        isDark
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
            content: Text(
              'Tem certeza que deseja excluir o usuário "${user['username']}"? Esta ação não pode ser desfeita.',
              style: TextStyle(
                color:
                    isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: TextStyle(
                    color:
                        isDark
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryLight,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await authService.deleteUser(user['_id']);
                  Navigator.pop(context);
                  if (result['success'] == true) {
                    onSuccess();
                    _showSnackbar(context, 'Usuário excluído com sucesso!');
                  } else {
                    _showSnackbar(
                      context,
                      result['message']?.toString() ??
                          'Erro ao excluir usuário',
                      isError: true,
                    );
                  }
                },
                icon: const Icon(Icons.delete, size: 20),
                label: const Text('Excluir Usuário'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  // Helper widgets
  static Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(
        color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color:
              isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
        ),
        prefixIcon: Icon(
          icon,
          color:
              isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor:
            isDark ? AppColors.background : AppColors.surfaceLightVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: ThemeController.to.currentPalette['primary']!,
            width: 2,
          ),
        ),
      ),
    );
  }

  static Widget _buildDropdown({
    required String value,
    required String label,
    required IconData icon,
    required bool isDark,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color:
              isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
        ),
        prefixIcon: Icon(
          icon,
          color:
              isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
        ),
        filled: true,
        fillColor:
            isDark ? AppColors.background : AppColors.surfaceLightVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: isDark ? AppColors.surface : AppColors.surfaceLightMode,
      style: TextStyle(
        color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  static Widget _buildPermissionsSection(
    List<String> selectedPermissions,
    bool isDark,
    Map<String, Color> palette,
    ValueChanged<List<String>> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Permissões de Módulos',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        _buildPermissionCheckbox(
          title: 'Módulo Mobile',
          value: selectedPermissions.contains('mobile'),
          isDark: isDark,
          palette: palette,
          onChanged: (value) {
            final newPermissions = List<String>.from(selectedPermissions);
            if (value == true) {
              newPermissions.add('mobile');
            } else {
              newPermissions.remove('mobile');
            }
            onChanged(newPermissions);
          },
        ),
        _buildPermissionCheckbox(
          title: 'Módulo Totem',
          value: selectedPermissions.contains('totem'),
          isDark: isDark,
          palette: palette,
          onChanged: (value) {
            final newPermissions = List<String>.from(selectedPermissions);
            if (value == true) {
              newPermissions.add('totem');
            } else {
              newPermissions.remove('totem');
            }
            onChanged(newPermissions);
          },
        ),
      ],
    );
  }

  static Widget _buildPermissionCheckbox({
    required String title,
    required bool value,
    required bool isDark,
    required Map<String, Color> palette,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: palette['primary'],
      contentPadding: EdgeInsets.zero,
    );
  }

  static void _showSnackbar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
