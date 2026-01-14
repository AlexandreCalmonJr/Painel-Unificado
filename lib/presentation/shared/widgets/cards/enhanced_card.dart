// File: lib/presentation/shared/widgets/cards/enhanced_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/core/constants/layout_constants.dart';
import 'package:painel_windowns/presentation/bloc/theme/theme_cubit.dart';
import 'package:painel_windowns/presentation/bloc/theme/theme_state.dart';

/// Card aprimorado com variantes, estados e animações
class EnhancedCard extends StatefulWidget {
  const EnhancedCard({
    required this.child,
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.footer,
    this.variant = CardVariant.elevated,
    this.padding,
    this.margin,
    this.onTap,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? footer;
  final CardVariant variant;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;

  @override
  State<EnhancedCard> createState() => _EnhancedCardState();
}

class _EnhancedCardState extends State<EnhancedCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.effectiveDarkMode;

        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: LayoutConstants.animationDurationShort,
            margin: widget.margin ?? EdgeInsets.all(LayoutConstants.cardMargin),
            decoration: _getDecoration(isDark),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(LayoutConstants.cardRadius),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.title != null) _buildHeader(isDark),
                    if (widget.hasError && widget.errorMessage != null)
                      _buildErrorBanner(),
                    _buildBody(isDark),
                    if (widget.footer != null) _buildFooter(isDark),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _getDecoration(bool isDark) {
    final baseColor = isDark ? AppColors.surface : AppColors.surfaceLightMode;
    final borderColor = isDark ? AppColors.border : AppColors.borderLight;

    switch (widget.variant) {
      case CardVariant.elevated:
        return BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(LayoutConstants.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius:
                  _isHovered
                      ? LayoutConstants.cardElevationHover
                      : LayoutConstants.cardElevation,
              offset: Offset(0, _isHovered ? 6 : 4),
            ),
          ],
        );

      case CardVariant.outlined:
        return BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(LayoutConstants.cardRadius),
          border: Border.all(
            color: _isHovered ? AppColors.primary : borderColor,
            width: _isHovered ? 2 : 1,
          ),
        );

      case CardVariant.filled:
        return BoxDecoration(
          color:
              isDark ? AppColors.surfaceLight : AppColors.surfaceLightVariant,
          borderRadius: BorderRadius.circular(LayoutConstants.cardRadius),
        );

      case CardVariant.glass:
        return BoxDecoration(
          color: baseColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(LayoutConstants.cardRadius),
          border: Border.all(color: borderColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        );
    }
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.all(LayoutConstants.cardPadding),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.border : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        children: [
          if (widget.leading != null) ...[
            widget.leading!,
            SizedBox(width: LayoutConstants.spaceM),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title!,
                  style: AppTextStyles.h4.copyWith(
                    color:
                        isDark
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryLight,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  SizedBox(height: LayoutConstants.spaceXS),
                  Text(
                    widget.subtitle!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.actions != null) ...[
            SizedBox(width: LayoutConstants.spaceM),
            Row(mainAxisSize: MainAxisSize.min, children: widget.actions!),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: EdgeInsets.all(LayoutConstants.spaceM),
      color: AppColors.danger.withOpacity(0.1),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
          SizedBox(width: LayoutConstants.spaceM),
          Expanded(
            child: Text(
              widget.errorMessage!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    Widget body = Padding(
      padding: widget.padding ?? EdgeInsets.all(LayoutConstants.cardPadding),
      child: widget.child,
    );

    if (widget.isLoading) {
      body = Stack(
        children: [
          Opacity(opacity: 0.5, child: body),
          const Positioned.fill(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    return body;
  }

  Widget _buildFooter(bool isDark) {
    return Container(
      padding: EdgeInsets.all(LayoutConstants.cardPadding),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.border : AppColors.borderLight,
          ),
        ),
      ),
      child: widget.footer,
    );
  }
}

/// Variantes de estilo do card
enum CardVariant {
  /// Card com elevação (sombra)
  elevated,

  /// Card com borda
  outlined,

  /// Card com fundo preenchido
  filled,

  /// Card com efeito glassmorphism
  glass,
}
