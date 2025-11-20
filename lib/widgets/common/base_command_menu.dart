// File: lib/widgets/common/base_command_menu.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/utils/app_constants.dart';
import 'package:painel_windowns/widgets/dialogs/base_dialog.dart';

/// Configuração de ação de comando
class CommandAction<T> {
  final String label;
  final IconData icon;
  final Future<void> Function(BuildContext context, T item) onTap;
  final bool Function(T item)? isVisible;
  final bool requiresConfirmation;
  final String? confirmTitle;
  final String? confirmMessage;
  final bool isDestructive;
  final Color? color;

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
}

/// Widget de menu de comandos reutilizável
class BaseCommandMenu<T> extends StatelessWidget {
  final T item;
  final List<CommandAction<T>> actions;
  final bool showAsButtons;
  final IconData menuIcon;

  const BaseCommandMenu({
    super.key,
    required this.item,
    required this.actions,
    this.showAsButtons = false,
    this.menuIcon = Icons.more_vert,
  });

  @override
  Widget build(BuildContext context) {
    final visibleActions =
        actions.where((action) => action.isVisible?.call(item) ?? true).toList();

    if (visibleActions.isEmpty) {
      return const SizedBox.shrink();
    }

    if (showAsButtons) {
      return Wrap(
        spacing: AppConstants.spacingS,
        children: visibleActions.map((action) {
          return ElevatedButton.icon(
            onPressed: () => _handleAction(context, action),
            icon: Icon(action.icon, size: AppConstants.iconS),
            label: Text(action.label),
            style: ElevatedButton.styleFrom(
              backgroundColor: action.color,
              foregroundColor: action.isDestructive ? Colors.white : null,
            ),
          );
        }).toList(),
      );
    }

    return PopupMenuButton<CommandAction<T>>(
      icon: Icon(menuIcon),
      tooltip: 'Ações',
      onSelected: (action) => _handleAction(context, action),
      itemBuilder: (context) {
        return visibleActions.map((action) {
          return PopupMenuItem<CommandAction<T>>(
            value: action,
            child: Row(
              children: [
                Icon(
                  action.icon,
                  size: AppConstants.iconS,
                  color: action.color ?? (action.isDestructive ? AppColors.danger : null),
                ),
                const SizedBox(width: AppConstants.spacingS),
                Text(
                  action.label,
                  style: TextStyle(
                    color: action.isDestructive ? AppColors.danger : null,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    CommandAction<T> action,
  ) async {
    if (action.requiresConfirmation) {
      final confirmed = await BaseDialog.confirm(
        context: context,
        title: action.confirmTitle ?? 'Confirmar ação',
        message: action.confirmMessage ?? 'Deseja realmente executar esta ação?',
        isDestructive: action.isDestructive,
      );

      if (!confirmed) return;
    }

    try {
      BaseDialog.loading(context, message: 'Processando...');
      await action.onTap(context, item);
      if (context.mounted) {
        BaseDialog.closeLoading(context);
      }
    } catch (e) {
      if (context.mounted) {
        BaseDialog.closeLoading(context);
        await BaseDialog.info(
          context: context,
          title: 'Erro',
          message: e.toString(),
        );
      }
    }
  }
}
