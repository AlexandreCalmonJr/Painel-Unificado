import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/presentation/bloc/theme/theme_cubit.dart';
import 'package:painel_windowns/presentation/bloc/theme/theme_state.dart';

class BaseCard extends StatelessWidget {
  const BaseCard({
    required this.title,
    required this.child,
    super.key,
    this.actions,
    this.expandChild = false,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool expandChild;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.effectiveDarkMode;

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
      },
    );
  }
}
