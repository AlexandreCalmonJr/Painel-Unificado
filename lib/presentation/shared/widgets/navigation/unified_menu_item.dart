// File: lib/presentation/shared/widgets/navigation/unified_menu_item.dart
// Unified menu item widget supporting sidebar and hub styles

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:painel_windowns/core/config/theme_models.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/core/utils/theme_utils.dart';
import 'package:painel_windowns/presentation/bloc/theme/theme_cubit.dart';
import 'package:painel_windowns/presentation/bloc/theme/theme_state.dart';

/// Menu item display style
enum MenuItemStyle {
  /// Compact sidebar style
  sidebar,

  /// Card-based hub style
  hub, compact,
}

/// Unified menu item widget
class UnifiedMenuItem extends StatelessWidget {
  const UnifiedMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    super.key,
    this.subtitle,
    this.style = MenuItemStyle.sidebar,
    this.index,
    this.selectedIndex,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final MenuItemStyle style;
  final int? index;
  final int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return style == MenuItemStyle.sidebar
        ? _buildSidebarStyle()
        : _buildHubStyle();
  }

  Widget _buildSidebarStyle() {
    final isSelected =
        index != null && selectedIndex != null && selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:
            isSelected
                ? Colors.blueAccent.withOpacity(0.3)
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70, size: 20),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        subtitle:
            subtitle != null
                ? Text(
                  subtitle!,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                )
                : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildHubStyle() {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.effectiveDarkMode;
        final palette = ColorPalettes.getPalette(themeState.config.colorScheme);

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface : AppColors.surfaceLightMode,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isDark
                        ? AppColors.border.withOpacity(0.5)
                        : AppColors.borderLight,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: palette['primary']!.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: palette['primary']),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          isDark
                              ? AppColors.textPrimary
                              : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isDark
                                ? AppColors.textSecondary
                                : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
