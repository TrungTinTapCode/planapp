// Màn hình Thông báo (embedded trong TabBar)
// Vị trí: lib/presentation/screens/notification/notification_screen.dart

import 'package:flutter/material.dart';
import 'notification_ui.dart';

class NotificationItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final DateTime time;
  final bool unread;

  const NotificationItem({
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

  // Mock data tĩnh (sẽ thay bằng Bloc/UseCase sau)
  final List<NotificationItem> _items = [
    NotificationItem(
      icon: Icons.assignment_turned_in,
      title: 'Bạn được giao nhiệm vụ mới',
      subtitle: '"Thiết kế UI màn hình Task" trong dự án Alpha',
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      unread: true,
    ),
    NotificationItem(
      icon: Icons.chat_bubble_outline,
      title: 'Bình luận mới trong Task',
      subtitle: 'Minh: "Check lại phần deadline giúp mình nhé"',
      time: DateTime.now().subtract(const Duration(hours: 1, minutes: 12)),
      unread: true,
    ),
    NotificationItem(
      icon: Icons.folder_shared,
      title: 'Bạn đã được thêm vào dự án',
      subtitle: 'Dự án: Project Beta',
      time: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      unread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered =
        _filterIndex == 0 ? _items : _items.where((e) => e.unread).toList();

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 400));
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
                  onTap: () {},
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatRelativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút';
    if (diff.inHours < 24) return '${diff.inHours} giờ';
    return '${diff.inDays} ngày';
  }
}
