// File: lib/utils/app_constants.dart
import 'package:flutter/material.dart';

/// Constantes de UI da aplicação
class AppConstants {
  // ===== SPACING =====
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // ===== BORDER RADIUS =====
  static const double radiusXS = 2.0;
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusCircle = 999.0;

  // ===== ICON SIZES =====
  static const double iconXS = 12.0;
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;

  // ===== FONT SIZES =====
  static const double fontXS = 10.0;
  static const double fontS = 12.0;
  static const double fontM = 14.0;
  static const double fontL = 16.0;
  static const double fontXL = 20.0;
  static const double fontXXL = 24.0;

  // ===== ANIMATION DURATIONS =====
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ===== PAGINATION =====
  static const int defaultPageSize = 10;
  static const List<int> pageSizeOptions = [10, 25, 50, 100];

  // ===== DEBOUNCE =====
  static const Duration searchDebounce = Duration(milliseconds: 500);

  // ===== REFRESH =====
  static const Duration autoRefreshInterval = Duration(seconds: 15);
}

/// Cores da aplicação
class AppColors {
  // ===== PALETA CYBER/ENTERPRISE (DARK MODE) =====

  // Backgrounds
  static const Color background = Color(0xFF0B1120); // Rich Black/Blue
  static const Color surface = Color(0xFF1E293B); // Slate 800
  static const Color surfaceLight = Color(0xFF334155); // Slate 700

  // Brand Colors
  static const Color primary = Color(0xFF3B82F6); // Royal Blue
  static const Color primaryDark = Color(0xFF2563EB); // Deep Blue
  static const Color accent = Color(0xFF06B6D4); // Cyan/Neon Blue

  // Status Colors (Vibrant for Dark Mode)
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color danger = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF3B82F6); // Blue

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC); // Slate 50 (White-ish)
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color textHint = Color(0xFF64748B); // Slate 500
  static const Color textDisabled = Color(0xFF475569); // Slate 600

  // Borders & Dividers
  static const Color border = Color(0xFF334155); // Slate 700

  // Legacy Mappings (para manter compatibilidade enquanto migra)
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey100 = Color(0xFF1E293B); // Mapped to Surface
  static const Color grey200 = Color(0xFF334155); // Mapped to Surface Light

  // Device Status Colors
  static const Color online = success;
  static const Color offline = textDisabled;
  static const Color maintenance = warning;
  static const Color collected = Color(0xFFA855F7); // Purple
  static const Color production = primary;

  // Battery Colors
  static const Color batteryFull = success;
  static const Color batteryHigh = Color(0xFF84CC16); // Lime
  static const Color batteryMedium = warning;
  static const Color batteryLow = Color(0xFFF97316); // Orange
  static const Color batteryCritical = danger;

  // Shadows
  static const Color shadow = Color(0x40000000); // Darker shadow

  // ===== LIGHT MODE PALETTE =====
  static const Color backgroundLight = Color(0xFFF1F5F9); // Slate 100
  static const Color surfaceLightMode = Color(0xFFFFFFFF); // White
  static const Color surfaceLightVariant = Color(0xFFE2E8F0); // Slate 200

  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500
  static const Color borderLight = Color(0xFFCBD5E1); // Slate 300
}

class AppGradients {
  static const LinearGradient sidebar = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1E3A8A), // Blue 900
      Color(0xFF0F172A), // Slate 900
    ],
  );

  static const LinearGradient primaryButton = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF3B82F6), // Blue 500
      Color(0xFF2563EB), // Blue 600
    ],
  );

  static const LinearGradient loginBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F172A), // Slate 900
      Color(0xFF1E3A8A), // Blue 900
      Color(0xFF000000), // Black
    ],
  );
}

/// Estilos de texto da aplicação
class AppTextStyles {
  // ===== HEADINGS =====
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle h5 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle h6 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ===== BODY =====
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  // ===== LABELS =====
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  // ===== BUTTONS =====
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // ===== CAPTION =====
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle captionSmall = TextStyle(
    fontSize: 10,
    color: AppColors.textHint,
  );
}
