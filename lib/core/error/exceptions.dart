/// Base class for all exceptions in the application
class AppException implements Exception {
  final String message;
  final int? code;

  const AppException({required this.message, this.code});

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception for server-related errors
class ServerException extends AppException {
  const ServerException({required super.message, super.code});

  @override
  String toString() =>
      'ServerException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception for cache-related errors
class CacheException extends AppException {
  const CacheException({required super.message, super.code});

  @override
  String toString() =>
      'CacheException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception for network-related errors
class NetworkException extends AppException {
  const NetworkException({required super.message, super.code});

  @override
  String toString() =>
      'NetworkException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception for authentication-related errors
class AuthException extends AppException {
  const AuthException({required super.message, super.code});

  @override
  String toString() =>
      'AuthException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception for validation errors
class ValidationException extends AppException {
  const ValidationException({required super.message, super.code});

  @override
  String toString() =>
      'ValidationException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception for not found errors
class NotFoundException extends AppException {
  const NotFoundException({required super.message, super.code});

  @override
  String toString() =>
      'NotFoundException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception for permission errors
class PermissionException extends AppException {
  const PermissionException({required super.message, super.code});

  @override
  String toString() =>
      'PermissionException: $message${code != null ? ' (code: $code)' : ''}';
}
