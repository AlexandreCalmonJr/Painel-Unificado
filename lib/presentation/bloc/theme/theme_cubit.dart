import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:painel_windowns/core/config/theme_models.dart';
import 'package:painel_windowns/core/utils/theme_utils.dart';
import 'package:painel_windowns/presentation/bloc/theme/theme_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cubit para gerenciar o tema da aplicação
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState.initial()) {
    _initialize();
  }

  static const String _prefsKey = 'theme_config';
  Timer? _autoModeTimer;

  /// Inicializa o cubit carregando configurações salvas
  Future<void> _initialize() async {
    await _loadThemeFromPrefs();

    // Se modo automático, inicia timer
    if (state.config.mode == AppThemeMode.auto) {
      _startAutoModeTimer();
    }
  }

  /// Carrega configuração de tema do SharedPreferences
  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString(_prefsKey);

      if (configJson != null) {
        final config = ThemeConfig.fromJson(
          json.decode(configJson) as Map<String, dynamic>,
        );
        _updateThemeConfig(config);
      } else {
        _updateEffectiveDarkMode();
      }
    } catch (e) {
      print('Erro ao carregar tema: $e');
      // Usa configuração padrão em caso de erro
      _updateEffectiveDarkMode();
    }
  }

  /// Salva configuração de tema no SharedPreferences
  Future<void> _saveThemeToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = json.encode(state.config.toJson());
      await prefs.setString(_prefsKey, configJson);
    } catch (e) {
      print('Erro ao salvar tema: $e');
    }
  }

  /// Atualiza o tema com nova configuração
  void _updateThemeConfig(ThemeConfig config) {
    final effectiveDarkMode = ThemeUtils.getEffectiveDarkMode(config.mode);
    emit(state.copyWith(config: config, effectiveDarkMode: effectiveDarkMode));
  }

  /// Atualiza apenas o modo efetivo (considerando modo automático)
  void _updateEffectiveDarkMode() {
    final effectiveDarkMode = ThemeUtils.getEffectiveDarkMode(
      state.config.mode,
    );
    emit(state.copyWith(effectiveDarkMode: effectiveDarkMode));
  }

  /// Timer para modo automático
  void _startAutoModeTimer() {
    _autoModeTimer?.cancel();

    // Verifica a cada hora se deve mudar o tema
    _autoModeTimer = Timer.periodic(const Duration(hours: 1), (_) {
      if (state.config.mode == AppThemeMode.auto) {
        _updateEffectiveDarkMode();
      } else {
        _autoModeTimer?.cancel();
      }
    });
  }

  /// Alterna entre modo claro e escuro
  Future<void> toggleTheme() async {
    if (state.config.mode == AppThemeMode.auto) {
      // Se está em auto, muda para dark ou light baseado no estado atual
      final newMode =
          state.effectiveDarkMode ? AppThemeMode.light : AppThemeMode.dark;
      await setThemeMode(newMode);
    } else {
      // Alterna entre dark e light
      final newMode =
          state.config.mode == AppThemeMode.dark
              ? AppThemeMode.light
              : AppThemeMode.dark;
      await setThemeMode(newMode);
    }
  }

  /// Define o modo de tema
  Future<void> setThemeMode(AppThemeMode mode) async {
    final newConfig = state.config.copyWith(mode: mode);
    _updateThemeConfig(newConfig);
    await _saveThemeToPrefs();

    // Reinicia timer se mudou para auto
    if (mode == AppThemeMode.auto) {
      _startAutoModeTimer();
    } else {
      _autoModeTimer?.cancel();
    }
  }

  /// Define o esquema de cores
  Future<void> setColorScheme(AppColorScheme scheme) async {
    final newConfig = state.config.copyWith(colorScheme: scheme);
    emit(state.copyWith(config: newConfig));
    await _saveThemeToPrefs();
  }

  /// Define tema completo
  Future<void> setTheme({
    AppThemeMode? mode,
    AppColorScheme? colorScheme,
  }) async {
    final newConfig = state.config.copyWith(
      mode: mode,
      colorScheme: colorScheme,
    );
    _updateThemeConfig(newConfig);
    await _saveThemeToPrefs();

    if (mode == AppThemeMode.auto) {
      _startAutoModeTimer();
    } else {
      _autoModeTimer?.cancel();
    }
  }

  /// Reseta para configuração padrão
  Future<void> resetToDefault() async {
    _updateThemeConfig(const ThemeConfig());
    await _saveThemeToPrefs();
    _autoModeTimer?.cancel();
  }

  @override
  Future<void> close() {
    _autoModeTimer?.cancel();
    return super.close();
  }
}
