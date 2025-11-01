import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/firebase/notification_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationService _service;
  NotificationRepositoryImpl(this._service);

  @override
  Stream<List<AppNotification>> getUserNotifications(String userId) {
    return _service.streamUserNotifications(userId);
  }

  @override
  Future<void> markAsRead(String userId, String notificationId) {
    return _service.markAsRead(userId, notificationId);
  }

  @override
  Stream<int> getUnreadCount(String userId) {
    return _service.streamUnreadCount(userId);
  }
}
