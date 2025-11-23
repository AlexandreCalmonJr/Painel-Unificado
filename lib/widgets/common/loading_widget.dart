// File: lib/widgets/common/loading_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:painel_windowns/controllers/theme_controller.dart';
import 'package:painel_windowns/utils/app_constants.dart';

/// Widget de loading moderno com animações
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const LoadingWidget({super.key, this.message, this.size = 50, this.color});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeController = ThemeController.to;
      final palette = themeController.currentPalette;
      final loadingColor = color ?? palette['primary']!;

      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: TextStyle(
                  color:
                      themeController.isDarkMode
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

/// Loading overlay que cobre toda a tela
class LoadingOverlay {
  static void show({String? message}) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Material(
          color: Colors.black54,
          child: LoadingWidget(message: message),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void hide() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}

/// Shimmer loading effect para skeleton screens
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return Obx(() {
      final themeController = ThemeController.to;
      final isDark = themeController.isDarkMode;

      final baseColor =
          widget.baseColor ??
          (isDark ? AppColors.surface : AppColors.surfaceLightVariant);
      final highlightColor =
          widget.highlightColor ??
          (isDark ? AppColors.surfaceLight : AppColors.surfaceLightMode);

      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [baseColor, highlightColor, baseColor],
                stops: [
                  _controller.value - 0.3,
                  _controller.value,
                  _controller.value + 0.3,
                ],
              ).createShader(bounds);
            },
            child: widget.child,
          );
        },
      );
    });
  }
}

/// Skeleton box para loading states
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonBox({super.key, this.width, this.height, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeController = ThemeController.to;
      final isDark = themeController.isDarkMode;

      return Container(
        width: width,
        height: height ?? 16,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : AppColors.surfaceLightVariant,
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        ),
      );
    });
  }
}
