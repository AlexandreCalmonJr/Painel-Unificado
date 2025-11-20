// File: lib/widgets/common/stat_card.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/utils/app_constants.dart';

/// Widget reutilizável para cards de estatística
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String? subtitle;
  final Widget? trailing;
  final bool isCompact;
  final double? trend; // Porcentagem de mudança (ex: 5.2 = +5.2%)

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
    this.subtitle,
    this.trailing,
    this.isCompact = false,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Padding(
          padding: EdgeInsets.all(
            isCompact ? AppConstants.spacingM : AppConstants.spacingL,
          ),
          child: isCompact ? _buildCompactContent() : _buildFullContent(),
        ),
      ),
    );

    return onTap != null
        ? MouseRegion(
            cursor: SystemMouseCursors.click,
            child: card,
          )
        : card;
  }

  Widget _buildCompactContent() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.spacingS),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: Icon(icon, color: color, size: AppConstants.iconM),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.h4.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }

  Widget _buildFullContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Icon(icon, color: color, size: AppConstants.iconL),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: AppConstants.spacingM),
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppConstants.spacingS),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: AppTextStyles.h2.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (trend != null) ...[
              const SizedBox(width: AppConstants.spacingS),
              _buildTrendIndicator(),
            ],
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppConstants.spacingS),
          Text(
            subtitle!,
            style: AppTextStyles.caption,
          ),
        ],
      ],
    );
  }

  Widget _buildTrendIndicator() {
    final isPositive = trend! >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: (isPositive ? AppColors.success : AppColors.danger)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            size: 12,
            color: isPositive ? AppColors.success : AppColors.danger,
          ),
          const SizedBox(width: 2),
          Text(
            '${trend!.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isPositive ? AppColors.success : AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}
