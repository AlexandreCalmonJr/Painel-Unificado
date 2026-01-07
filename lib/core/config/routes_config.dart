import 'package:flutter/material.dart';

/// Configuração de rotas da aplicação
class AppRoutes {
  // Rotas de autenticação
  static const String splash = '/';
  static const String login = '/login';

  // Rotas principais
  static const String home = '/home';

  // Rotas de devices
  static const String devicesDashboard = '/devices';
  static const String deviceDetail = '/devices/detail';

  // Rotas de totems
  static const String totemsDashboard = '/totems';
  static const String totemDetail = '/totems/detail';

  // Rotas de módulos
  static const String modulesDashboard = '/modules';
  static const String moduleDetail = '/modules/detail';

  // Rotas de admin
  static const String adminDashboard = '/admin';

  // Rotas de configuração
  static const String settings = '/settings';
  static const String profile = '/profile';

  /// Mapa de rotas (será implementado quando migrarmos as páginas)
  static Map<String, WidgetBuilder> get routes => {
    // TODO: Implementar rotas quando as páginas forem migradas
  };
}
