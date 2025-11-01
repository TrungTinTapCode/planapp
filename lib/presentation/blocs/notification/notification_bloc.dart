import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/notification_repository.dart';
import '../../../domain/entities/app_notification.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repo;
  StreamSubscription<List<AppNotification>>? _sub;

  NotificationBloc({required NotificationRepository repo})
    : _repo = repo,
      super(NotificationInitial()) {
    on<NotificationStartListening>(_onStart);
    on<NotificationUpdated>(_onUpdated);
    on<NotificationMarkAsRead>(_onMarkRead);
  }

  Future<void> _onStart(
    NotificationStartListening event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    await _sub?.cancel();
    _sub = _repo
        .getUserNotifications(event.userId)
        .listen(
          (items) {
            add(NotificationUpdated(items));
          },
          onError: (e) {
            emit(NotificationError(e.toString()));
          },
        );
  }

  Future<void> _onUpdated(
    NotificationUpdated event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoadSuccess(event.items));
  }

  Future<void> _onMarkRead(
    NotificationMarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _repo.markAsRead(event.userId, event.notificationId);
    } catch (e) {
      emit(NotificationError('Không thể cập nhật thông báo: $e'));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
