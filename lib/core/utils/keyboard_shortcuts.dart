import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para LogicalKeySet e LogicalKeyboardKey

class KeyboardShortcuts extends StatelessWidget {
  final Widget child;
  final VoidCallback? onRefresh;
  final VoidCallback? onSearch;
  final VoidCallback? onExport;

  const KeyboardShortcuts({
    super.key, // ✅ Adicionado Key
    required this.child,
    this.onRefresh,
    this.onSearch,
    this.onExport,
  }); // ✅ Adicionado super(key: key)

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        // Ctrl + R: Atualizar
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyR): () {
          onRefresh?.call();
        },

        // Ctrl + F: Buscar
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF): () {
          onSearch?.call();
        },

        // Ctrl + E: Exportar
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyE): () {
          onExport?.call();
        },

        // F5: Atualizar (alternativo)
        LogicalKeySet(LogicalKeyboardKey.f5): () {
          onRefresh?.call();
        },
      },
      child: Focus(
        autofocus: true,
        child: child,
      ),
    );
  }
}