import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:painel_windowns/core/config/theme_models.dart';
import 'package:painel_windowns/core/utils/theme_utils.dart';

/// Estado do tema da aplicação
class ThemeState extends Equatable {
  final ThemeConfig config;
  final bool effectiveDarkMode;

  const ThemeState({required this.config, required this.effectiveDarkMode});

  /// Estado inicial com configuração padrão
  factory ThemeState.initial() {
    return const ThemeState(
      config: ThemeConfig(),
      effectiveDarkMode: true, // Padrão é dark mode
    );
  }

  /// Getters convenientes
  bool get isDarkMode => effectiveDarkMode;
  AppThemeMode get themeMode => config.mode;
  AppColorScheme get colorScheme => config.colorScheme;

  ThemeMode get flutterThemeMode =>
      effectiveDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Retorna a paleta de cores atual
  Map<String, Color> get currentPalette =>
      ColorPalettes.getPalette(config.colorScheme);

  /// Cria uma cópia com modificações
  ThemeState copyWith({ThemeConfig? config, bool? effectiveDarkMode}) {
    return ThemeState(
      config: config ?? this.config,
      effectiveDarkMode: effectiveDarkMode ?? this.effectiveDarkMode,
    );
  }

  @override
  List<Object?> get props => [config, effectiveDarkMode];
}
