import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/presentation/features/auth/bloc/theme_controller.dart';

class BaseCard extends StatelessWidget {
  const BaseCard({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.expandChild = false,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool expandChild;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeController = ThemeController.to;
      final isDark = themeController.isDarkMode;

      return Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : AppColors.surfaceLightMode,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.h3.copyWith(
                        color:
                            isDark
                                ? AppColors.textPrimary
                                : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                  if (actions != null) ...[
                    const SizedBox(width: 16),
                    ...actions!,
                  ],
                ],
              ),
            ),
            const Divider(height: 1),
            // Body
            if (expandChild) Expanded(child: child) else child,
          ],
        ),
      );
    });
  }
}
