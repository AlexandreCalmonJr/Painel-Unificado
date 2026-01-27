import 'package:flutter/material.dart';
import 'package:painel_windowns/presentation/features/admin/widgets/admin_modules_tab.dart';
import 'package:painel_windowns/services/auth_service.dart';
import 'package:painel_windowns/core/di/injection.dart';

/// Wrapper para integrar AdminModulesTab no HomelabApp
class ModulesView extends StatelessWidget {
  const ModulesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = getIt<AuthService>();

    return AdminModulesTab(authService: authService);
  }
}
