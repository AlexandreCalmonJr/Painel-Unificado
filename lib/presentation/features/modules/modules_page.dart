import 'package:flutter/material.dart';
import 'package:painel_windowns/core/di/injection.dart';
import 'package:painel_windowns/presentation/features/admin/widgets/admin_modules_tab.dart';
import 'package:painel_windowns/services/auth_service.dart';

/// Wrapper para integrar AdminModulesTab no HomelabApp
class ModulesPage extends StatelessWidget {
  const ModulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = getIt<AuthService>();

    return AdminModulesTab(authService: authService);
  }
}
