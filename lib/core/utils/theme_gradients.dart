import 'package:flutter/material.dart';
import 'package:painel_windowns/core/config/theme_models.dart';
import 'package:painel_windowns/core/utils/theme_utils.dart';

/// Utility class for generating theme-aware gradients
class ThemeGradients {
  /// Returns a login background gradient based on the color scheme
  static LinearGradient getLoginBackgroundGradient(AppColorScheme scheme) {
    final palette = ColorPalettes.getPalette(scheme);
    final primaryColor = palette['primary']!;

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF0F172A), // Slate 900
        _darken(primaryColor, 0.3),
        const Color(0xFF000000), // Black
      ],
    );
  }

  /// Returns a primary button gradient based on the color scheme
  static LinearGradient getPrimaryButtonGradient(AppColorScheme scheme) {
    final palette = ColorPalettes.getPalette(scheme);
    final primaryColor = palette['primary']!;

    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [primaryColor, _darken(primaryColor, 0.1)],
    );
  }

  /// Returns a sidebar gradient based on the color scheme
  static LinearGradient getSidebarGradient(AppColorScheme scheme) {
    final palette = ColorPalettes.getPalette(scheme);
    final primaryColor = palette['primary']!;

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        _darken(primaryColor, 0.3),
        const Color(0xFF0F172A), // Slate 900
      ],
    );
  }

  /// Helper method to darken a color
  static Color _darken(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final darkened = hsl.withLightness(
      (hsl.lightness - amount).clamp(0.0, 1.0),
    );

    return darkened.toColor();
  }
}
