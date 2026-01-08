import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/failures.dart';

/// Interface do repositório de WebSocket
///
/// Nota: WebSocket é tratado como um serviço de infraestrutura,
/// não como um repository tradicional. O WebSocketService existente
/// será mantido na camada de serviços (services/) pois gerencia
/// conexões em tempo real e não dados persistentes.
///
/// Esta interface serve apenas como contrato para futuras implementações
/// caso seja necessário abstrair a lógica do WebSocket.
abstract class IWebSocketRepository {
  /// Conecta ao WebSocket
  Future<Either<Failure, Unit>> connect(String url, String token);

  /// Desconecta do WebSocket
  Future<Either<Failure, Unit>> disconnect();

  /// Envia mensagem via WebSocket
  Future<Either<Failure, Unit>> sendMessage(Map<String, dynamic> message);

  /// Stream de mensagens recebidas
  Stream<Map<String, dynamic>> get messageStream;

  /// Verifica se está conectado
  bool get isConnected;
}
