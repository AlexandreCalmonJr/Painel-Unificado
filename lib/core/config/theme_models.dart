import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, auto }

enum AppColorScheme { blue, green, purple, orange }

class ThemeConfig {
  final AppThemeMode mode;
  final AppColorScheme colorScheme;

  const ThemeConfig({
    this.mode = AppThemeMode.auto,
    this.colorScheme = AppColorScheme.blue,
  });

  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    return ThemeConfig(
      mode: AppThemeMode.values.firstWhere(
        (e) => e.toString() == json['mode'],
        orElse: () => AppThemeMode.auto,
      ),
      colorScheme: AppColorScheme.values.firstWhere(
        (e) => e.toString() == json['colorScheme'],
        orElse: () => AppColorScheme.blue,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'mode': mode.toString(), 'colorScheme': colorScheme.toString()};
  }

  ThemeConfig copyWith({AppThemeMode? mode, AppColorScheme? colorScheme}) {
    return ThemeConfig(
      mode: mode ?? this.mode,
      colorScheme: colorScheme ?? this.colorScheme,
    );
  }
}
