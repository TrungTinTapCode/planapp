import '../entities/app_notification.dart';

abstract class NotificationRepository {
  Stream<List<AppNotification>> getUserNotifications(String userId);
  Future<void> markAsRead(String userId, String notificationId);
  Stream<int> getUnreadCount(String userId);
}
