// File: lib/services/websocket_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Necessário para WebSocket

import 'package:flutter/material.dart'; // Necessário para Colors
import 'package:get/get.dart'; // Necessário para Get.snackbar
import 'package:logger/logger.dart'; // Necessário para Logger

class WebSocketService {
  final Logger _logger;
  WebSocket? _socket;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  WebSocketService(this._logger); // Adicionei o construtor que faltava

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  Future<void> connect(String serverUrl) async {
    try {
      final wsUrl = serverUrl.replaceFirst('http', 'ws');
      _socket = await WebSocket.connect('$wsUrl/ws');

      _logger.i('✅ WebSocket conectado');

      _socket!.listen(
        (message) {
          final data = json.decode(message);
          _controller.add(data);
          _handleNotification(data);
        },
        onError: (error) => _logger.e('WebSocket error: $error'),
        onDone: () {
          _logger.w('WebSocket desconectado. Reconectando...');
          Future.delayed(Duration(seconds: 5), () => connect(serverUrl));
        },
      );
    } catch (e) {
      _logger.e('Erro ao conectar WebSocket: $e');
    }
  }

  void _handleNotification(Map<String, dynamic> data) {
    final type = data['type'];

    switch (type) {
      case 'device_offline':
        _showNotification(
          'Dispositivo Offline',
          '${data['device_name']} está offline há ${data['duration']}',
          NotificationType.warning,
        );
        break;

      case 'device_online':
        _showNotification(
          'Dispositivo Online',
          '${data['device_name']} voltou a ficar online',
          NotificationType.success,
        );
        break;

      case 'maintenance_required':
        _showNotification(
          'Manutenção Necessária',
          '${data['device_name']}: ${data['reason']}',
          NotificationType.error,
        );
        break;
    }
  }

  void _showNotification(String title, String message, NotificationType type) {
    // Integra com sistema de notificações do Flutter
    Get.snackbar(
      title,
      message,
      backgroundColor: type == NotificationType.error
          ? Colors.red
          : type == NotificationType.warning
              ? Colors.orange
              : Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 5),
      snackPosition: SnackPosition.TOP,
    );
  }

  // Adicionei um método para fechar a conexão
  void dispose() {
    _socket?.close();
    _controller.close();
  }
}

enum NotificationType { success, warning, error }