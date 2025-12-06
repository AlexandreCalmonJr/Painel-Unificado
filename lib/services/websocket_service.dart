// File: lib/services/websocket_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class WebSocketService {
  final Logger _logger;
  WebSocket? _socket;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  bool _isDisposed = false;
  String? _serverUrl;

  WebSocketService(this._logger);

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  Future<void> connect(String serverUrl) async {
    _serverUrl = serverUrl;
    if (_socket != null && _socket!.readyState == WebSocket.open) return;

    try {
      final wsUrl = serverUrl.replaceFirst('http', 'ws');
      _logger.i('🔌 Conectando WebSocket em $wsUrl/ws...');

      // Conecta com timeout
      _socket = await WebSocket.connect(
        '$wsUrl/ws',
      ).timeout(Duration(seconds: 5));

      _logger.i('✅ WebSocket conectado!');

      // Envia registro inicial
      _sendRegister();

      // Inicia heartbeat
      _startHeartbeat();

      _socket!.listen(
        (message) {
          try {
            final data = json.decode(message);
            _controller.add(data);
            _handleNotification(data);
          } catch (e) {
            _logger.e('Erro ao processar mensagem WS: $e');
          }
        },
        onError: (error) {
          _logger.e('❌ WebSocket error: $error');
          _scheduleReconnect();
        },
        onDone: () {
          _logger.w('🔌 WebSocket desconectado.');
          _scheduleReconnect();
        },
      );
    } catch (e) {
      _logger.e('❌ Falha na conexão WebSocket: $e');
      _scheduleReconnect();
    }
  }

  void _sendRegister() {
    if (_socket?.readyState == WebSocket.open) {
      final hostname = Platform.localHostname;
      _socket!.add(
        json.encode({
          'type': 'register',
          'hostname': hostname,
          'platform': Platform.operatingSystem,
        }),
      );
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_socket?.readyState == WebSocket.open) {
        _socket!.add(json.encode({'type': 'heartbeat'}));
      }
    });
  }

  void _scheduleReconnect() {
    if (_isDisposed) return;

    _heartbeatTimer?.cancel();
    if (_reconnectTimer?.isActive ?? false) return;

    _logger.i('🔄 Tentando reconectar em 5 segundos...');
    _reconnectTimer = Timer(Duration(seconds: 5), () {
      if (_serverUrl != null) {
        connect(_serverUrl!);
      }
    });
  }

  Future<void> sendShutdownSignal() async {
    if (_socket?.readyState == WebSocket.open) {
      _logger.w('🛑 Enviando sinal de SHUTDOWN...');
      final hostname = Platform.localHostname;
      _socket!.add(json.encode({'type': 'shutdown', 'hostname': hostname}));
      // Aguarda um pouco para garantir o envio
      await Future.delayed(Duration(milliseconds: 500));
      await _socket!.close();
    }
  }

  void _handleNotification(Map<String, dynamic> data) {
    final type = data['type'];
    // Implementar lógica de notificação se necessário
    // Por enquanto, apenas loga
    if (type == 'device_offline' || type == 'device_online') {
      _logger.d('Status update received: $type');
    }
  }

  void dispose() {
    _isDisposed = true;
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _socket?.close();
    _controller.close();
  }
}
