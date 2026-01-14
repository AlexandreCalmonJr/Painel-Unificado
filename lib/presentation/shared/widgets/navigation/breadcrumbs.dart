// File: lib/presentation/shared/widgets/navigation/breadcrumbs.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/core/constants/layout_constants.dart';

/// Item de breadcrumb
class BreadcrumbItem {
  const BreadcrumbItem({required this.label, this.icon, this.onTap});

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
}

/// Widget de breadcrumbs para navegação hierárquica
class Breadcrumbs extends StatelessWidget {
  const Breadcrumbs({required this.items, super.key, this.isDark = false});

  final List<BreadcrumbItem> items;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LayoutConstants.spaceL,
        vertical: LayoutConstants.spaceM,
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _buildBreadcrumbItem(items[i], i == items.length - 1),
            if (i < items.length - 1) _buildSeparator(),
          ],
        ],
      ),
    );
  }

  Widget _buildBreadcrumbItem(BreadcrumbItem item, bool isLast) {
    final textColor =
        isLast
            ? (isDark ? AppColors.textPrimary : AppColors.textPrimaryLight)
            : AppColors.textSecondary;

    final fontWeight = isLast ? FontWeight.w600 : FontWeight.normal;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.icon != null) ...[
          Icon(item.icon, size: LayoutConstants.iconSizeS, color: textColor),
          SizedBox(width: LayoutConstants.spaceS),
        ],
        Text(
          item.label,
          style: AppTextStyles.bodySmall.copyWith(
            color: textColor,
            fontWeight: fontWeight,
          ),
        ),
      ],
    );

    if (item.onTap != null && !isLast) {
      return InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(LayoutConstants.cardRadiusSmall),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LayoutConstants.spaceS,
            vertical: LayoutConstants.spaceXS,
          ),
          child: content,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LayoutConstants.spaceS,
        vertical: LayoutConstants.spaceXS,
      ),
      child: content,
    );
  }

  Widget _buildSeparator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: LayoutConstants.spaceS),
      child: Icon(
        Icons.chevron_right,
        size: LayoutConstants.iconSizeS,
        color: AppColors.textSecondary,
      ),
    );
  }
}

/// Helper para criar breadcrumbs comuns
class BreadcrumbsHelper {
  /// Cria breadcrumbs com Home como primeiro item
  static List<BreadcrumbItem> withHome({
    required BuildContext context,
    required List<String> path,
  }) {
    return [
      BreadcrumbItem(
        label: 'Home',
        icon: Icons.home,
        onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
      ),
      ...path.map((label) => BreadcrumbItem(label: label)),
    ];
  }

  /// Cria breadcrumbs simples sem ícone
  static List<BreadcrumbItem> simple(List<String> path) {
    return path.map((label) => BreadcrumbItem(label: label)).toList();
  }

  /// Cria breadcrumbs com navegação customizada
  static List<BreadcrumbItem> withNavigation({
    required List<String> labels,
    required List<VoidCallback?> onTaps,
  }) {
    assert(
      labels.length == onTaps.length,
      'Labels and onTaps must have same length',
    );

    return List.generate(
      labels.length,
      (i) => BreadcrumbItem(label: labels[i], onTap: onTaps[i]),
    );
  }
}
