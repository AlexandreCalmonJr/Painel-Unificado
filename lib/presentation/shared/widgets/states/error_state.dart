// File: lib/presentation/shared/widgets/states/error_state.dart
import 'package:flutter/material.dart';
import 'package:painel_windowns/core/constants/app_constants.dart';
import 'package:painel_windowns/core/constants/layout_constants.dart';

/// Widget para exibir estado de erro com opção de retry
class ErrorState extends StatelessWidget {
  const ErrorState({
    required this.error,
    super.key,
    this.onRetry,
    this.title = 'Ops! Algo deu errado',
    this.showDetails = false,
  });

  final String error;
  final VoidCallback? onRetry;
  final String title;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(LayoutConstants.spaceXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 80, color: AppColors.danger),
            SizedBox(height: LayoutConstants.spaceL),
            Text(
              title,
              style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            if (showDetails) ...[
              SizedBox(height: LayoutConstants.spaceM),
              Container(
                padding: EdgeInsets.all(LayoutConstants.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    LayoutConstants.cardRadiusSmall,
                  ),
                  border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                ),
                child: Text(
                  error,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.danger,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            if (onRetry != null) ...[
              SizedBox(height: LayoutConstants.spaceL),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('Tentar Novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: LayoutConstants.spaceL,
                    vertical: LayoutConstants.spaceM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      LayoutConstants.cardRadiusSmall,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget para exibir erro inline (menor, para usar dentro de cards)
class InlineError extends StatelessWidget {
  const InlineError({required this.message, super.key, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(LayoutConstants.spaceM),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(LayoutConstants.cardRadiusSmall),
        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
          SizedBox(width: LayoutConstants.spaceM),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger),
            ),
          ),
          if (onRetry != null) ...[
            SizedBox(width: LayoutConstants.spaceM),
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 20),
              color: AppColors.danger,
              tooltip: 'Tentar novamente',
            ),
          ],
        ],
      ),
    );
  }
}

/// Variantes pré-configuradas de ErrorState
class ErrorStateVariants {
  /// Erro de rede/conexão
  static Widget networkError({VoidCallback? onRetry}) {
    return ErrorState(
      title: 'Erro de Conexão',
      error: 'Não foi possível conectar ao servidor',
      onRetry: onRetry,
    );
  }

  /// Erro de timeout
  static Widget timeoutError({VoidCallback? onRetry}) {
    return ErrorState(
      title: 'Tempo Esgotado',
      error: 'A requisição demorou muito para responder',
      onRetry: onRetry,
    );
  }

  /// Erro de autenticação
  static Widget authError({VoidCallback? onRetry}) {
    return ErrorState(
      title: 'Erro de Autenticação',
      error: 'Sua sessão expirou. Faça login novamente.',
      onRetry: onRetry,
    );
  }

  /// Erro genérico
  static Widget generic({
    required String error,
    VoidCallback? onRetry,
    bool showDetails = false,
  }) {
    return ErrorState(error: error, onRetry: onRetry, showDetails: showDetails);
  }
}
