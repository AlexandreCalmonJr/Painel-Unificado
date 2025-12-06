// File: lib/widgets/common/badge_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:painel_windowns/controllers/theme_controller.dart';
import 'package:painel_windowns/utils/app_constants.dart';

enum BadgeType { success, error, warning, info, neutral }

/// Widget de badge moderno e reutilizável
class BadgeWidget extends StatelessWidget {
  final String label;
  final BadgeType type;
  final IconData? icon;
  final Color? customColor;
  final bool outlined;
  final VoidCallback? onTap;

  const BadgeWidget({
    super.key,
    required this.label,
    this.type = BadgeType.neutral,
    this.icon,
    this.customColor,
    this.outlined = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeController = ThemeController.to;
      final badgeColor =
          customColor ?? _getColor(type, themeController.currentPalette);

      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: outlined ? Colors.transparent : badgeColor.withOpacity(0.1),
            border: outlined ? Border.all(color: badgeColor, width: 1.5) : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: badgeColor),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: badgeColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Color _getColor(BadgeType type, Map<String, Color> palette) {
    switch (type) {
      case BadgeType.success:
        return AppColors.success;
      case BadgeType.error:
        return AppColors.danger;
      case BadgeType.warning:
        return AppColors.warning;
      case BadgeType.info:
        return AppColors.info;
      case BadgeType.neutral:
        return palette['primary']!;
    }
  }
}

/// Badge com contador
class CounterBadge extends StatelessWidget {
  final int count;
  final Color? color;
  final double size;

  const CounterBadge({
    super.key,
    required this.count,
    this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();

    return Obx(() {
      final themeController = ThemeController.to;
      final badgeColor = color ?? themeController.currentPalette['primary']!;

      return Container(
        width: size,
        height: size,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: badgeColor,
          borderRadius: BorderRadius.circular(size / 2),
          boxShadow: [
            BoxShadow(
              color: badgeColor.withOpacity(0.4),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            count > 99 ? '99+' : count.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.6,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    });
  }
}

/// Badge de status com ponto indicador
class StatusBadge extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color? activeColor;
  final Color? inactiveColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.isActive,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isActive
            ? (activeColor ?? AppColors.success)
            : (inactiveColor ?? AppColors.textSecondary);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
