import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/core/di/injection.dart';
import 'package:painel_windowns/presentation/bloc/auth/auth_bloc.dart';
import 'package:painel_windowns/presentation/bloc/auth/auth_event.dart';
import 'package:painel_windowns/presentation/bloc/theme/theme_cubit.dart';
import 'package:painel_windowns/presentation/bloc/theme/theme_state.dart';
import 'package:painel_windowns/presentation/features/homelab/homelab_app.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/services/server_config_service.dart';
import 'package:painel_windowns/services/websocket_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.authService, super.key});
  final AuthService authService;

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // Controladores para os formulários
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  late TextEditingController _ipController;
  late TextEditingController _portController;

  // Serviços e estado da UI
  bool _isLoading = false;
  bool _obscurePassword = true;
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Configuração das animações
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

    // Inicia as animações
    _fadeController.forward();
    _slideController.forward();

    // Carrega a configuração do servidor salva
    final serverConfig = ServerConfigService.instance.loadConfig();
    _ipController = TextEditingController(text: serverConfig['ip']);
    _portController = TextEditingController(text: serverConfig['port']);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _ipController.dispose();
    _portController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorSnackbar('Por favor, preencha todos os campos');
      return;
    }

    setState(() => _isLoading = true);

    // Usar AuthBloc para login
    context.read<AuthBloc>().add(
      LoginRequested(
        username: _usernameController.text,
        password: _passwordController.text,
      ),
    );

    // Manter compatibilidade com AuthService por enquanto
    try {
      final result = await widget.authService.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (mounted) {
        if (result['success'] as bool) {
          // Animação de sucesso antes da navegação
          _showSuccessSnackbar('Login realizado com sucesso!');
          await Future<void>.delayed(const Duration(milliseconds: 1000));
          Navigator.of(context).pushReplacement(
            PageRouteBuilder<void>(
              pageBuilder:
                  (context, animation, _) =>
                      HomelabApp(authService: widget.authService),
              transitionDuration: const Duration(milliseconds: 500),
              transitionsBuilder: (context, animation, _, child) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
            ),
          );
        } else {
          _showErrorSnackbar(result['message'] as String);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Erro de conexão: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveServerConfig() async {
    if (_ipController.text.isEmpty || _portController.text.isEmpty) {
      _showErrorSnackbar('Por favor, preencha IP e porta do servidor');
      return;
    }

    await ServerConfigService.instance.saveConfig(
      _ipController.text,
      _portController.text,
    );

    // Tenta conectar o WebSocket com as novas configurações
    try {
      final wsService = getIt<WebSocketService>();
      final baseUrl = 'http://${_ipController.text}:${_portController.text}';
      wsService.connect(baseUrl);
    } catch (e) {
      print('Erro ao conectar WebSocket: $e');
    }

    if (mounted) {
      _showSuccessSnackbar('Configurações salvas com sucesso!');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      width: 420,
                      padding: const EdgeInsets.all(32.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color:
                            isDark
                                ? AppColors.surface
                                : AppColors.surfaceLightMode,
                        border: Border.all(
                          color:
                              isDark ? AppColors.border : AppColors.borderLight,
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo e título
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: palette['primary']!.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              LucideIcons.shieldCheck,
                              size: 48,
                              color: palette['primary'],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'MDM Control Panel',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color:
                                  isDark
                                      ? AppColors.textPrimary
                                      : AppColors.textPrimaryLight,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Tabs com design melhorado
                          Container(
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? AppColors.background
                                      : AppColors.surfaceLightVariant,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color:
                                    isDark
                                        ? AppColors.border
                                        : AppColors.borderLight,
                              ),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: TabBar(
                              controller: _tabController,
                              indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: palette['primary'],
                                boxShadow: [
                                  BoxShadow(
                                    color: palette['primary']!.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              labelColor: Colors.white,
                              unselectedLabelColor:
                                  isDark
                                      ? AppColors.textSecondary
                                      : AppColors.textSecondaryLight,
                              dividerColor: Colors.transparent,
                              indicatorSize: TabBarIndicatorSize.tab,
                              splashFactory: NoSplash.splashFactory,
                              overlayColor: WidgetStateProperty.all(
                                Colors.transparent,
                              ),
                              tabs: const [
                                Tab(
                                  icon: Icon(LucideIcons.logIn, size: 20),
                                  text: 'Login',
                                  height: 56,
                                ),
                                Tab(
                                  icon: Icon(LucideIcons.server, size: 20),
                                  text: 'Servidor',
                                  height: 56,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Conteúdo das tabs
                          SizedBox(
                            height: 280,
                            child: TabBarView(
                              controller: _tabController,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _buildLoginForm(isDark, palette),
                                _buildServerConfigForm(isDark, palette),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Assinatura do desenvolvedor
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: (isDark
                                      ? AppColors.background
                                      : AppColors.surfaceLightVariant)
                                  .withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    isDark
                                        ? AppColors.border
                                        : AppColors.borderLight,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.code,
                                  size: 18,
                                  color:
                                      isDark
                                          ? AppColors.textSecondary
                                          : AppColors.textSecondaryLight,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Desenvolvido por Alexandre Calmon - TI Bahia',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        isDark
                                            ? AppColors.textSecondary
                                            : AppColors.textSecondaryLight,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
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
      },
    );
  }

  Widget _buildLoginForm(bool isDark, Map<String, Color> palette) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTextField(
            controller: _usernameController,
            label: 'Usuário',
            icon: LucideIcons.user,
            textInputAction: TextInputAction.next,
            isDark: isDark,
            palette: palette,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _passwordController,
            label: 'Senha',
            icon: LucideIcons.lock,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _login(),
            isDark: isDark,
            palette: palette,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                color:
                    isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight,
              ),
              onPressed:
                  () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 32),
          _buildActionButton(
            onPressed: _login,
            text: 'Entrar',
            icon: LucideIcons.logIn,
            color: palette['primary'],
            isLoading: _isLoading,
          ),
          const SizedBox(height: 16),
          // Link para registro
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Não tem acesso? ',
                style: TextStyle(
                  color:
                      isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                  fontSize: 14,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed('/register'),
                style: TextButton.styleFrom(
                  foregroundColor: palette['primary'],
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Solicitar cadastro',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServerConfigForm(bool isDark, Map<String, Color> palette) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTextField(
            controller: _ipController,
            label: 'IP do Servidor',
            icon: LucideIcons.server,
            textInputAction: TextInputAction.next,
            isDark: isDark,
            palette: palette,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _portController,
            label: 'Porta do Servidor',
            icon: LucideIcons.network,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.number,
            onFieldSubmitted: (_) => _saveServerConfig(),
            isDark: isDark,
            palette: palette,
          ),
          const SizedBox(height: 32),
          _buildActionButton(
            onPressed: _saveServerConfig,
            text: 'Salvar Configuração',
            icon: LucideIcons.save,
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required Map<String, Color> palette,
    bool obscureText = false,
    TextInputAction? textInputAction,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      onFieldSubmitted: onFieldSubmitted,
      style: TextStyle(
        fontSize: 16,
        color: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color:
              isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
          fontSize: 14,
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.only(right: 12),
          child: Icon(
            icon,
            color:
                isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
            size: 20,
          ),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor:
            isDark ? AppColors.background : AppColors.surfaceLightVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.border : AppColors.borderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.border : AppColors.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette['primary']!, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
    Color? color,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (color ?? AppColors.primary).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon:
            isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Icon(icon, size: 18),
        label:
            isLoading
                ? const Text('Carregando...')
                : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
