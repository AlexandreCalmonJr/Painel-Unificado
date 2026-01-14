// File: lib/presentation/shared/widgets/states/empty_state.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/core/constants/layout_constants.dart';

/// Widget para exibir estado vazio com ícone, mensagem e ação opcional
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    super.key,
    this.subtitle,
    this.action,
    this.iconSize = 80.0,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  final double iconSize;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(LayoutConstants.spaceXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: iconColor ?? AppColors.textSecondary,
            ),
            SizedBox(height: LayoutConstants.spaceL),
            Text(
              title,
              style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: LayoutConstants.spaceS),
              Text(
                subtitle!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              SizedBox(height: LayoutConstants.spaceL),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Variantes pré-configuradas de EmptyState
class EmptyStateVariants {
  /// Estado vazio para quando não há dados
  static Widget noData({
    String title = 'Nenhum dado encontrado',
    String? subtitle,
    Widget? action,
  }) {
    return EmptyState(
      icon: Icons.inbox_outlined,
      title: title,
      subtitle: subtitle ?? 'Não há informações para exibir no momento',
      action: action,
    );
  }

  /// Estado vazio para busca sem resultados
  static Widget noSearchResults({required String searchTerm, Widget? action}) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'Nenhum resultado encontrado',
      subtitle: 'Não encontramos resultados para "$searchTerm"',
      action: action,
    );
  }

  /// Estado vazio para lista vazia
  static Widget emptyList({required String itemName, Widget? action}) {
    return EmptyState(
      icon: Icons.list_alt,
      title: 'Lista vazia',
      subtitle: 'Nenhum $itemName cadastrado ainda',
      action: action,
    );
  }

  /// Estado vazio para sem permissão
  static Widget noPermission({
    String title = 'Sem permissão',
    String? subtitle,
  }) {
    return EmptyState(
      icon: Icons.lock_outline,
      title: title,
      subtitle: subtitle ?? 'Você não tem permissão para acessar este recurso',
      iconColor: AppColors.warning,
    );
  }

  /// Estado vazio para offline
  static Widget offline({Widget? action}) {
    return EmptyState(
      icon: Icons.wifi_off,
      title: 'Sem conexão',
      subtitle: 'Verifique sua conexão com a internet',
      action: action,
      iconColor: AppColors.danger,
    );
  }
}
