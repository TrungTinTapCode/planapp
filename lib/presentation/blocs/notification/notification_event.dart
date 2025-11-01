import 'package:equatable/equatable.dart';
import '../../../domain/entities/app_notification.dart';

abstract class NotificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationStartListening extends NotificationEvent {
  final String userId;
  NotificationStartListening(this.userId);
  @override
  List<Object?> get props => [userId];
}

class NotificationUpdated extends NotificationEvent {
  final List<AppNotification> items;
  NotificationUpdated(this.items);
  @override
  List<Object?> get props => [items];
}

class NotificationMarkAsRead extends NotificationEvent {
  final String userId;
  final String notificationId;
  NotificationMarkAsRead(this.userId, this.notificationId);
  @override
  List<Object?> get props => [userId, notificationId];
}
