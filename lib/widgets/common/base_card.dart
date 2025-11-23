// File: lib/widgets/common/base_card.dart (ENHANCED)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:painel_windowns/controllers/theme_controller.dart';
import 'package:painel_windowns/utils/app_constants.dart';

/// Widget base para cards com estilo consistente e efeitos modernos
class BaseCard extends StatefulWidget {
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
  final VoidCallback? onTap;
  final bool showBorder;
  final bool enableHoverEffect;
  final bool enableGlowEffect;

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
    this.onTap,
    this.showBorder = true,
    this.enableHoverEffect = false,
    this.enableGlowEffect = false,
  });

  @override
  State<BaseCard> createState() => _BaseCardState();
}

class _BaseCardState extends State<BaseCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeController = ThemeController.to;
      final isDark = themeController.isDarkMode;
      final palette = themeController.currentPalette;

      return MouseRegion(
        onEnter: widget.enableHoverEffect ? (_) => _onHover(true) : null,
        onExit: widget.enableHoverEffect ? (_) => _onHover(false) : null,
        cursor:
            widget.onTap != null
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder:
              (context, child) => Transform.scale(
                scale: widget.enableHoverEffect ? _scaleAnimation.value : 1.0,
                child: child,
              ),
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color:
                    widget.gradient == null
                        ? (widget.backgroundColor ??
                            (isDark
                                ? AppColors.surface
                                : AppColors.surfaceLightMode))
                        : null,
                gradient: widget.gradient,
                borderRadius:
                    widget.borderRadius ??
                    BorderRadius.circular(AppConstants.radiusL),
                boxShadow: [
                  BoxShadow(
                    color:
                        _isHovered && widget.enableGlowEffect
                            ? palette['primary']!.withOpacity(0.3)
                            : Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius:
                        _isHovered
                            ? (widget.elevation ?? 8) * 2
                            : (widget.elevation ?? 4),
                    offset: Offset(0, _isHovered ? 6 : 2),
                    spreadRadius: _isHovered && widget.enableGlowEffect ? 2 : 0,
                  ),
                ],
                border:
                    widget.showBorder
                        ? Border.all(
                          color:
                              _isHovered && widget.enableHoverEffect
                                  ? palette['primary']!.withOpacity(0.5)
                                  : (isDark
                                          ? AppColors.border
                                          : AppColors.borderLight)
                                      .withOpacity(0.1),
                          width: _isHovered ? 2 : 1,
                        )
                        : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.title != null || widget.actions != null)
                    _buildHeader(isDark, palette),
                  if (widget.expandChild)
                    Expanded(
                      child: Padding(
                        padding:
                            widget.padding ??
                            const EdgeInsets.all(AppConstants.spacingM),
                        child: widget.child,
                      ),
                    )
                  else
                    Padding(
                      padding:
                          widget.padding ??
                          const EdgeInsets.all(AppConstants.spacingM),
                      child: widget.child,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  void _onHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  Widget _buildHeader(bool isDark, Map<String, Color> palette) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: (isDark ? AppColors.border : AppColors.borderLight)
                .withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          if (widget.leading != null) ...[
            widget.leading!,
            const SizedBox(width: AppConstants.spacingM),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.title != null)
                  Text(
                    widget.title!,
                    style: AppTextStyles.h5.copyWith(
                      color:
                          isDark
                              ? AppColors.textPrimary
                              : AppColors.textPrimaryLight,
                    ),
                  ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  DefaultTextStyle(
                    style: AppTextStyles.bodySmall.copyWith(
                      color:
                          isDark
                              ? AppColors.textSecondary
                              : AppColors.textSecondaryLight,
                    ),
                    child: widget.subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (widget.actions != null) ...widget.actions!,
        ],
      ),
    );
  }
}
