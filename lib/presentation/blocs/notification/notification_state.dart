import 'package:equatable/equatable.dart';
import '../../../domain/entities/app_notification.dart';

abstract class NotificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoadSuccess extends NotificationState {
  final List<AppNotification> items;
  NotificationLoadSuccess(this.items);
  @override
  List<Object?> get props => [items];
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
  @override
  List<Object?> get props => [message];
}
