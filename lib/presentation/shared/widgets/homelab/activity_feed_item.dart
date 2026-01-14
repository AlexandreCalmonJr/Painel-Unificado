// File: lib/presentation/shared/widgets/homelab/activity_feed_item.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/services/homelab_service.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Activity feed item widget for timeline display
class ActivityFeedItem extends StatelessWidget {
  const ActivityFeedItem({required this.event, super.key, this.isLast = false});

  final ActivityEvent event;
  final bool isLast;

  Color _getEventColor() {
    switch (event.type) {
      case ActivityType.deviceOnline:
        return AppColors.success;
      case ActivityType.deviceOffline:
        return AppColors.textSecondary;
      case ActivityType.alert:
        return AppColors.warning;
      case ActivityType.info:
        return AppColors.primary;
    }
  }

  IconData _getEventIcon() {
    switch (event.type) {
      case ActivityType.deviceOnline:
        return Icons.check_circle;
      case ActivityType.deviceOffline:
        return Icons.cancel;
      case ActivityType.alert:
        return Icons.warning_amber;
      case ActivityType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final eventColor = _getEventColor();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: eventColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: eventColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(_getEventIcon(), size: 16, color: eventColor),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: (isDark ? AppColors.border : AppColors.borderLight)
                    .withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 12),
        // Event content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.message,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color:
                        isDark
                            ? AppColors.textPrimary
                            : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeago.format(event.timestamp, locale: 'pt_BR'),
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        isDark
                            ? AppColors.textSecondary
                            : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
