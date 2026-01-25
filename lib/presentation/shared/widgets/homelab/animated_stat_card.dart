// File: lib/presentation/shared/widgets/homelab/animated_stat_card.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';

/// Animated statistics card with counter animation
class AnimatedStatCard extends StatefulWidget {
  const AnimatedStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    super.key,
    this.subtitle,
    this.trend,
    this.onTap,
  });

  final String title;
  final int value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final double? trend; // Percentage change
  final VoidCallback? onTap;

  @override
  State<AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.value.toDouble(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedStatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: oldWidget.value.toDouble(),
        end: widget.value.toDouble(),
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -4.0 : 0.0),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surface : AppColors.surfaceLightMode,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    _isHovered
                        ? widget.color.withOpacity(0.5)
                        : (isDark ? AppColors.border : AppColors.borderLight)
                            .withOpacity(0.1),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      _isHovered
                          ? widget.color.withOpacity(0.2)
                          : Colors.black.withOpacity(0.05),
                  blurRadius: _isHovered ? 20 : 10,
                  offset: Offset(0, _isHovered ? 8 : 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(widget.icon, color: widget.color, size: 28),
                    ),
                    if (widget.trend != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (widget.trend! >= 0
                                  ? AppColors.success
                                  : AppColors.danger)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              widget.trend! >= 0
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              size: 14,
                              color:
                                  widget.trend! >= 0
                                      ? AppColors.success
                                      : AppColors.danger,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.trend!.abs().toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color:
                                    widget.trend! >= 0
                                        ? AppColors.success
                                        : AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Text(
                      _animation.value.toInt().toString(),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color:
                            isDark
                                ? AppColors.textPrimary
                                : AppColors.textPrimaryLight,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color:
                        isDark
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryLight,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isDark
                              ? AppColors.textSecondary.withOpacity(0.7)
                              : AppColors.textSecondaryLight.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
