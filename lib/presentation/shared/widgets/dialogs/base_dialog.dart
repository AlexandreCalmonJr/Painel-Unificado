// File: lib/widgets/dialogs/base_dialog.dart
import 'package:flutter/material.dart';

/// Classe utilitária para diálogos reutilizáveis
class BaseDialog {
  /// Diálogo de confirmação
  static Future<bool> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? Colors.red : null,
              foregroundColor: isDestructive ? Colors.white : null,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Diálogo de input de texto
  static Future<String?> input({
    required BuildContext context,
    required String title,
    required String label,
    String? hint,
    String? initialValue,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    int? maxLines,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
            validator: validator,
            keyboardType: keyboardType,
            obscureText: obscureText,
            maxLines: obscureText ? 1 : maxLines,
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(context).pop(controller.text);
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );

    controller.dispose();
    return result;
  }

  /// Diálogo de loading
  static void loading(BuildContext context, {String? message}) {
    // ignore: inference_failure_on_function_invocation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(
                child: Text(message ?? 'Carregando...'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Fecha o diálogo de loading
  static void closeLoading(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Diálogo de formulário genérico
  static Future<Map<String, dynamic>?> form({
    required BuildContext context,
    required String title,
    required List<FormFieldConfig> fields,
    String confirmText = 'Salvar',
    String cancelText = 'Cancelar',
  }) async {
    final formKey = GlobalKey<FormState>();
    final controllers = <String, TextEditingController>{};

    // Cria controllers para cada campo
    for (final field in fields) {
      controllers[field.key] = TextEditingController(text: field.initialValue);
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: fields.map((field) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: controllers[field.key],
                    decoration: InputDecoration(
                      labelText: field.label,
                      hintText: field.hint,
                      border: const OutlineInputBorder(),
                    ),
                    validator: field.validator,
                    keyboardType: field.keyboardType,
                    obscureText: field.obscureText,
                    maxLines: field.obscureText ? 1 : field.maxLines,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final data = <String, dynamic>{};
                for (final field in fields) {
                  data[field.key] = controllers[field.key]!.text;
                }
                Navigator.of(context).pop(data);
              }
            },
            child: Text(confirmText),
          ),
        ],
      ),
    );

    // Dispose controllers
    for (final controller in controllers.values) {
      controller.dispose();
    }

    return result;
  }

  /// Diálogo de informação
  static Future<void> info({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
  }) async {
    // ignore: inference_failure_on_function_invocation
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}

/// Configuração de campo de formulário
class FormFieldConfig {

  FormFieldConfig({
    required this.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines,
  });
  final String key;
  final String label;
  final String? hint;
  final String? initialValue;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
}
