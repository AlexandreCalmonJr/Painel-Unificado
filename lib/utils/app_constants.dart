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
  // ===== CORES PRIMÁRIAS =====
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);

  static const Color secondary = Color(0xFF607D8B);
  static const Color secondaryDark = Color(0xFF455A64);
  static const Color secondaryLight = Color(0xFF90A4AE);

  // ===== CORES DE STATUS =====
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color danger = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // ===== CORES DE ESTADO DE DISPOSITIVO =====
  static const Color online = Color(0xFF4CAF50);
  static const Color offline = Color(0xFF9E9E9E);
  static const Color maintenance = Color(0xFFFF9800);
  static const Color collected = Color(0xFF9C27B0);
  static const Color production = Color(0xFF2196F3);

  // ===== CORES DE BATERIA =====
  static const Color batteryFull = Color(0xFF4CAF50);
  static const Color batteryHigh = Color(0xFF8BC34A);
  static const Color batteryMedium = Color(0xFFFFC107);
  static const Color batteryLow = Color(0xFFFF9800);
  static const Color batteryCritical = Color(0xFFF44336);

  // ===== CORES NEUTRAS =====
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // ===== CORES DE FUNDO =====
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFFF5F5F5);

  // ===== CORES DE TEXTO =====
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textHint = Color(0xFF9E9E9E);

  // ===== CORES DE BORDA =====
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFFBDBDBD);

  // ===== CORES DE SOMBRA =====
  static const Color shadow = Color(0x1F000000);
  static const Color shadowDark = Color(0x3D000000);
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
