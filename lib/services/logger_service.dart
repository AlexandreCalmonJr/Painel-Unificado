import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Centralized logging service to replace print() statements
/// Provides structured logging with different levels and optional persistence
class LoggerService {
  factory LoggerService() => _instance;
  LoggerService._internal();
  static final LoggerService _instance = LoggerService._internal();

  static LoggerService get instance => _instance;

  /// Minimum log level to display
  LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  /// Whether to log to console
  bool _logToConsole = true;

  /// Whether to persist logs to file (can be implemented later)
  bool _persistLogs = false;

  /// Configure the logger
  void configure({LogLevel? minLevel, bool? logToConsole, bool? persistLogs}) {
    if (minLevel != null) _minLevel = minLevel;
    if (logToConsole != null) _logToConsole = logToConsole;
    if (persistLogs != null) _persistLogs = persistLogs;
  }

  /// Log a debug message
  void debug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.debug,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log an info message
  void info(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.info,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log a warning message
  void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.warning,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log an error message
  void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Internal logging method
  void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Check if this level should be logged
    if (level.index < _minLevel.index) return;

    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase().padRight(7);
    final tagStr = tag != null ? '[$tag] ' : '';
    final formattedMessage = '$timestamp $levelStr $tagStr$message';

    // Log to console if enabled
    if (_logToConsole) {
      if (kDebugMode) {
        // Use developer.log for better debugging in Flutter DevTools
        developer.log(
          message,
          time: DateTime.now(),
          level: _getLevelValue(level),
          name: tag ?? 'App',
          error: error,
          stackTrace: stackTrace,
        );
      } else {
        // In release mode, use print (will be stripped in production builds)
        // ignore: avoid_print
        print(formattedMessage);
      }
    }

    // Log error details if present
    if (error != null && _logToConsole) {
      if (kDebugMode) {
        developer.log(
          'Error: $error',
          time: DateTime.now(),
          level: _getLevelValue(level),
          name: tag ?? 'App',
          error: error,
          stackTrace: stackTrace,
        );
      } else {
        // ignore: avoid_print
        print('Error: $error');
      }
    }

    // Log stack trace if present
    if (stackTrace != null && _logToConsole && level == LogLevel.error) {
      if (kDebugMode) {
        developer.log(
          'StackTrace: $stackTrace',
          time: DateTime.now(),
          level: _getLevelValue(level),
          name: tag ?? 'App',
        );
      } else {
        // ignore: avoid_print
        print('StackTrace: $stackTrace');
      }
    }

    // TODO: Implement file persistence if _persistLogs is true
    if (_persistLogs) {
      _persistLog(formattedMessage, error, stackTrace);
    }
  }

  /// Get numeric level value for developer.log
  int _getLevelValue(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }

  /// Persist log to file (placeholder for future implementation)
  void _persistLog(String message, Object? error, StackTrace? stackTrace) {
    // TODO: Implement file-based logging
    // This could write to a local file or send to a remote logging service
  }

  /// Clear all persisted logs
  Future<void> clearLogs() async {
    // TODO: Implement log clearing
  }

  /// Get all persisted logs
  Future<List<String>> getLogs() async {
    // TODO: Implement log retrieval
    return [];
  }
}

/// Log levels
enum LogLevel { debug, info, warning, error }

/// Convenience getters for quick access
LoggerService get logger => LoggerService.instance;
