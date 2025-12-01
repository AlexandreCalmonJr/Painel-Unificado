// File: lib/utils/exceptions.dart
/// Exceções customizadas para tratamento de erros consistente
library;


abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, [this.code, this.originalError]);

  @override
  String toString() => message;
}

/// Exceção para erros de rede e conectividade
class NetworkException extends AppException {
  NetworkException([String? message, dynamic originalError])
      : super(
          message ?? 'Erro de conexão com o servidor',
          'NETWORK_ERROR',
          originalError,
        );
}

/// Exceção para erros de autenticação
class AuthException extends AppException {
  AuthException([String? message, dynamic originalError])
      : super(
          message ?? 'Erro de autenticação',
          'AUTH_ERROR',
          originalError,
        );
}

/// Exceção para erros de validação de dados
class ValidationException extends AppException {
  ValidationException([String? message, dynamic originalError])
      : super(
          message ?? 'Dados inválidos',
          'VALIDATION_ERROR',
          originalError,
        );
}

/// Exceção para erros do servidor (HTTP 5xx)
class ServerException extends AppException {
  final int? statusCode;

  ServerException(
    String message, [
    this.statusCode,
    dynamic originalError,
  ]) : super(message, 'SERVER_ERROR', originalError);
}

/// Exceção para timeout de requisições
class TimeoutException extends NetworkException {
  TimeoutException([String? message, dynamic originalError])
      : super(
          message ?? 'Tempo de resposta esgotado',
          originalError,
        );
}

/// Exceção para recursos não encontrados (HTTP 404)
class NotFoundException extends AppException {
  NotFoundException([String? message, dynamic originalError])
      : super(
          message ?? 'Recurso não encontrado',
          'NOT_FOUND',
          originalError,
        );
}

/// Exceção para permissões insuficientes (HTTP 403)
class ForbiddenException extends AppException {
  ForbiddenException([String? message, dynamic originalError])
      : super(
          message ?? 'Acesso negado',
          'FORBIDDEN',
          originalError,
        );
}

/// Exceção para conflitos (HTTP 409)
class ConflictException extends AppException {
  ConflictException([String? message, dynamic originalError])
      : super(
          message ?? 'Conflito de dados',
          'CONFLICT',
          originalError,
        );
}
