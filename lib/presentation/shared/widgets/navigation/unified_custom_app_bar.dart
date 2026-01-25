import 'package:flutter/material.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/presentation/features/auth/pages/login_page.dart';

class UnifiedCustomAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const UnifiedCustomAppBar({
    required this.title,
    required this.icon,
    required this.authService,
    required this.isSidebarVisible,
    required this.onMenuPressed,
    this.iconColor = Colors.blue,
    this.actions,
    super.key,
  });

  final String title;
  final IconData icon;
  final AuthService authService;
  final bool isSidebarVisible;
  final VoidCallback onMenuPressed;
  final Color iconColor;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(70);

  Future<void> _logout(BuildContext context) async {
    await authService.logout();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (context) => LoginScreen(authService: authService),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar Logout'),
            content: const Text('Tem certeza que deseja sair do sistema?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _logout(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sair'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = authService.currentUser;
    final username = currentUser?['username'] ?? 'Usuário';
    final role = currentUser?['role'] ?? 'user';
    final isAdmin = role == 'admin';

    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.3),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SafeArea(
          // Keep SafeArea inside to avoid Material clipping issues if needed, or wrap Material
          child: Row(
            children: [
              // Menu Toggle
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSidebarVisible ? Icons.menu_open : Icons.menu,
                    color: Colors.grey[600],
                  ),
                ),
                onPressed: onMenuPressed,
                tooltip: 'Esconder/Mostrar Menu',
              ),
              const SizedBox(width: 12),

              // Title and Icon
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: Colors.blueGrey[800],
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              // Custom Actions (e.g. Refresh, Location)
              if (actions != null) ...actions!,

              if (actions != null) const SizedBox(width: 15),

              // User Info Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      isAdmin ? Icons.admin_panel_settings : Icons.person,
                      size: 16,
                      color: isAdmin ? Colors.red[600] : Colors.blue[600],
                    ),
                    const SizedBox(width: 6),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          role.toString().toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),

              // Logout Menu
              PopupMenuButton<String>(
                icon: CircleAvatar(
                  backgroundColor: isAdmin ? Colors.red[600] : Colors.blue[600],
                  child: Text(
                    username.toString().isNotEmpty
                        ? username.toString()[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                tooltip: 'Menu do usuário',
                onSelected: (value) {
                  if (value == 'logout') {
                    _showLogoutDialog(context);
                  }
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout,
                              size: 18,
                              color: Colors.red[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Sair',
                              style: TextStyle(color: Colors.red[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
