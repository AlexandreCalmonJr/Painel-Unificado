// File: lib/presentation/shared/widgets/homelab/system_health_widget.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/services/homelab_service.dart';

/// System health monitoring widget with circular gauges
class SystemHealthWidget extends StatelessWidget {
  const SystemHealthWidget({required this.health, super.key});

  final SystemHealth health;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : AppColors.surfaceLightMode,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? AppColors.border : AppColors.borderLight)
              .withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monitor_heart, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Saúde do Sistema',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      isDark
                          ? AppColors.textPrimary
                          : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MetricGauge(
                label: 'CPU',
                value: health.cpuUsage,
                color: _getHealthColor(health.cpuUsage),
              ),
              _MetricGauge(
                label: 'Memória',
                value: health.memoryUsage,
                color: _getHealthColor(health.memoryUsage),
              ),
              _MetricGauge(
                label: 'Rede',
                value: health.networkUsage,
                color: _getHealthColor(health.networkUsage),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (isDark
                      ? AppColors.background
                      : AppColors.surfaceLightVariant)
                  .withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 20,
                  color:
                      isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                ),
                const SizedBox(width: 12),
                Text(
                  'Uptime: ${_formatUptime(health.uptime)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color:
                        isDark
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getHealthColor(double value) {
    if (value < 50) return AppColors.success;
    if (value < 80) return AppColors.warning;
    return AppColors.danger;
  }

  String _formatUptime(Duration uptime) {
    final days = uptime.inDays;
    final hours = uptime.inHours % 24;
    final minutes = uptime.inMinutes % 60;

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

class _MetricGauge extends StatelessWidget {
  const _MetricGauge({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 8,
                  backgroundColor: (isDark
                          ? AppColors.background
                          : AppColors.surfaceLightVariant)
                      .withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation(
                    (isDark
                            ? AppColors.background
                            : AppColors.surfaceLightVariant)
                        .withOpacity(0.3),
                  ),
                ),
              ),
              // Progress circle
              SizedBox(
                width: 80,
                height: 80,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutCubic,
                  tween: Tween(begin: 0, end: value / 100),
                  builder: (context, value, child) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 8,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation(color),
                      strokeCap: StrokeCap.round,
                    );
                  },
                ),
              ),
              // Value text
              Text(
                '${value.toInt()}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      isDark
                          ? AppColors.textPrimary
                          : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color:
                isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
