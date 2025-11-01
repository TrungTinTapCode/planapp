// Màn hình Thông báo (embedded trong TabBar)
// Vị trí: lib/presentation/screens/notification/notification_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/notification/notification_bloc.dart';
import '../../blocs/notification/notification_state.dart';
import '../../blocs/notification/notification_event.dart';
import '../../../domain/entities/app_notification.dart';
import 'notification_ui.dart';

// Lớp model UI nếu cần tuỳ biến thêm trong tương lai
class NotificationItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final DateTime time;
  final bool unread;
  final String id;

  const NotificationItem({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    this.unread = false,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int _filterIndex = 0; // 0: all, 1: unread

  @override
  void initState() {
    super.initState();
    // Đảm bảo NotificationBloc bắt đầu lắng nghe kể cả khi listener ở main chưa bắt được
    // vì AuthAuthenticated có thể phát rất sớm trong vòng đời app.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthBloc>().state;
      final notifState = context.read<NotificationBloc>().state;
      if (auth is AuthAuthenticated && notifState is NotificationInitial) {
        context.read<NotificationBloc>().add(
          NotificationStartListening(auth.user.id),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        List<NotificationItem> items = [];
        if (state is NotificationLoadSuccess) {
          items = state.items.map(_mapEntityToItem).toList();
        }

        // Loading / Initial state UI
        if (state is NotificationInitial || state is NotificationLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final filtered =
            _filterIndex == 0 ? items : items.where((e) => e.unread).toList();

        return RefreshIndicator(
          onRefresh: () async {
            // Với stream realtime, không cần refresh thủ công; chỉ delay để hiệu ứng.
            await Future.delayed(const Duration(milliseconds: 300));
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              NotificationUIComponents.filterChips(
                selectedIndex: _filterIndex,
                onSelected: (i) => setState(() => _filterIndex = i),
              ),
              const SizedBox(height: 12),
              if (filtered.isEmpty) ...[
                const SizedBox(height: 40),
                NotificationUIComponents.emptyState(),
              ] else ...[
                ...filtered.map(
                  (e) => Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: NotificationUIComponents.notificationTile(
                      icon: e.icon,
                      title: e.title,
                      subtitle: e.subtitle,
                      timeText: _formatRelativeTime(e.time),
                      unread: e.unread,
                      onTap: () => _onTapItem(context, e),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatRelativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút';
    if (diff.inHours < 24) return '${diff.inHours} giờ';
    return '${diff.inDays} ngày';
  }

  NotificationItem _mapEntityToItem(AppNotification e) {
    IconData icon;
    switch (e.type) {
      case 'TASK_ASSIGNED':
        icon = Icons.assignment_turned_in;
        break;
      case 'MENTIONED':
        icon = Icons.chat_bubble_outline;
        break;
      case 'DEADLINE_SOON':
        icon = Icons.access_time;
        break;
      default:
        icon = Icons.notifications;
    }
    return NotificationItem(
      id: e.id,
      icon: icon,
      title: e.title,
      subtitle: e.body,
      time: e.createdAt,
      unread: !e.isRead,
    );
  }

  void _onTapItem(BuildContext context, NotificationItem item) {
    // Đánh dấu đã đọc nếu đang unread
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && item.unread) {
      context.read<NotificationBloc>().add(
        NotificationMarkAsRead(authState.user.id, item.id),
      );
    }
    // TODO: Điều hướng tới màn hình phù hợp theo loại thông báo
  }
}
