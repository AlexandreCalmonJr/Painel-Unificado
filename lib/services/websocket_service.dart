// File: lib/services/websocket_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Serviço WebSocket para comunicação em tempo real com o servidor
/// Refatorado para não depender de GetX
class WebSocketService {
  WebSocketService(this._logger);

  final Logger _logger;
  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // Streams para eventos específicos
  final _deviceUpdatesController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get deviceUpdates =>
      _deviceUpdatesController.stream;

  final _dashboardStatsController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get dashboardStats =>
      _dashboardStatsController.stream;

  final _connectionStatusController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  String? _lastUrl;
  int _retryCount = 0;
  static const int _maxRetries = 5;
  static const Duration _heartbeatInterval = Duration(seconds: 30);

  /// Conecta ao WebSocket do servidor
  void connect(String baseUrl) {
    _lastUrl = baseUrl;
    _connectInternal();
  }

  void _connectInternal() {
    if (_isConnected || _lastUrl == null) return;

    try {
      // Converte http:// para ws:// e https:// para wss://
      final wsUrl = _lastUrl!
          .replaceFirst('http://', 'ws://')
          .replaceFirst('https://', 'wss://');
      final fullWsUrl = '$wsUrl/ws';

      _logger.i('🔌 Conectando WebSocket: $fullWsUrl');

      _channel = WebSocketChannel.connect(Uri.parse(fullWsUrl));

      _channel!.stream.listen(
        _onMessage,
        onDone: () {
          _logger.w('🔌 WebSocket desconectado');
          _handleDisconnect();
        },
        onError: (error) {
          _logger.e('❌ Erro no WebSocket: $error');
          _handleDisconnect();
        },
      );

      _isConnected = true;
      _retryCount = 0;
      _connectionStatusController.add(true);
      _startHeartbeat();
      _logger.i('✅ WebSocket conectado!');

      // Registra o cliente como painel admin
      _send({
        'type': 'register',
        'clientId': 'painel_admin',
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      _logger.e('❌ Falha ao conectar WebSocket: $e');
      _handleDisconnect();
    }
  }

  void _onMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final type = data['type'] as String?;

      _logger.d('📨 WebSocket message: $type');

      switch (type) {
        case 'heartbeat_ack':
        case 'pong':
          // Heartbeat acknowledgment - connection alive
          break;

        case 'device_online':
        case 'device_offline':
        case 'device_update':
          _deviceUpdatesController.add(data);
          break;

        case 'dashboard_stats':
          _dashboardStatsController.add(data['data'] as Map<String, dynamic>);
          break;

        default:
          _logger.d('📨 Mensagem WebSocket: $data');
      }
    } catch (e) {
      _logger.e('❌ Erro ao processar mensagem WebSocket: $e');
    }
  }

  void _send(Map<String, dynamic> data) {
    if (_channel != null && _isConnected) {
      try {
        _channel!.sink.add(jsonEncode(data));
      } catch (e) {
        _logger.e('❌ Erro ao enviar mensagem WebSocket: $e');
      }
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (_isConnected) {
        _send({
          'type': 'heartbeat',
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  void _handleDisconnect() {
    _isConnected = false;
    _connectionStatusController.add(false);
    _heartbeatTimer?.cancel();
    _channel = null;

    if (_retryCount < _maxRetries) {
      final delay = Duration(
        seconds: 2 * (_retryCount + 1),
      ); // Exponential backoff
      _logger.w('🔄 Tentando reconectar em ${delay.inSeconds}s... (${_retryCount + 1}/$_maxRetries)');
      
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(delay, () {
        _retryCount++;
        _connectInternal();
      });
    } else {
      _logger.e('❌ Número máximo de tentativas de reconexão atingido');
    }
  }

  /// Desconecta do WebSocket
  void disconnect() {
    _logger.i('🔌 Desconectando WebSocket');
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _channel?.sink.close();
    _isConnected = false;
    _connectionStatusController.add(false);
  }

  /// Reseta contador de retry (útil após reconexão manual)
  void resetRetryCount() {
    _retryCount = 0;
  }

  /// Envia sinal de shutdown (quando app está fechando)
  void sendShutdownSignal() {
    if (_isConnected) {
      _send({
        'type': 'shutdown',
        'clientId': 'painel_admin',
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Cleanup
  void dispose() {
    disconnect();
    _deviceUpdatesController.close();
    _dashboardStatsController.close();
    _connectionStatusController.close();
  }
}
