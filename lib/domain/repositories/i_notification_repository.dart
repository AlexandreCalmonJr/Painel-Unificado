import 'package:dartz/dartz.dart';
import 'package:painel_windowns/core/error/failures.dart';

/// Interface do repositório de notificações
abstract class INotificationRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getNotifications(
    String token,
  );
  Future<Either<Failure, Unit>> markAsRead(String token, String notificationId);
  Future<Either<Failure, Unit>> markAllAsRead(String token);
  Future<Either<Failure, Unit>> deleteNotification(
    String token,
    String notificationId,
  );
}
