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
  final double? elevation;
  final BorderRadius? borderRadius;
  final Widget? leading;
  final Widget? subtitle;

  const BaseCard({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.padding,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.leading,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? 2,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(AppConstants.radiusM),
      ),
      color: backgroundColor ?? AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || actions != null) _buildHeader(),
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
          bottom: BorderSide(color: AppColors.border),
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
                    style: AppTextStyles.h5,
                  ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  subtitle!,
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
