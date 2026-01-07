import 'package:flutter/material.dart';

/// Utilitário para formatar status de periféricos e dispositivos
class StatusFormatter {
  /// Formata status de periféricos (Zebra, Bematech, etc.)
  ///
  /// Expande abreviações comuns:
  /// - 'N' → 'Não detectado'
  /// - 'A' → 'Ativo'
  /// - 'E' → 'Erro'
  /// - 'D' → 'Desconectado'
  static String formatPeripheralStatus(String status) {
    if (status.isEmpty) return 'N/A';

    // Se já é um valor completo (mais de 2 caracteres), retorna como está
    if (status.length > 2) return status;

    // Expande abreviações
    switch (status.toUpperCase()) {
      case 'N':
        return 'Não detectado';
      case 'A':
        return 'Ativo';
      case 'E':
        return 'Erro';
      case 'D':
        return 'Desconectado';
      case 'OK':
        return 'Funcionando';
      default:
        return status;
    }
  }

  /// Retorna cor baseada no status do periférico
  static Color getPeripheralStatusColor(String status) {
    final formatted = formatPeripheralStatus(status);

    switch (formatted) {
      case 'Ativo':
      case 'Funcionando':
        return Colors.green;
      case 'Não detectado':
      case 'Desconectado':
        return Colors.grey;
      case 'Erro':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
