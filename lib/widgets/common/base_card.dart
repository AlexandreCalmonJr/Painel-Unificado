// File: lib/widgets/common/base_card.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/utils/app_constants.dart';

/// Widget base para cards com estilo consistente
class BaseCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Gradient? gradient;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Widget? leading;
  final Widget? subtitle;
  final bool expandChild;

  const BaseCard({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.padding,
    this.backgroundColor,
    this.gradient,
    this.elevation,
    this.borderRadius,
    this.leading,
    this.subtitle,
    this.expandChild = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: gradient == null ? (backgroundColor ?? AppColors.surface) : null,
        gradient: gradient,
        borderRadius:
            borderRadius ?? BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: elevation ?? 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.border.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null || actions != null) _buildHeader(),
          if (expandChild)
            Expanded(
              child: Padding(
                padding: padding ?? const EdgeInsets.all(AppConstants.spacingM),
                child: child,
              ),
            )
          else
            Padding(
              padding: padding ?? const EdgeInsets.all(AppConstants.spacingM),
              child: child,
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppConstants.spacingM),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: AppTextStyles.h5.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  DefaultTextStyle(
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    child: subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
