// File: lib/presentation/shared/widgets/cards/enhanced_stat_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/core/constants/layout_constants.dart';
import 'package:painel_windowns/presentation/bloc/theme/theme_cubit.dart';
import 'package:painel_windowns/presentation/bloc/theme/theme_state.dart';

/// Card de estatística aprimorado com tendências e animações
class EnhancedStatCard extends StatefulWidget {
  const EnhancedStatCard({
    required this.title,
    required this.value,
    required this.icon,
    super.key,
    this.subtitle,
    this.trend,
    this.trendValue,
    this.color,
    this.onTap,
    this.isLoading = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;
  final TrendDirection? trend;
  final String? trendValue;
  final Color? color;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  State<EnhancedStatCard> createState() => _EnhancedStatCardState();
}

class _EnhancedStatCardState extends State<EnhancedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: LayoutConstants.animationDurationShort,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
        final cardColor = widget.color ?? AppColors.primary;

        return MouseRegion(
          onEnter: (_) {
            setState(() => _isHovered = true);
            _controller.forward();
          },
          onExit: (_) {
            setState(() => _isHovered = false);
            _controller.reverse();
          },
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface : AppColors.surfaceLightMode,
                borderRadius: BorderRadius.circular(LayoutConstants.cardRadius),
                border: Border.all(
                  color:
                      _isHovered
                          ? cardColor.withOpacity(0.5)
                          : (isDark ? AppColors.border : AppColors.borderLight),
                  width: _isHovered ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: _isHovered ? 12 : 8,
                    offset: Offset(0, _isHovered ? 6 : 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(
                    LayoutConstants.cardRadius,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(LayoutConstants.cardPadding),
                    child:
                        widget.isLoading
                            ? _buildLoadingState()
                            : _buildContent(isDark, cardColor),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 100,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildContent(bool isDark, Color cardColor) {
    return Row(
      children: [
        // Icon container
        Container(
          padding: EdgeInsets.all(LayoutConstants.spaceM),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cardColor, cardColor.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(
              LayoutConstants.cardRadiusSmall,
            ),
          ),
          child: Icon(
            widget.icon,
            color: Colors.white,
            size: LayoutConstants.iconSizeL,
          ),
        ),

        SizedBox(width: LayoutConstants.spaceM),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Value
              Row(
                children: [
                  Flexible(
                    child: Text(
                      widget.value,
                      style: AppTextStyles.h2.copyWith(
                        color:
                            isDark
                                ? AppColors.textPrimary
                                : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.trend != null) ...[
                    SizedBox(width: LayoutConstants.spaceS),
                    _buildTrendIndicator(),
                  ],
                ],
              ),

              SizedBox(height: LayoutConstants.spaceXS),

              // Title
              Text(
                widget.title,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),

              // Subtitle or trend value
              if (widget.subtitle != null || widget.trendValue != null) ...[
                SizedBox(height: LayoutConstants.spaceXS),
                Text(
                  widget.subtitle ?? widget.trendValue!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color:
                        widget.trendValue != null
                            ? _getTrendColor()
                            : AppColors.textSecondary,
                    fontWeight:
                        widget.trendValue != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrendIndicator() {
    IconData icon;
    Color color;

    switch (widget.trend!) {
      case TrendDirection.up:
        icon = Icons.trending_up;
        color = AppColors.success;
        break;
      case TrendDirection.down:
        icon = Icons.trending_down;
        color = AppColors.danger;
        break;
      case TrendDirection.neutral:
        icon = Icons.trending_flat;
        color = AppColors.textSecondary;
        break;
    }

    return Icon(icon, color: color, size: LayoutConstants.iconSizeS);
  }

  Color _getTrendColor() {
    switch (widget.trend) {
      case TrendDirection.up:
        return AppColors.success;
      case TrendDirection.down:
        return AppColors.danger;
      case TrendDirection.neutral:
      case null:
        return AppColors.textSecondary;
    }
  }
}

/// Direção da tendência
enum TrendDirection {
  /// Tendência positiva (crescimento)
  up,

  /// Tendência negativa (queda)
  down,

  /// Tendência neutra (estável)
  neutral,
}

/// Grid responsivo de stat cards
class StatCardGrid extends StatelessWidget {
  const StatCardGrid({
    required this.cards,
    super.key,
    this.crossAxisCount,
    this.childAspectRatio = 1.5,
  });

  final List<EnhancedStatCard> cards;
  final int? crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = crossAxisCount ?? _getColumnCount(width);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: LayoutConstants.spaceM,
        mainAxisSpacing: LayoutConstants.spaceM,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => cards[index],
    );
  }

  int _getColumnCount(double width) {
    if (LayoutConstants.isMobile(width)) return 1;
    if (LayoutConstants.isTablet(width)) return 2;
    return 3;
  }
}
