// File: lib/config/theme_config.dart
import 'package:flutter/material.dart';

/// Tipos de tema disponíveis
enum AppThemeMode {
  light,
  dark,
  auto, // Automático baseado em horário
}

/// Paletas de cores disponíveis
enum AppColorScheme { blue, purple, green, orange, red }

/// Configuração de tema do aplicativo
class ThemeConfig {
  final AppThemeMode mode;
  final AppColorScheme colorScheme;

  const ThemeConfig({
    this.mode = AppThemeMode.dark,
    this.colorScheme = AppColorScheme.blue,
  });

  ThemeConfig copyWith({AppThemeMode? mode, AppColorScheme? colorScheme}) {
    return ThemeConfig(
      mode: mode ?? this.mode,
      colorScheme: colorScheme ?? this.colorScheme,
    );
  }

  Map<String, dynamic> toJson() {
    return {'mode': mode.name, 'colorScheme': colorScheme.name};
  }

  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    return ThemeConfig(
      mode: AppThemeMode.values.firstWhere(
        (e) => e.name == json['mode'],
        orElse: () => AppThemeMode.dark,
      ),
      colorScheme: AppColorScheme.values.firstWhere(
        (e) => e.name == json['colorScheme'],
        orElse: () => AppColorScheme.blue,
      ),
    );
  }
}

/// Paletas de cores para cada esquema
class ColorPalettes {
  // ===== BLUE THEME (Padrão) =====
  static const Map<String, Color> blue = {
    'primary': Color(0xFF3B82F6),
    'primaryDark': Color(0xFF2563EB),
    'accent': Color(0xFF06B6D4),
    'success': Color(0xFF10B981),
    'warning': Color(0xFFF59E0B),
    'danger': Color(0xFFEF4444),
  };

  // ===== PURPLE THEME =====
  static const Map<String, Color> purple = {
    'primary': Color(0xFF8B5CF6),
    'primaryDark': Color(0xFF7C3AED),
    'accent': Color(0xFFA78BFA),
    'success': Color(0xFF10B981),
    'warning': Color(0xFFF59E0B),
    'danger': Color(0xFFEF4444),
  };

  // ===== GREEN THEME =====
  static const Map<String, Color> green = {
    'primary': Color(0xFF10B981),
    'primaryDark': Color(0xFF059669),
    'accent': Color(0xFF34D399),
    'success': Color(0xFF10B981),
    'warning': Color(0xFFF59E0B),
    'danger': Color(0xFFEF4444),
  };

  // ===== ORANGE THEME =====
  static const Map<String, Color> orange = {
    'primary': Color(0xFFF59E0B),
    'primaryDark': Color(0xFFD97706),
    'accent': Color(0xFFFBBF24),
    'success': Color(0xFF10B981),
    'warning': Color(0xFFF59E0B),
    'danger': Color(0xFFEF4444),
  };

  // ===== RED THEME =====
  static const Map<String, Color> red = {
    'primary': Color(0xFFEF4444),
    'primaryDark': Color(0xFFDC2626),
    'accent': Color(0xFFF87171),
    'success': Color(0xFF10B981),
    'warning': Color(0xFFF59E0B),
    'danger': Color(0xFFEF4444),
  };

  /// Retorna a paleta de cores para o esquema especificado
  static Map<String, Color> getPalette(AppColorScheme scheme) {
    switch (scheme) {
      case AppColorScheme.blue:
        return blue;
      case AppColorScheme.purple:
        return purple;
      case AppColorScheme.green:
        return green;
      case AppColorScheme.orange:
        return orange;
      case AppColorScheme.red:
        return red;
    }
  }

  /// Retorna o nome amigável do esquema de cores
  static String getSchemeName(AppColorScheme scheme) {
    switch (scheme) {
      case AppColorScheme.blue:
        return 'Azul';
      case AppColorScheme.purple:
        return 'Roxo';
      case AppColorScheme.green:
        return 'Verde';
      case AppColorScheme.orange:
        return 'Laranja';
      case AppColorScheme.red:
        return 'Vermelho';
    }
  }

  /// Retorna o ícone para o esquema de cores
  static IconData getSchemeIcon(AppColorScheme scheme) {
    switch (scheme) {
      case AppColorScheme.blue:
        return Icons.water_drop;
      case AppColorScheme.purple:
        return Icons.auto_awesome;
      case AppColorScheme.green:
        return Icons.eco;
      case AppColorScheme.orange:
        return Icons.wb_sunny;
      case AppColorScheme.red:
        return Icons.favorite;
    }
  }
}

/// Gradientes para cada esquema de cores
class ThemeGradients {
  static LinearGradient getSidebarGradient(AppColorScheme scheme) {
    final palette = ColorPalettes.getPalette(scheme);
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        palette['primaryDark']!,
        const Color(0xFF0F172A), // Slate 900
      ],
    );
  }

  static LinearGradient getPrimaryButtonGradient(AppColorScheme scheme) {
    final palette = ColorPalettes.getPalette(scheme);
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [palette['primary']!, palette['primaryDark']!],
    );
  }

  static LinearGradient getLoginBackgroundGradient(AppColorScheme scheme) {
    final palette = ColorPalettes.getPalette(scheme);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF0F172A), // Slate 900
        palette['primaryDark']!,
        const Color(0xFF000000), // Black
      ],
    );
  }

  static LinearGradient getCardGradient(AppColorScheme scheme) {
    final palette = ColorPalettes.getPalette(scheme);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        palette['primary']!.withOpacity(0.1),
        palette['accent']!.withOpacity(0.05),
      ],
    );
  }
}

/// Utilitários para tema
class ThemeUtils {
  /// Determina se deve usar tema escuro baseado no horário
  static bool shouldUseDarkMode() {
    final hour = DateTime.now().hour;
    // Modo escuro entre 18h e 6h
    return hour >= 18 || hour < 6;
  }

  /// Retorna o modo efetivo considerando o modo automático
  static bool getEffectiveDarkMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.auto:
        return shouldUseDarkMode();
    }
  }

  /// Retorna o nome amigável do modo de tema
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

  /// Retorna o ícone para o modo de tema
  static IconData getModeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.auto:
        return Icons.brightness_auto;
    }
  }
}
