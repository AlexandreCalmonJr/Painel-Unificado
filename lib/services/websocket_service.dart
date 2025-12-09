import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  final Logger _logger;
  WebSocketChannel? _channel;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  bool _isDisposed = false;
  String? _serverUrl;
  bool _isConnected = false;

  WebSocketService(this._logger);

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  Future<void> connect(String serverUrl) async {
    _serverUrl = serverUrl;
    // Se já estiver conectado na mesma URL, não faz nada
    if (_isConnected && _channel != null) return;

    try {
      final wsUrl = serverUrl.replaceFirst('http', 'ws');
      _logger.i('🔌 Tentando conectar WebSocket em $wsUrl/ws...');

      final uri = Uri.parse('$wsUrl/ws');
      _channel = WebSocketChannel.connect(uri);

      // Aguarda a primeira mensagem ou erro para confirmar conexão
      // Na verdade, WebSocketChannel não tem callback de "conectado" explícito sem IO.
      // Vamos assumir que está tentando e monitorar o stream.

      _channel!.stream.listen(
        (message) {
          if (!_isConnected) {
            _isConnected = true;
            _logger.i('✅ WebSocket conectado com sucesso em $wsUrl!');
            _sendRegister();
            _startHeartbeat();
          }

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
          _isConnected = false;
          _scheduleReconnect();
        },
        onDone: () {
          _logger.w('🔌 WebSocket desconectado.');
          _isConnected = false;
          _scheduleReconnect();
        },
      );

      // Envia um ping inicial para forçar a verificação da conexão
      // Se falhar, vai cair no onError
      // Mas só podemos enviar se o sink estiver aberto.
      // O sink do WebSocketChannel geralmente está pronto.
    } catch (e) {
      _logger.e('❌ Falha ao iniciar conexão WebSocket: $e');
      _isConnected = false;
      _scheduleReconnect();
    }
  }

  void _sendRegister() {
    if (_isConnected) {
      final hostname = kIsWeb ? 'Web Client' : Platform.localHostname;
      final os = kIsWeb ? 'Web' : Platform.operatingSystem;

      try {
        _channel?.sink.add(
          json.encode({
            'type': 'register',
            'hostname': hostname,
            'platform': os,
          }),
        );
      } catch (e) {
        _logger.e('Erro ao enviar registro: $e');
      }
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_isConnected) {
        try {
          _channel?.sink.add(json.encode({'type': 'heartbeat'}));
        } catch (e) {
          _logger.e('Erro ao enviar heartbeat: $e');
        }
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
    if (_isConnected) {
      _logger.w('🛑 Enviando sinal de SHUTDOWN...');
      final hostname = kIsWeb ? 'Web Client' : Platform.localHostname;
      try {
        _channel?.sink.add(
          json.encode({'type': 'shutdown', 'hostname': hostname}),
        );
        // Aguarda um pouco para garantir o envio
        await Future.delayed(Duration(milliseconds: 500));
        await _channel?.sink.close();
      } catch (e) {
        _logger.e('Erro ao enviar shutdown: $e');
      }
      _isConnected = false;
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
    _channel?.sink.close();
    _controller.close();
    _isConnected = false;
  }
}
