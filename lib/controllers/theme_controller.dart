// File: lib/controllers/theme_controller.dart (ATUALIZADO)
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:painel_windowns/config/theme_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  // Observables
  final Rx<ThemeConfig> _themeConfig = const ThemeConfig().obs;
  final _effectiveDarkMode = true.obs;

  // Keys para SharedPreferences
  final _prefsKey = 'theme_config';

  // Getters
  ThemeConfig get themeConfig => _themeConfig.value;
  bool get isDarkMode => _effectiveDarkMode.value;
  AppThemeMode get themeMode => _themeConfig.value.mode;
  AppColorScheme get colorScheme => _themeConfig.value.colorScheme;

  ThemeMode get flutterThemeMode =>
      _effectiveDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  // Retorna a paleta de cores atual
  Map<String, Color> get currentPalette =>
      ColorPalettes.getPalette(_themeConfig.value.colorScheme);

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromPrefs();

    // Se modo automático, atualiza a cada hora
    if (_themeConfig.value.mode == AppThemeMode.auto) {
      _startAutoModeTimer();
    }
  }

  /// Carrega configuração de tema do SharedPreferences
  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString(_prefsKey);

      if (configJson != null) {
        final config = ThemeConfig.fromJson(json.decode(configJson));
        _themeConfig.value = config;
      }

      _updateEffectiveDarkMode();
    } catch (e) {
      print('Erro ao carregar tema: $e');
      // Usa configuração padrão em caso de erro
      _themeConfig.value = const ThemeConfig();
      _updateEffectiveDarkMode();
    }
  }

  /// Salva configuração de tema no SharedPreferences
  Future<void> _saveThemeToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = json.encode(_themeConfig.value.toJson());
      await prefs.setString(_prefsKey, configJson);
    } catch (e) {
      print('Erro ao salvar tema: $e');
    }
  }

  /// Atualiza o modo efetivo (considerando modo automático)
  void _updateEffectiveDarkMode() {
    _effectiveDarkMode.value = ThemeUtils.getEffectiveDarkMode(
      _themeConfig.value.mode,
    );
    Get.changeThemeMode(flutterThemeMode);
  }

  /// Timer para modo automático
  void _startAutoModeTimer() {
    // Verifica a cada hora se deve mudar o tema
    Future.delayed(const Duration(hours: 1), () {
      if (_themeConfig.value.mode == AppThemeMode.auto) {
        _updateEffectiveDarkMode();
        _startAutoModeTimer(); // Reinicia o timer
      }
    });
  }

  /// Alterna entre modo claro e escuro (apenas se não estiver em auto)
  Future<void> toggleTheme() async {
    if (_themeConfig.value.mode == AppThemeMode.auto) {
      // Se está em auto, muda para dark ou light baseado no estado atual
      final newMode =
          _effectiveDarkMode.value ? AppThemeMode.light : AppThemeMode.dark;
      await setThemeMode(newMode);
    } else {
      // Alterna entre dark e light
      final newMode =
          _themeConfig.value.mode == AppThemeMode.dark
              ? AppThemeMode.light
              : AppThemeMode.dark;
      await setThemeMode(newMode);
    }
  }

  /// Define o modo de tema
  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeConfig.value = _themeConfig.value.copyWith(mode: mode);
    _updateEffectiveDarkMode();
    await _saveThemeToPrefs();

    // Reinicia timer se mudou para auto
    if (mode == AppThemeMode.auto) {
      _startAutoModeTimer();
    }
  }

  /// Define o esquema de cores
  Future<void> setColorScheme(AppColorScheme scheme) async {
    _themeConfig.value = _themeConfig.value.copyWith(colorScheme: scheme);
    await _saveThemeToPrefs();

    // Força atualização da UI
    update();
  }

  /// Define tema completo
  Future<void> setTheme({
    AppThemeMode? mode,
    AppColorScheme? colorScheme,
  }) async {
    _themeConfig.value = _themeConfig.value.copyWith(
      mode: mode,
      colorScheme: colorScheme,
    );
    _updateEffectiveDarkMode();
    await _saveThemeToPrefs();

    if (mode == AppThemeMode.auto) {
      _startAutoModeTimer();
    }

    update();
  }

  /// Reseta para configuração padrão
  Future<void> resetToDefault() async {
    _themeConfig.value = const ThemeConfig();
    _updateEffectiveDarkMode();
    await _saveThemeToPrefs();
  }
}
