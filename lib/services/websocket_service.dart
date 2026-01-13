import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:logger/src/logger.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService extends GetxService {
  WebSocketService(Logger logger);

  WebSocketChannel? _channel;
  final _isConnected = false.obs;
  bool get isConnected => _isConnected.value;

  // Streams para eventos específicos
  final _deviceUpdatesController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get deviceUpdates =>
      _deviceUpdatesController.stream;

  final _dashboardStatsController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get dashboardStats =>
      _dashboardStatsController.stream;

  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  String? _lastUrl;
  int _retryCount = 0;
  static const int _maxRetries = 5;

  void connect(String baseUrl) {
    _lastUrl = baseUrl;
    _connectInternal();
  }

  void _connectInternal() {
    if (_isConnected.value || _lastUrl == null) return;

    try {
      // Converte http:// para ws://
      final wsUrl = '${_lastUrl!.replaceFirst('http', 'ws')}/ws';
      print('Tentando conectar WebSocket: $wsUrl');

      _channel = IOWebSocketChannel.connect(
        Uri.parse(wsUrl),
        pingInterval: const Duration(seconds: 30),
      );

      _channel!.stream.listen(
        (message) {
          _onMessage(message);
        },
        onDone: () {
          print('WebSocket desconectado.');
          _handleDisconnect();
        },
        onError: (error) {
          print('Erro no WebSocket: $error');
          _handleDisconnect();
        },
      );

      _isConnected.value = true;
      _retryCount = 0;
      _startHeartbeat();
      print('WebSocket conectado!');

      // Registra o cliente
      _send({'type': 'register', 'clientId': 'painel_admin'});
    } catch (e) {
      print('Falha ao conectar WebSocket: $e');
      _handleDisconnect();
    }
  }

  void _onMessage(dynamic message) {
    try {
      final data = jsonDecode(
        message as String,
      ) as Map<String, dynamic>;

      switch (data['type']) {
        case 'heartbeat_ack':
          // Alive
          break;
        case 'device_update':
          _deviceUpdatesController.add(data['data'] as Map<String, dynamic>);
          break;
        case 'dashboard_stats':
          _dashboardStatsController.add(data['data'] as Map<String, dynamic>);
          break;
        default:
          print('Mensagem WebSocket recebida: $data');
      }
    } catch (e) {
      print('Erro ao processar mensagem WebSocket: $e');
    }
  }

  void _send(Map<String, dynamic> data) {
    if (_channel != null && _isConnected.value) {
      _channel!.sink.add(jsonEncode(data));
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _send({'type': 'heartbeat'});
    });
  }

  void _handleDisconnect() {
    _isConnected.value = false;
    _heartbeatTimer?.cancel();
    _channel = null;

    if (_retryCount < _maxRetries) {
      final delay = Duration(
        seconds: 2 * (_retryCount + 1),
      ); // Backoff exponencial
      print('Tentando reconectar em ${delay.inSeconds} segundos...');
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(delay, () {
        _retryCount++;
        _connectInternal();
      });
    } else {
      print('Número máximo de tentativas de reconexão atingido.');
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _channel?.sink.close();
    _isConnected.value = false;
  }

  @override
  void onClose() {
    disconnect();
    _deviceUpdatesController.close();
    _dashboardStatsController.close();
    super.onClose();
  }

  void sendShutdownSignal() {}
}
