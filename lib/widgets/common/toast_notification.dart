// File: lib/widgets/common/toast_notification.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:painel_windowns/controllers/theme_controller.dart';
import 'package:painel_windowns/utils/app_constants.dart';

enum ToastType { success, error, warning, info }

class ToastNotification {
  static void show({
    required String message,
    String? title,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    final themeController = ThemeController.to;
    final isDark = themeController.isDarkMode;

    Get.snackbar(
      title ?? _getDefaultTitle(type),
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: _getBackgroundColor(type, isDark),
      colorText: Colors.white,
      icon: Icon(_getIcon(type), color: Colors.white),
      duration: duration,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInCirc,
      animationDuration: const Duration(milliseconds: 400),
      onTap: onTap != null ? (_) => onTap() : null,
      boxShadows: [
        BoxShadow(
          color: _getBackgroundColor(type, isDark).withOpacity(0.4),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: 2,
        ),
      ],
    );
  }

  static String _getDefaultTitle(ToastType type) {
    switch (type) {
      case ToastType.success:
        return 'Sucesso';
      case ToastType.error:
        return 'Erro';
      case ToastType.warning:
        return 'Atenção';
      case ToastType.info:
        return 'Informação';
    }
  }

  static IconData _getIcon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.warning:
        return Icons.warning;
      case ToastType.info:
        return Icons.info;
    }
  }

  static Color _getBackgroundColor(ToastType type, bool isDark) {
    switch (type) {
      case ToastType.success:
        return AppColors.success;
      case ToastType.error:
        return AppColors.danger;
      case ToastType.warning:
        return AppColors.warning;
      case ToastType.info:
        return AppColors.info;
    }
  }

  // Atalhos convenientes
  static void success(String message, {String? title}) {
    show(message: message, title: title, type: ToastType.success);
  }

  static void error(String message, {String? title}) {
    show(message: message, title: title, type: ToastType.error);
  }

  static void warning(String message, {String? title}) {
    show(message: message, title: title, type: ToastType.warning);
  }

  static void info(String message, {String? title}) {
    show(message: message, title: title, type: ToastType.info);
  }
}
