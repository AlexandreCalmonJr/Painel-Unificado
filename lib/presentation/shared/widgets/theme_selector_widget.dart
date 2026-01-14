// File: lib/widgets/theme_selector_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:painel_windowns/core/config/theme_models.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/core/utils/theme_utils.dart';
import 'package:painel_windowns/presentation/bloc/theme/theme_cubit.dart';
import 'package:painel_windowns/presentation/bloc/theme/theme_state.dart';

/// Widget para seleção de tema e esquema de cores
class ThemeSelectorWidget extends StatelessWidget {
  const ThemeSelectorWidget({super.key, this.showInDialog = false});
  final bool showInDialog;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.effectiveDarkMode;
        final themeCubit = context.read<ThemeCubit>();

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surface : AppColors.surfaceLightMode,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.border : AppColors.borderLight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Row(
                children: [
                  Icon(
                    Icons.palette,
                    color:
                        isDark ? AppColors.primary : AppColors.textPrimaryLight,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Personalização',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:
                          isDark
                              ? AppColors.textPrimary
                              : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Modo de tema (Light/Dark/Auto)
              Text(
                'Modo de Tema',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color:
                      isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 12),
              _buildThemeModeSelector(themeCubit, themeState, isDark),

              const SizedBox(height: 24),
              Divider(color: isDark ? AppColors.border : AppColors.borderLight),
              const SizedBox(height: 24),

              // Esquema de cores
              Text(
                'Esquema de Cores',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color:
                      isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 12),
              _buildColorSchemeSelector(themeCubit, themeState, isDark),

              if (showInDialog) ...[
                const SizedBox(height: 24),
                Divider(
                  color: isDark ? AppColors.border : AppColors.borderLight,
                ),
                const SizedBox(height: 16),
                _buildResetButton(context, themeCubit),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeModeSelector(
    ThemeCubit cubit,
    ThemeState state,
    bool isDark,
  ) {
    return Row(
      children:
          AppThemeMode.values.map((mode) {
            final isSelected = state.config.mode == mode;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _ThemeModeCard(
                  mode: mode,
                  isSelected: isSelected,
                  isDark: isDark,
                  palette: ColorPalettes.getPalette(state.config.colorScheme),
                  onTap: () => cubit.setThemeMode(mode),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildColorSchemeSelector(
    ThemeCubit cubit,
    ThemeState state,
    bool isDark,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children:
          AppColorScheme.values.map((scheme) {
            final isSelected = state.config.colorScheme == scheme;
            return _ColorSchemeCard(
              scheme: scheme,
              isSelected: isSelected,
              isDark: isDark,
              onTap: () => cubit.setColorScheme(scheme),
            );
          }).toList(),
    );
  }

  Widget _buildResetButton(BuildContext context, ThemeCubit cubit) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          cubit.resetToDefault();
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.refresh, size: 18),
        label: const Text('Restaurar Padrão'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  /// Mostra o seletor de tema em um dialog
  static void show(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (dialogContext) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: const ThemeSelectorWidget(showInDialog: true),
            ),
          ),
    );
  }
}

/// Card para seleção de modo de tema
class _ThemeModeCard extends StatelessWidget {
  const _ThemeModeCard({
    required this.mode,
    required this.isSelected,
    required this.isDark,
    required this.palette,
    required this.onTap,
  });
  final AppThemeMode mode;
  final bool isSelected;
  final bool isDark;
  final Map<String, Color> palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: AppConstants.animationNormal,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? palette['primary']!.withOpacity(0.15)
                  : (isDark
                      ? AppColors.background
                      : AppColors.surfaceLightVariant),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? palette['primary']!
                    : (isDark ? AppColors.border : AppColors.borderLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              ThemeUtils.getModeIcon(mode),
              color:
                  isSelected
                      ? palette['primary']
                      : (isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              ThemeUtils.getModeName(mode),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color:
                    isSelected
                        ? palette['primary']
                        : (isDark
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryLight),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Card para seleção de esquema de cores
class _ColorSchemeCard extends StatelessWidget {
  const _ColorSchemeCard({
    required this.scheme,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });
  final AppColorScheme scheme;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = ColorPalettes.getPalette(scheme);
    final primaryColor = palette['primary']!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: AppConstants.animationNormal,
        width: 90,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.background : AppColors.surfaceLightVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? primaryColor
                    : (isDark ? AppColors.border : AppColors.borderLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Preview de cores
            Container(
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, palette['accent']!],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child:
                  isSelected
                      ? const Center(
                        child: Icon(Icons.check, color: Colors.white, size: 20),
                      )
                      : null,
            ),
            const SizedBox(height: 8),

            // Nome do esquema
            Text(
              ColorPalettes.getSchemeName(scheme),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color:
                    isSelected
                        ? primaryColor
                        : (isDark
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryLight),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Botão compacto para abrir o seletor de tema
class ThemeSelectorButton extends StatelessWidget {
  const ThemeSelectorButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.effectiveDarkMode;

        return IconButton(
          onPressed: () => ThemeSelectorWidget.show(context),
          icon: Icon(
            Icons.palette,
            color:
                isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
          ),
          style: IconButton.styleFrom(
            backgroundColor: (isDark
                    ? AppColors.surface
                    : AppColors.surfaceLightMode)
                .withOpacity(0.5),
            padding: const EdgeInsets.all(12),
          ),
          tooltip: 'Personalizar Tema',
        );
      },
    );
  }
}
