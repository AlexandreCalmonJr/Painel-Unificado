// File: lib/widgets/error_handler.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/core/error/exceptions.dart';

/// Widget para tratamento global de erros
class ErrorHandler {
  /// Exibe mensagem de erro como SnackBar
  static void showError(BuildContext context, dynamic error) {
    String message;
    Color backgroundColor;

    if (error is AppException) {
      message = error.message;
      backgroundColor = _getColorForException(error);
    } else {
      message = error.toString();
      backgroundColor = Colors.red;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getIconForError(error),
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Exibe mensagem de sucesso
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Exibe mensagem de aviso
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Exibe mensagem de informação
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Retorna cor baseada no tipo de exceção
  static Color _getColorForException(AppException error) {
    if (error is NetworkException) return Colors.orange;
    if (error is AuthException) return Colors.red.shade700;
    if (error is ValidationException) return Colors.amber.shade700;
    if (error is ServerException) return Colors.red;
    if (error is ForbiddenException) return Colors.deepOrange;
    if (error is NotFoundException) return Colors.grey.shade700;
    return Colors.red;
  }

  /// Retorna ícone baseado no tipo de erro
  static IconData _getIconForError(dynamic error) {
    if (error is NetworkException) return Icons.wifi_off;
    if (error is AuthException) return Icons.lock;
    if (error is ValidationException) return Icons.warning;
    if (error is ServerException) return Icons.error;
    if (error is ForbiddenException) return Icons.block;
    if (error is NotFoundException) return Icons.search_off;
    return Icons.error_outline;
  }
}

/// Widget de diálogo de confirmação
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirmar',
    this.cancelText = 'Cancelar',
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }

  /// Exibe o diálogo de confirmação
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: () {},
      ),
    );
    return result ?? false;
  }
}
