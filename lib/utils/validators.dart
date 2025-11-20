// File: lib/utils/validators.dart
/// Validadores reutilizáveis para formulários

class Validators {
  /// Valida nome de usuário
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome de usuário é obrigatório';
    }
    if (value.length < 3) {
      return 'Nome de usuário deve ter pelo menos 3 caracteres';
    }
    if (value.length > 50) {
      return 'Nome de usuário deve ter no máximo 50 caracteres';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Nome de usuário deve conter apenas letras, números e _';
    }
    return null;
  }

  /// Valida senha
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 8) {
      return 'Senha deve ter pelo menos 8 caracteres';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Senha deve conter pelo menos uma letra maiúscula';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Senha deve conter pelo menos uma letra minúscula';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Senha deve conter pelo menos um número';
    }
    return null;
  }

  /// Valida endereço IP
  static String? validateIP(String? value) {
    if (value == null || value.isEmpty) {
      return 'IP é obrigatório';
    }
    final ipRegex = RegExp(
      r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );
    if (!ipRegex.hasMatch(value)) {
      return 'IP inválido (ex: 192.168.0.1)';
    }
    return null;
  }

  /// Valida porta
  static String? validatePort(String? value) {
    if (value == null || value.isEmpty) {
      return 'Porta é obrigatória';
    }
    final port = int.tryParse(value);
    if (port == null) {
      return 'Porta deve ser um número';
    }
    if (port < 1 || port > 65535) {
      return 'Porta deve estar entre 1 e 65535';
    }
    return null;
  }

  /// Valida campo obrigatório
  static String? validateRequired(String? value, [String fieldName = 'Campo']) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }
    return null;
  }

  /// Valida email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
  }

  /// Valida número de série
  static String? validateSerialNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Número de série é obrigatório';
    }
    if (value.length < 5) {
      return 'Número de série inválido';
    }
    return null;
  }

  /// Valida MAC Address
  static String? validateMacAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'MAC Address é obrigatório';
    }
    final macRegex = RegExp(
      r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$',
    );
    if (!macRegex.hasMatch(value)) {
      return 'MAC Address inválido (ex: AA:BB:CC:DD:EE:FF)';
    }
    return null;
  }

  /// Valida URL
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL é obrigatória';
    }
    try {
      final uri = Uri.parse(value);
      if (!uri.hasScheme || !uri.hasAuthority) {
        return 'URL inválida';
      }
      return null;
    } catch (e) {
      return 'URL inválida';
    }
  }

  /// Valida número positivo
  static String? validatePositiveNumber(String? value, [String fieldName = 'Valor']) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }
    final number = num.tryParse(value);
    if (number == null) {
      return '$fieldName deve ser um número';
    }
    if (number <= 0) {
      return '$fieldName deve ser maior que zero';
    }
    return null;
  }
}
