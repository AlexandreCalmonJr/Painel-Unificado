import 'package:flutter/material.dart';
import 'package:painel_windowns/core/config/theme_models.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';

class ThemeUtils {
  static bool getEffectiveDarkMode(AppThemeMode mode) {
    if (mode == AppThemeMode.auto) {
      final hour = DateTime.now().hour;
      return hour < 6 || hour >= 18;
    }
    return mode == AppThemeMode.dark;
  }

  static IconData getModeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.wb_sunny;
      case AppThemeMode.dark:
        return Icons.nightlight_round;
      case AppThemeMode.auto:
        return Icons.brightness_auto;
    }
  }

  static String getModeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Claro';
      case AppThemeMode.dark:
        return 'Escuro';
      case AppThemeMode.auto:
        return 'Automático';
    }
  }
}

class ColorPalettes {
  static Map<String, Color> getPalette(AppColorScheme scheme) {
    switch (scheme) {
      case AppColorScheme.blue:
        return {'primary': AppColors.primary, 'accent': AppColors.accent};
      case AppColorScheme.green:
        return {'primary': AppColors.success, 'accent': AppColors.primary};
      case AppColorScheme.purple:
        return {'primary': AppColors.collected, 'accent': AppColors.primary};
      case AppColorScheme.orange:
        return {'primary': AppColors.warning, 'accent': AppColors.danger};
    }
  }

  static String getSchemeName(AppColorScheme scheme) {
    switch (scheme) {
      case AppColorScheme.blue:
        return 'Azul (Padrão)';
      case AppColorScheme.green:
        return 'Verde';
      case AppColorScheme.purple:
        return 'Roxo';
      case AppColorScheme.orange:
        return 'Laranja';
    }
  }
}
