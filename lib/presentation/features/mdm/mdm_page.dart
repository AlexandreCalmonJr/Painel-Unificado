import 'package:flutter/material.dart';
import 'package:painel_windowns/core/di/injection.dart';
import 'package:painel_windowns/presentation/features/mobile/pages/mobile_dashboard_page.dart';
import 'package:painel_windowns/services/auth_service.dart';

/// Wrapper para integrar MobileDashboardPage no HomelabApp
class MDMView extends StatelessWidget {
  const MDMView({super.key});

  @override
  Widget build(BuildContext context) {
    return MobileDashboardPage(authService: getIt<AuthService>());
  }
}
