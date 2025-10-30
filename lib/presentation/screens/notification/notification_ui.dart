// UI Components cho màn hình Thông báo
// Vị trí: lib/presentation/screens/notification/notification_ui.dart

import 'package:flutter/material.dart';

class NotificationUIComponents {
  // Header/filter của danh sách thông báo
  static Widget filterChips({
    required int selectedIndex,
    required void Function(int) onSelected,
  }) {
    final labels = ['Tất cả', 'Chưa đọc'];
    return Wrap(
      spacing: 8,
      children: List.generate(labels.length, (i) {
        final selected = selectedIndex == i;
        return ChoiceChip(
          label: Text(labels[i]),
          selected: selected,
          onSelected: (_) => onSelected(i),
        );
      }),
    );
  }

  // Trạng thái rỗng
  static Widget emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.notifications_off, size: 56, color: Colors.grey),
          SizedBox(height: 8),
          Text('Không có thông báo', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // Item thông báo
  static Widget notificationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String timeText,
    required bool unread,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Icon(icon, color: Colors.blue),
          ),
          if (unread)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: Text(
        timeText,
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      onTap: onTap,
    );
  }
}
