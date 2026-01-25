// File: lib/widgets/common/stat_card.dart (ENHANCED)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/core/utils/theme_utils.dart';
import 'package:painel_windowns/presentation/bloc/theme/theme_cubit.dart';
import 'package:painel_windowns/presentation/bloc/theme/theme_state.dart';

/// Widget reutilizável para cards de estatística com animações e efeitos modernos
class StatCard extends StatefulWidget {
  const StatCard({
    required this.title,
    required this.value,
    required this.icon,
    super.key,
    this.color,
    this.onTap,
    this.subtitle,
    this.trailing,
    this.isCompact = false,
    this.trend,
    this.showGradient = false,
    this.enableAnimation = true,
  });
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final String? subtitle;
  final Widget? trailing;
  final bool isCompact;
  final double? trend; // Porcentagem de mudança (ex: 5.2 = +5.2%)
  final bool showGradient;
  final bool enableAnimation;

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    if (widget.enableAnimation) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _controller.forward();
          _controller.reverse();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.effectiveDarkMode;
        final palette = ColorPalettes.getPalette(themeState.config.colorScheme);
        final cardColor = widget.color ?? palette['primary']!;

        return MouseRegion(
          onEnter: (_) => _onHover(true),
          onExit: (_) => _onHover(false),
          cursor:
              widget.onTap != null
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.basic,
          child: AnimatedBuilder(
            animation: _controller,
            builder:
                (context, child) => Transform.scale(
                  scale: _isHovered ? _scaleAnimation.value : 1.0,
                  child: child,
                ),
            child: GestureDetector(
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color:
                      widget.showGradient
                          ? null
                          : (isDark
                              ? AppColors.surface
                              : AppColors.surfaceLightMode),
                  gradient:
                      widget.showGradient
                          ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [cardColor.withOpacity(0.8), cardColor],
                          )
                          : null,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  boxShadow: [
                    BoxShadow(
                      color:
                          _isHovered
                              ? cardColor.withOpacity(0.3)
                              : Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                      blurRadius: _isHovered ? 12 : 4,
                      offset: Offset(0, _isHovered ? 6 : 2),
                      spreadRadius: _isHovered ? 2 : 0,
                    ),
                  ],
                  border: Border.all(
                    color:
                        _isHovered
                            ? cardColor.withOpacity(0.5)
                            : (isDark
                                    ? AppColors.border
                                    : AppColors.borderLight)
                                .withOpacity(0.1),
                    width: _isHovered ? 2 : 1,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(
                    widget.isCompact
                        ? AppConstants.spacingM
                        : AppConstants.spacingL,
                  ),
                  child:
                      widget.isCompact
                          ? _buildCompactContent(isDark, cardColor)
                          : _buildFullContent(isDark, cardColor),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered && widget.onTap != null) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  Widget _buildCompactContent(bool isDark, Color cardColor) {
    final textColor = widget.showGradient ? Colors.white : cardColor;

    return Row(
      children: [
        AnimatedBuilder(
          animation: _rotationAnimation,
          builder:
              (context, child) => Transform.rotate(
                angle: _isHovered ? _rotationAnimation.value : 0,
                child: child,
              ),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spacingS),
            decoration: BoxDecoration(
              color:
                  widget.showGradient
                      ? Colors.white.withOpacity(0.2)
                      : cardColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Icon(
              widget.icon,
              color: widget.showGradient ? Colors.white : cardColor,
              size: AppConstants.iconM,
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: AppTextStyles.bodySmall.copyWith(
                  color:
                      widget.showGradient
                          ? Colors.white.withOpacity(0.9)
                          : (isDark
                              ? AppColors.textSecondary
                              : AppColors.textSecondaryLight),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.value,
                style: AppTextStyles.h4.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (widget.trailing != null) widget.trailing!,
      ],
    );
  }

  Widget _buildFullContent(bool isDark, Color cardColor) {
    final textColor = widget.showGradient ? Colors.white : cardColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder:
                  (context, child) => Transform.rotate(
                    angle: _isHovered ? _rotationAnimation.value : 0,
                    child: child,
                  ),
              child: Container(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                decoration: BoxDecoration(
                  color:
                      widget.showGradient
                          ? Colors.white.withOpacity(0.2)
                          : cardColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.showGradient ? Colors.white : cardColor,
                  size: AppConstants.iconL,
                ),
              ),
            ),
            if (widget.trailing != null) widget.trailing!,
          ],
        ),
        const SizedBox(height: AppConstants.spacingM),
        Text(
          widget.title,
          style: AppTextStyles.bodyMedium.copyWith(
            color:
                widget.showGradient
                    ? Colors.white.withOpacity(0.9)
                    : (isDark
                        ? AppColors.textSecondary
                        : AppColors.textSecondaryLight),
          ),
        ),
        const SizedBox(height: AppConstants.spacingS),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              widget.value,
              style: AppTextStyles.h2.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.trend != null) ...[
              const SizedBox(width: AppConstants.spacingS),
              _buildTrendIndicator(),
            ],
          ],
        ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: AppConstants.spacingS),
          Text(
            widget.subtitle!,
            style: AppTextStyles.caption.copyWith(
              color:
                  widget.showGradient
                      ? Colors.white.withOpacity(0.8)
                      : (isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTrendIndicator() {
    final isPositive = widget.trend! >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color:
            widget.showGradient
                ? Colors.white.withOpacity(0.2)
                : (isPositive ? AppColors.success : AppColors.danger)
                    .withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            size: 12,
            color:
                widget.showGradient
                    ? Colors.white
                    : (isPositive ? AppColors.success : AppColors.danger),
          ),
          const SizedBox(width: 2),
          Text(
            '${widget.trend!.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color:
                  widget.showGradient
                      ? Colors.white
                      : (isPositive ? AppColors.success : AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
