import 'package:flutter/material.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';

class CommandAction<T> {

  CommandAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isVisible,
    this.requiresConfirmation = false,
    this.confirmTitle,
    this.confirmMessage,
    this.isDestructive = false,
    this.color,
  });
  final String label;
  final IconData icon;
  // ignore: inference_failure_on_function_return_type
  final Function(BuildContext context, T item) onTap;
  final bool Function(T item)? isVisible;
  final bool requiresConfirmation;
  final String? confirmTitle;
  final String? confirmMessage;
  final bool isDestructive;
  final Color? color;
}

class BaseCommandMenu<T> extends StatelessWidget {
  const BaseCommandMenu({
    required this.item, required this.actions, super.key,
    this.icon,
    this.tooltip,
  });

  final T item;
  final List<CommandAction<T>> actions;
  final IconData? icon;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final visibleActions =
        actions
            .where((action) => action.isVisible?.call(item) ?? true)
            .toList();

    if (visibleActions.isEmpty) return const SizedBox.shrink();

    return PopupMenuButton<CommandAction<T>>(
      icon: Icon(icon ?? Icons.more_vert),
      tooltip: tooltip ?? 'Ações',
      onSelected: (action) async {
        if (action.requiresConfirmation) {
          final confirmed = await _showConfirmDialog(
            context,
            action.confirmTitle ?? 'Confirmar',
            action.confirmMessage ?? 'Tem certeza?',
            isDestructive: action.isDestructive,
          );
          if (!confirmed) return;
        }

        if (context.mounted) {
          action.onTap(context, item);
        }
      },
      itemBuilder:
          (context) =>
              visibleActions.map((action) {
                final color =
                    action.color ??
                    (action.isDestructive ? AppColors.danger : null);

                return PopupMenuItem<CommandAction<T>>(
                  value: action,
                  child: Row(
                    children: [
                      Icon(action.icon, size: 20, color: color),
                      const SizedBox(width: 12),
                      Text(
                        action.label,
                        style: TextStyle(
                          color: color,
                          fontWeight:
                              action.isDestructive ? FontWeight.w600 : null,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
    );
  }

  Future<bool> _showConfirmDialog(
    BuildContext context,
    String title,
    String message, {
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDestructive ? AppColors.danger : null,
                  foregroundColor: isDestructive ? Colors.white : null,
                ),
                child: const Text('Confirmar'),
              ),
            ],
          ),
    );
    return result ?? false;
  }
}
