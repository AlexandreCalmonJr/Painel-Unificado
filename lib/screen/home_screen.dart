// File: lib/home_screen.dart (ATUALIZADO)

import 'package:flutter/material.dart';
import 'package:painel_windowns/devices/widgets/hub_menu_item.dart';
import 'package:painel_windowns/models/asset_module_base.dart';
import 'package:painel_windowns/modules/generic_dashboard_screen.dart';
// ✅ CORREÇÃO APLICADA AQUI
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/module_management_service.dart';

class HomeScreen extends StatefulWidget {
  final AuthService authService;
  const HomeScreen({super.key, required this.authService});

  @override
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

    _moduleService = ModuleManagementService(authService: widget.authService);

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
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (Route<dynamic> route) => false,
      );
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

  void _navigateToModule(AssetModuleConfig module) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GenericDashboardScreen(
          authService: widget.authService,
          moduleConfig: module,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.indigo.shade100,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Card(
                elevation: 20,
                shadowColor: Colors.blue.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 900),
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade600,
                              Colors.indigo.shade700,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.apps, size: 48, color: Colors.white),
                            SizedBox(height: 12),
                            Text(
                              'Central de Módulos',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade50,
                              Colors.indigo.shade50,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.shade100,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                widget.authService.isAdmin
                                    ? Icons.admin_panel_settings
                                    : Icons.person,
                                color: widget.authService.isAdmin
                                    ? Colors.red.shade600
                                    : Colors.blue.shade600,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bem-vindo de volta!',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.authService.currentUser?['username'] ??
                                        'Usuário',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blueGrey.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (widget.authService.currentUser?['role'] !=
                                      null)
                                    Text(
                                      widget.authService.currentUser!['role']
                                          .toString()
                                          .toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: widget.authService.isAdmin
                                            ? Colors.red.shade600
                                            : Colors.blue.shade600,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.green.shade600,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (_isLoadingModules)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        _buildModulesGrid(),
                      const SizedBox(height: 32),
                      _buildActionButton(
                        onPressed: () => _logout(context),
                        text: 'Sair',
                        icon: Icons.logout,
                        color: Colors.red.shade600,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModulesGrid() {
    List<Widget> moduleCards = [];

    // Adiciona módulos fixos baseados em permissões
    if (_hasPermission('mobile')) {
      moduleCards.add(
        HubMenuItem(
          icon: Icons.phone_android,
          title: 'Módulo Mobile',
          subtitle: 'Gestão de Dispositivos',
          onTap: () {
            Navigator.pushNamed(context, '/dashboard');
          },
        ),
      );
    }

    if (_hasPermission('totem')) {
      moduleCards.add(
        HubMenuItem(
          icon: Icons.desktop_windows,
          title: 'Módulo Totem',
          subtitle: 'Monitoramento de Totens',
          onTap: () {
            Navigator.pushNamed(context, '/totem_dashboard');
          },
        ),
      );
    }

    // Adiciona módulos dinâmicos
    for (final module in _availableModules) {
      // Pula os módulos fixos que já foram adicionados
      if (module.type == AssetModuleType.mobile ||
          module.type == AssetModuleType.totem) {
        continue;
      }

      moduleCards.add(
        HubMenuItem(
          icon: _getModuleIcon(module.type.iconName),
          title: module.name,
          subtitle: module.description.isNotEmpty
              ? module.description
              : module.type.displayName,
          onTap: () => _navigateToModule(module),
        ),
      );
    }

    // Adiciona painel admin
    if (widget.authService.isAdmin) {
      moduleCards.add(
        HubMenuItem(
          icon: Icons.admin_panel_settings,
          title: 'Painel de Controle',
          subtitle: 'Gerenciamento do Sistema',
          onTap: () {
            Navigator.pushNamed(context, '/admin_dashboard');
          },
        ),
      );
    }

    if (moduleCards.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhum módulo disponível',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Entre em contato com o administrador',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: moduleCards.length >= 4 ? 3 : 2,
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      childAspectRatio: 1.2,
      children: moduleCards,
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
    required Color color,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(icon, size: 18),
        label: isLoading
            ? const Text('Aguarde...')
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: color.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}